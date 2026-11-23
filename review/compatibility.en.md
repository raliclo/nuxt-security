# Compatibility and deployment validation

Chinese: [compatibility.md](./compatibility.md). See validation.en.md for completed checks.

Local storage consumption is serialized within one process. Multiple workers or instances require `security.rateLimiter.redis: { url, prefix }` pointing to the same Redis. Enable Redis at build time; override its connection through private runtime config. Never expose its URL in public config. Lua consumes tokens atomically using Redis time and TTL; connection failure returns 503. Separate applications need separate prefixes. TCP Redis is not supported by every edge runtime; the Cloudflare fixture disables rate limiting.

`trustProxy` remains false by default. Enable it, or configure an IP header, only behind an ingress that rewrites those headers and prevents direct bypass.

Independent `headers.contentSecurityPolicy` and `headers.contentSecurityPolicyReportOnly` policies can coexist. The legacy top-level report-only flag moves the enforced policy to report-only, with an explicit report policy taking precedence.

`ssg.dynamicNonce: true` retains prerendered HTML in server assets and serves it with a fresh nonce and `private, no-store`. HTML is omitted from public output. Keep a server runtime and do not force CDN caching. Routes with `nonce: false` use the regular renderer. Streaming bootstrap and hydration scripts share the request nonce; ordinary SSG uses hashes. JSON payload responses must not replace HTML headers.

`byFileExtension` supplies header defaults for matching suffixes, below explicit route rules and above global defaults, preserving false. Cloudflare header exports apply broad rules first and detach before replacement. Builds fail above 100 rules or a 2000-character line; reduce prerendered routes or use server-backed dynamic nonces. [Cloudflare requirements](https://developers.cloudflare.com/pages/configuration/headers/)

The documentation site uses Nuxt 4, Content 3 and UI 4. Its server SQLite API avoids requiring WASM evaluation in the browser CSP. Install its independent lockfile. The development-only inspector and DevTools tab expose capability names, booleans, route names and header names, never values. Disable with `security.devtools: false`.

The collection explicitly uses Content's Zod 4 schema adapter. Docs resolutions and npm overrides require Zod 4.6.7 or newer; do not switch back to legacy v3 schema exports. The oversized-collection regression verifies that `.max()` rejects before walking elements and allocating per-element errors.

Run the commands in compatibility.md using Node 24+, Yarn 1, Bun 1.4.4, Redis on localhost:16381 and a Playwright browser. Windows tests use installed Edge; Linux needs `yarn playwright install --with-deps chromium`. Set `NUXT_SECURITY_DIST=1` for deployment and Nitro 3 builds to validate packaged output. Begin preset builds with clean generated fixture directories; an old `.output/public` can otherwise be imported as public assets. CI builds Vercel, Cloudflare and Bun in that order from a clean checkout.

The native Nitro 3 fixture pins a Nuxt 5x nightly and Nitro RC, with Nitro auto-import compatibility disabled. It is separate from stable Nuxt 4/Nitro 2 validation. Generated nuxt-csurf server copies replace imports and registration while preserving the installed package's token/cookie verification.

Real cloud deployments and Turnstile/PGlite reproductions still require test projects or minimal reproductions. The user currently has none. Local workerd, Vercel artifacts and Bun tests do not establish live cloud behavior.
