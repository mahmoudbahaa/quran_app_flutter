import test from 'node:test';
import assert from 'node:assert/strict';
import { createWorker } from '../src/index.js';

const env = { QF_ENV: 'prelive', QF_CLIENT_ID: 'test-id', QF_CLIENT_SECRET: 'test-secret' };
const request = (path = '/content/api/v4/chapters') => new Request(`https://backend.example${path}`);
const token = () => Response.json({ access_token: 'test-token', expires_in: 3600 });

test('caches tokens and sends credentials only to fixed upstream hosts', async () => {
  const calls = [];
  const worker = createWorker({ fetcher: async (url, options) => {
    calls.push({ url, options });
    return url.endsWith('/oauth2/token') ? token() : Response.json({ chapters: [] });
  } });
  for (let i = 0; i < 2; i++) {
    const response = await worker.fetch(request(), env);
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), { chapters: [] });
    assert.equal(response.headers.get('x-auth-token'), null);
  }
  assert.equal(calls.length, 3);
  assert.equal(calls[0].url, 'https://prelive-oauth2.quran.foundation/oauth2/token');
  assert.equal(calls[0].options.body.get('scope'), 'content');
  assert.equal(calls[1].url, 'https://apis-prelive.quran.foundation/content/api/v4/chapters');
  assert.equal(calls[1].options.headers['x-auth-token'], 'test-token');
  assert.equal(calls[1].options.headers['x-client-id'], 'test-id');
});

test('refreshes once on 401 and never exposes upstream diagnostics', async () => {
  let tokens = 0;
  let content = 0;
  const worker = createWorker({ fetcher: async url => {
    if (url.endsWith('/oauth2/token')) { tokens++; return token(); }
    content++;
    return new Response('private upstream diagnostic', { status: 401 });
  } });
  const response = await worker.fetch(request(), env);
  assert.equal(response.status, 502);
  assert.equal(tokens, 2);
  assert.equal(content, 2);
  assert.equal((await response.text()).includes('private'), false);
});

test('rejects arbitrary routes, invalid pagination, and mutation requests before network access', async () => {
  const worker = createWorker({ fetcher: () => { throw new Error('Unexpected network request'); } });
  for (const [path, status] of [
    ['/oauth2/token', 404], ['/content/api/v4/users', 404],
    ['/content/api/v4/chapters?url=https://evil.example', 400],
    ['/content/api/v4/verses/by_page/1?per_page=all', 400],
    ['/content/api/v4/verses/by_page/1?per_page=51', 400],
    ['/content/api/v4/chapters?page=1&page=2', 400],
    ['/content/api/v4/chapter_recitations/7/115', 404],
  ]) assert.equal((await worker.fetch(request(path), env)).status, status);
  assert.equal((await worker.fetch(new Request('https://backend.example/content/api/v4/chapters', { method: 'POST' }), env)).status, 405);
});

test('fails closed when credentials or environment are missing', async () => {
  const worker = createWorker();
  assert.equal((await worker.fetch(request(), {})).status, 503);
  assert.equal((await worker.fetch(request(), { ...env, QF_ENV: 'other' })).status, 503);
});

test('renews tokens before expiry', async () => {
  let time = 0;
  let tokens = 0;
  const worker = createWorker({ now: () => time, fetcher: async url => {
    if (url.endsWith('/oauth2/token')) { tokens++; return token(); }
    return Response.json({ chapters: [] });
  } });
  await worker.fetch(request(), env);
  time = 3540001;
  await worker.fetch(request(), env);
  assert.equal(tokens, 2);
});

test('preserves rate-limit status and Retry-After without retrying', async () => {
  let content = 0;
  const worker = createWorker({ fetcher: async url => {
    if (url.endsWith('/oauth2/token')) return token();
    content++;
    return new Response('limited', { status: 429, headers: { 'Retry-After': '30' } });
  } });
  const response = await worker.fetch(request(), env);
  assert.equal(response.status, 429);
  assert.equal(response.headers.get('Retry-After'), '30');
  assert.equal(content, 1);
});

test('reports safe token failure reasons without leaking OAuth descriptions', async () => {
  const worker = createWorker({ fetcher: async () => Response.json({
    error: 'invalid_client', error_description: 'test-secret private details',
  }, { status: 401 }) });
  const response = await worker.fetch(request(), env);
  assert.equal(response.status, 502);
  assert.deepEqual(await response.json(), {
    error: 'upstream_unavailable', stage: 'token', reason: 'invalid_client', upstream_status: 401,
  });
});

test('identifies documented user-agent blocks and sets an explicit user agent', async () => {
  const worker = createWorker({ fetcher: async (_url, options) => {
    assert.equal(options.headers['User-Agent'], 'QuranFlutterBackend/1.0');
    return new Response('error code: 1010 private diagnostic', { status: 403 });
  } });
  const response = await worker.fetch(request(), env);
  assert.equal((await response.json()).reason, 'user_agent_blocked');
});

test('distinguishes token and content connection failures without exposing exception messages', async () => {
  for (const stage of ['token', 'content']) {
    const worker = createWorker({ fetcher: async url => {
      if (stage === 'content' && url.endsWith('/oauth2/token')) return token();
      throw new Error('private credential details');
    } });
    assert.deepEqual(await (await worker.fetch(request(), env)).json(), {
      error: 'upstream_unavailable', stage, reason: 'connection_failed',
    });
  }
});

test('reports malformed token responses safely', async () => {
  for (const [body, reason] of [['<html>private diagnostic</html>', 'invalid_json'], ['{}', 'invalid_token_response']]) {
    const worker = createWorker({ fetcher: async () => new Response(body) });
    assert.deepEqual(await (await worker.fetch(request(), env)).json(), {
      error: 'upstream_unavailable', stage: 'token', reason, upstream_status: 200,
    });
  }
});

test('rejects redirects without forwarding credentials to a new location', async () => {
  let calls = 0;
  const worker = createWorker({ fetcher: async (_url, options) => {
    calls++;
    assert.equal(options.redirect, 'manual');
    return new Response(null, { status: 302, headers: { Location: 'https://other.example' } });
  } });
  assert.deepEqual(await (await worker.fetch(request(), env)).json(), {
    error: 'upstream_unavailable', stage: 'token', reason: 'unexpected_redirect', upstream_status: 302,
  });
  assert.equal(calls, 1);
});
