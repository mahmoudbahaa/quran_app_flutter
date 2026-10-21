import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { Miniflare, convertV4MiniflareOptions } from 'miniflare';

test('default fetch implementation works in the Cloudflare runtime', async () => {
  const runtime = new Miniflare(convertV4MiniflareOptions({ workers: [
    {
      name: 'backend', modules: true,
      script: await readFile(new URL('../src/index.js', import.meta.url), 'utf8'),
      compatibilityDate: '2026-10-21',
      bindings: { QF_ENV: 'prelive', QF_CLIENT_ID: 'test-id', QF_CLIENT_SECRET: 'test-secret' },
      outboundService: 'upstream',
    },
    {
      name: 'upstream', modules: true, compatibilityDate: '2026-10-21',
      script: `export default { async fetch(request) {
        if (new URL(request.url).pathname === '/oauth2/token') {
          return Response.json({access_token: 'test-token', expires_in: 3600});
        }
        if (request.headers.get('x-auth-token') !== 'test-token') {
          return new Response('missing token', {status:401});
        }
        return Response.json({chapters:[{id:1}]});
      } };`,
    },
  ] }));
  try {
    const response = await runtime.dispatchFetch('https://backend.example/content/api/v4/chapters');
    const body = await response.json();
    assert.equal(response.status, 200, JSON.stringify(body));
    assert.deepEqual(body, { chapters: [{ id: 1 }] });
  } finally { await runtime.dispose(); }
});
