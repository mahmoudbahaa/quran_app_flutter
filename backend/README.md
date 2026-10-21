# Quran Foundation content backend

A Cloudflare Worker for read-only Quran Foundation Content v4 calls. Flutter uses this backend through the QURAN_API_BASE_URL build setting.
See the root README for client configuration and current prelive limitations.

## Manual dashboard deployment

1. Sign in at https://dash.cloudflare.com/ and open Workers & Pages.
2. Choose Create application / Create Worker, then the Hello World option.
3. Name the Worker `quran-content-prelive` and deploy the starter.
4. Open Edit code. Replace the starter JavaScript with all of `src/index.js`,
   then deploy. The script is self-contained and needs no runtime packages.
5. In Settings > Variables and Secrets add:

   | Type | Name | Value |
   | --- | --- | --- |
   | Plaintext | QF_ENV | prelive |
   | Secret | QF_CLIENT_ID | Your prelive client ID |
   | Secret | QF_CLIENT_SECRET | Your prelive client secret |

6. Save/deploy the configuration. Set compatibility date to `2026-10-21`.
7. Visit `https://YOUR-WORKER.workers.dev/health`. Expect
   `{"status":"ok","environment":"prelive"}`. This checks the Worker only.
8. Visit `/content/api/v4/chapters` on the same host. A successful chapters JSON
   response verifies the actual credentials and upstream access.
9. Test `/content/api/v4/verses/by_page/1?words=true&per_page=50`.
   Prelive contains only surahs 1 and 2.
10. Once verified, create a separate `quran-content-production` Worker using the
    same code, `QF_ENV=production`, and the production credentials. Verify the
    same endpoints there. Do not mix credentials across environments.

Keep the Cloudflare Workers Free plan. No custom domain or database is needed.
The supported routes are chapters, chapter reciters, verses by page, and chapter
recitations (single chapter or all chapters). The request path includes
`/content/api/v4`. Unknown routes, query parameters, and non-GET requests are
rejected. The backend returns upstream content JSON without QF auth headers.
Font and MP3 downloads continue directly from their supplied asset URLs.

## Local development and CLI alternative

Requires Node 22+. Run `npm ci`, then `npm test` and `npm run check`.
For local use copy `.env.example` to `.dev.vars.prelive`, enter prelive values,
and run `npm run dev -- --env prelive`.

CLI deployment, if preferred later:

```sh
npx wrangler login
npx wrangler secret put QF_CLIENT_ID --env prelive
npx wrangler secret put QF_CLIENT_SECRET --env prelive
npm run deploy:prelive
```

Use `--env production` and `npm run deploy:production` for the other environment.
Secrets are entered interactively. Never commit them or place them in Flutter.

## Behavior and limits

Access tokens are cached in isolate memory until one minute before expiry;
concurrent requests in one isolate share token retrieval. Different Cloudflare
isolates can obtain independent tokens. Content responses are currently not
cached by the backend. One upstream 401 triggers token renewal and one retry.
429 responses preserve Retry-After. Upstream error bodies and credentials are
never returned or logged. Failed calls time out rather than hanging forever.

This is a public read-only content endpoint. The route allowlist prevents an
arbitrary proxy, but does not authenticate app installations or prevent quota
abuse. No shared key embedded in Flutter can provide that protection. Configure
appropriate Cloudflare rate controls before broad public distribution.

Twelve automated tests cover mocked upstream HTTP and the Cloudflare runtime. Live credentials and cloud
availability must be checked separately via the endpoints above.

References:
- https://api-docs.quran.foundation/docs/quickstart/manual-authentication/
- https://developers.cloudflare.com/workers/get-started/dashboard/
- https://developers.cloudflare.com/workers/configuration/secrets/

## Diagnosing upstream failures

The response includes safe `stage`, `reason`, and, when available,
`upstream_status` fields. `stage=token` identifies OAuth failures;
`stage=content` identifies Content API failures. `invalid_client` means the
OAuth server rejected the credentials, while `invalid_scope` identifies a scope
problem. `user_agent_blocked` identifies the documented HTTP 403 / 1010 block.
Connection failures and timeouts have separate reason codes. Raw upstream error
bodies, descriptions, tokens, and credential values are never returned.

The Worker uses `redirect: manual`: workerd does not support `redirect: error`.
Redirect responses are rejected explicitly so credentials never follow redirects.
The runtime test catches incompatibilities that Node-only HTTP mocks miss.
