const hosts = {
  prelive: ['https://prelive-oauth2.quran.foundation', 'https://apis-prelive.quran.foundation'],
  production: ['https://oauth2.quran.foundation', 'https://apis.quran.foundation'],
};
const prefix = '/content/api/v4';
const allowedPaths = [
  /^\/chapters$/,
  /^\/resources\/chapter_reciters$/,
  /^\/verses\/by_page\/[1-9]\d{0,3}$/,
  /^\/chapter_recitations\/[1-9]\d{0,5}(?:\/(?:[1-9]|[1-9]\d|10\d|11[0-4]))?$/,
];
const allowedQuery = new Set(['language', 'mushaf', 'words', 'word_fields', 'fields', 'page', 'per_page', 'segments']);

function json(body, status = 200, headers = {}) {
  return Response.json(body, {
    status,
    headers: { 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff', ...headers },
  });
}

class UpstreamError extends Error {
  constructor(stage, reason, status) {
    super(reason);
    this.stage = stage;
    this.reason = reason;
    this.status = status;
  }
}

async function fetchUpstream(fetcher, url, options, stage) {
  try {
    const response = await fetcher(url, options);
    if (response.status >= 300 && response.status < 400) {
      await response.body?.cancel();
      throw new UpstreamError(stage, 'unexpected_redirect', response.status);
    }
    return response;
  } catch (error) {
    if (error instanceof UpstreamError) throw error;
    throw new UpstreamError(stage,
      ['TimeoutError', 'AbortError'].includes(error?.name) ? 'timeout' : 'connection_failed');
  }
}

// Each Worker isolate reuses its token. Other isolates may obtain their own.
// A single pending promise avoids duplicate token requests within an isolate.
// Keep the runtime receiver: a detached native fetch throws in Workers.
export function createWorker({ fetcher = (...args) => globalThis.fetch(...args), now = Date.now } = {}) {
  let tokenState;
  let pending;
  let identity;

  async function token(env, authHost) {
    const nextIdentity = JSON.stringify([env.QF_ENV, env.QF_CLIENT_ID, env.QF_CLIENT_SECRET]);
    if (nextIdentity !== identity) {
      identity = nextIdentity;
      tokenState = undefined;
    }
    if (tokenState && now() < tokenState.expiresAt) return tokenState.value;
    if (!pending) {
      pending = (async () => {
        const response = await fetchUpstream(fetcher, `${authHost}/oauth2/token`, {
          method: 'POST',
          redirect: 'manual',
          signal: AbortSignal.timeout(15000),
          headers: {
            Authorization: `Basic ${btoa(`${env.QF_CLIENT_ID}:${env.QF_CLIENT_SECRET}`)}`,
            'Content-Type': 'application/x-www-form-urlencoded',
            Accept: 'application/json',
            'User-Agent': 'QuranFlutterBackend/1.0',
          },
          body: new URLSearchParams({ grant_type: 'client_credentials', scope: 'content' }),
        }, 'token');
        if (!response.ok) {
          const text = await response.text();
          let reason = 'http_error';
          try {
            const code = JSON.parse(text).error;
            if (['invalid_client', 'invalid_scope', 'unauthorized_client', 'unsupported_grant_type', 'invalid_request'].includes(code)) reason = code;
          } catch {
            if (response.status === 403 && /\b1010\b/.test(text)) reason = 'user_agent_blocked';
          }
          throw new UpstreamError('token', reason, response.status);
        }
        let body;
        try { body = await response.json(); }
        catch { throw new UpstreamError('token', 'invalid_json', response.status); }
        if (typeof body.access_token !== 'string' || !body.access_token || !Number.isFinite(body.expires_in) || body.expires_in <= 0) {
          throw new UpstreamError('token', 'invalid_token_response', response.status);
        }
        tokenState = {
          value: body.access_token,
          expiresAt: now() + Math.max(0, body.expires_in * 1000 - 60000),
        };
        return tokenState.value;
      })().finally(() => { pending = undefined; });
    }
    return pending;
  }

  return {
    async fetch(request, env) {
      const url = new URL(request.url);
      if (request.method !== 'GET') return json({ error: 'method_not_allowed' }, 405, { Allow: 'GET' });
      if (url.pathname === '/health') return json({ status: 'ok', environment: env.QF_ENV });
      if (!url.pathname.startsWith(prefix)) return json({ error: 'not_found' }, 404);
      const path = url.pathname.slice(prefix.length);
      if (!allowedPaths.some(pattern => pattern.test(path))) return json({ error: 'not_found' }, 404);
      for (const [key, value] of url.searchParams) {
        if (!allowedQuery.has(key) || value.length > 1000 || url.searchParams.getAll(key).length !== 1) {
          return json({ error: 'invalid_query' }, 400);
        }
      }
      for (const key of ['page', 'per_page', 'mushaf']) {
        const value = url.searchParams.get(key);
        if (value !== null && (!/^[1-9]\d{0,5}$/.test(value) || (key === 'per_page' && Number(value) > 50))) {
          return json({ error: 'invalid_query', parameter: key }, 400);
        }
      }
      const endpoints = hosts[env.QF_ENV];
      if (!endpoints || !env.QF_CLIENT_ID || !env.QF_CLIENT_SECRET) {
        return json({ error: 'backend_not_configured' }, 503);
      }
      const [authHost, apiHost] = endpoints;
      try {
        const upstreamUrl = `${apiHost}${prefix}${path}${url.search}`;
        const send = async () => {
          const accessToken = await token(env, authHost);
          return fetchUpstream(fetcher, upstreamUrl, {
          redirect: 'manual',
          signal: AbortSignal.timeout(20000),
          headers: {
            Accept: 'application/json',
            'x-client-id': env.QF_CLIENT_ID,
            'x-auth-token': accessToken,
            'User-Agent': 'QuranFlutterBackend/1.0',
          },
        }, 'content');
        };
        let response = await send();
        if (response.status === 401) {
          await response.body?.cancel();
          tokenState = undefined;
          response = await send();
        }
        if (!response.ok) {
          const status = response.status;
          const retryAfter = response.headers.get('Retry-After');
          await response.body?.cancel();
          // Do not expose upstream diagnostics or authentication failures.
          return json({ error: status === 429 ? 'rate_limited' : 'upstream_request_failed', stage: 'content', upstream_status: status },
            status === 401 || status === 403 ? 502 : status,
            status === 429 && retryAfter ? { 'Retry-After': retryAfter } : {});
        }
        try { return json(await response.json()); }
        catch { throw new UpstreamError('content', 'invalid_json', response.status); }
      } catch (error) {
        if (error instanceof UpstreamError) {
          return json({
            error: 'upstream_unavailable',
            stage: error.stage,
            reason: error.reason,
            ...(error.status ? { upstream_status: error.status } : {}),
          }, 502);
        }
        return json({ error: 'upstream_unavailable', stage: 'backend', reason: 'unexpected_error' }, 502);
      }
    },
  };
}

export default createWorker();
