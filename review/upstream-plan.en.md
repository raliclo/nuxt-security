# Upstream review and repair plan

Snapshot: 2026-11-23, Baroshem/nuxt-security at d074467. Target fork: raliclo/nuxt-security; branch: codex/nuxt-latest-security-fixes. The snapshot contains 38 issues and 35 PRs.

This is a repair/acceptance plan, not a completion checklist. See [the Traditional Chinese counterpart](./upstream-plan.md) for priorities and [validation](./validation.md) for executed evidence. Existing-main fixes, overlapping PRs, new features and external platform limits must not be reported as one set of completed fixes.

The follow-up implements docs migration, native Nitro 3, streaming, Redis, bounded bodies, islands and deployment artifacts. The dispositions below retain their original design context; consult validation.en.md for current evidence. Live cloud and Turnstile/PGlite reproduction targets are still unavailable.

## Acceptance

Each behavior change needs a regression covering valid and hostile/boundary input. Keep secure defaults. Validate current stable Nuxt 4.6.4 with actual Nitro/h3/Vite versions, prepare, lint, tests and package build. Verify docs independently: its old Content/UI stack and separate lockfile require a coordinated migration. Windows tests do not establish Linux, Node LTS, Bun, streaming or deployment-preset behavior.

## Item-by-item disposition

- [PR #777: fix(rateLimiter): count the base path of a wildcard route with its sub-paths](https://github.com/Baroshem/nuxt-security/pull/777)
  - Same fix as #774; parameterized catch-alls remain a separate test requirement.
- [PR #776: fix(nonce): don't pair up quotes from CSS when injecting the nonce](https://github.com/Baroshem/nuxt-security/pull/776)
  - Preferred nonce implementation; add nonce attribute quoting/duplication and false closing-tag cases.
- [Issue #775: Prerendered pages lose their security headers when `@nuxtjs/sitemap` runs with `zeroRuntime`](https://github.com/Baroshem/nuxt-security/issues/775)
  - Prevent empty renderers from erasing collected headers. Test persistence and separately reproduce sitemap zeroRuntime on Node/Vercel in both module orders.
- [Issue #774: Rate limiter: a `/path/**` rule sets the limit for `/path` but not its counter, so `/path` shares the global counter and can shrink it](https://github.com/Baroshem/nuxt-security/issues/774)
  - Unify literal wildcard base-path and child counters; test exact-rule precedence, queries and trailing slashes.
- [PR #773: fix(rateLimiter): count the first request of an interval](https://github.com/Baroshem/nuxt-security/pull/773)
  - Same fix as #772; defer runtime storage/config access until request handling.
- [Issue #772: Rate limiter allows `tokensPerInterval + 1` requests in the first interval](https://github.com/Baroshem/nuxt-security/issues/772)
  - Count the first request and test zero tokens, renewal, remaining and reset headers.
- [PR #771: fix(cors): stop returning true from the preflight handler on h3 v1](https://github.com/Baroshem/nuxt-security/pull/771)
  - Same fix as #770; preserve the HTTP regression fixture.
- [Issue #770: corsHandler throws ERR_HTTP_HEADERS_SENT on every preflight with h3 v1 since 2.7.0](https://github.com/Baroshem/nuxt-security/issues/770)
  - Integrate the h3 preflight boolean/Response distinction and verify response/error hooks.
- [PR #769: fix: run the server runtime on Nitro v3 without Nuxt 5's compatibility layer](https://github.com/Baroshem/nuxt-security/pull/769)
  - Review independently: matrix Nitro 2/3, h3 1/2, SSR/SSG, CSRF/body handling and disabled auto-imports.
- [PR #768: docs(csrf): align ModuleOptions with nuxt-csurf](https://github.com/Baroshem/nuxt-security/pull/768)
  - Align CSRF docs with installed nuxt-csurf options and add typed examples.
- [Issue #767: `xssValidator` crashes every request with `escapeHtml is not a function` since xss@1.0.16](https://github.com/Baroshem/nuxt-security/issues/767)
  - Already addressed in main; verify resolved xss and escapeHtml=false behavior.
- [Issue #760: CSP Nonce breaks on inline styles with tailwind classes](https://github.com/Baroshem/nuxt-security/issues/760)
  - Use a tag scanner that skips raw text, comments and quoted attribute values; test Tailwind escaped quotes.
- [PR #759: fix(sri): re-hash public assets after modules have populated them](https://github.com/Baroshem/nuxt-security/pull/759)
  - Overlaps #756; a rollup hook alone cannot guarantee later modules have finished.
- [Issue #757: Nonce not injected on bodyAppend scripts when experimental.ssrStreaming is enabled](https://github.com/Baroshem/nuxt-security/issues/757)
  - Create an SSR streaming fixture and check bodyAppend config/hydration nonces against CSP; use the supported streaming hook.
- [PR #756: fix: hash finalized public assets for SRI](https://github.com/Baroshem/nuxt-security/pull/756)
  - Hash lazily after public assets are finalized; compare generated integrity to actual served bytes.
- [PR #755: chore(deps): bump js-yaml from 4.1.0 to 4.3.1 in /docs](https://github.com/Baroshem/nuxt-security/pull/755)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [PR #754: chore(deps): bump @nuxt/devtools from 3.1.0 to 3.4.1](https://github.com/Baroshem/nuxt-security/pull/754)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #753: chore(deps-dev): bump @nuxt/devtools from 1.6.0 to 3.3.1 in /docs](https://github.com/Baroshem/nuxt-security/pull/753)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [PR #752: chore(deps-dev): bump nuxt from 3.14.1592 to 3.21.10 in /docs](https://github.com/Baroshem/nuxt-security/pull/752)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [PR #751: chore(deps-dev): bump nuxt from 4.2.1 to 4.5.1](https://github.com/Baroshem/nuxt-security/pull/751)
  - Use stable Nuxt 4.6.4 with aligned kit/schema and a refreshed lockfile.
- [PR #749: chore(deps): bump socket.io-parser from 4.2.4 to 4.2.7 in /docs](https://github.com/Baroshem/nuxt-security/pull/749)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [PR #748: chore(deps): bump postcss from 8.5.6 to 8.5.25](https://github.com/Baroshem/nuxt-security/pull/748)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #747: chore(deps): bump postcss from 8.4.49 to 8.5.25 in /docs](https://github.com/Baroshem/nuxt-security/pull/747)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [PR #746: chore(deps): bump seroval from 1.3.2 to 1.5.6](https://github.com/Baroshem/nuxt-security/pull/746)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #745: chore(deps): bump tar from 7.4.3 to 7.5.22](https://github.com/Baroshem/nuxt-security/pull/745)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #744: chore(deps): bump shell-quote from 1.8.3 to 1.10.0](https://github.com/Baroshem/nuxt-security/pull/744)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #743: chore(deps): bump svgo from 3.3.2 to 3.3.4 in /docs](https://github.com/Baroshem/nuxt-security/pull/743)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [PR #742: chore(deps): bump svgo from 4.0.0 to 4.0.2](https://github.com/Baroshem/nuxt-security/pull/742)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #740: Don't add preload links to CSP](https://github.com/Baroshem/nuxt-security/pull/740)
  - Avoid unnecessary preload hashes while verifying executable scripts/styles remain allowed.
- [PR #739: chore(deps): bump shell-quote from 1.8.1 to 1.10.0 in /docs](https://github.com/Baroshem/nuxt-security/pull/739)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [PR #738: refactor(cspSsrNonce): refactor html injection](https://github.com/Baroshem/nuxt-security/pull/738)
  - Overlaps #776; do not stack the quote-placeholder implementation.
- [Issue #737: [Vite 8] Both esbuild and oxc options were set](https://github.com/Baroshem/nuxt-security/issues/737)
  - Use Vite 8 Rolldown/Oxc compression; retain Vite 7 esbuild and terser tests.
- [PR #736: Fix/xss rich text and statusmessage bypass](https://github.com/Baroshem/nuxt-security/pull/736)
  - Do not merge the custom URL detector blindly: its callback/URL handling needs adversarial tests. Use the existing sanitizer semantics.
- [PR #734: chore(deps): bump @babel/core from 7.28.0 to 7.29.7](https://github.com/Baroshem/nuxt-security/pull/734)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #733: chore(deps): bump @babel/core from 7.26.0 to 7.29.7 in /docs](https://github.com/Baroshem/nuxt-security/pull/733)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [Issue #732: nuxt-security overwrites user routeRules['/__nuxt_hints/**'] instead of merging](https://github.com/Baroshem/nuxt-security/issues/732)
  - Merge hints route rules without losing csurf, robots, explicit false or custom security settings.
- [PR #728: chore(deps): bump launch-editor from 2.12.0 to 2.14.1](https://github.com/Baroshem/nuxt-security/pull/728)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #727: chore(deps): bump launch-editor from 2.9.1 to 2.14.1 in /docs](https://github.com/Baroshem/nuxt-security/pull/727)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [PR #726: chore(deps): bump vite from 7.2.2 to 7.3.5](https://github.com/Baroshem/nuxt-security/pull/726)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #721: chore(deps-dev): bump vitest from 4.0.8 to 4.1.0](https://github.com/Baroshem/nuxt-security/pull/721)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [Issue #720: XSS validator returns 400 for valid rich-text JSON payload in POST body](https://github.com/Baroshem/nuxt-security/issues/720)
  - Inspect original string values/keys instead of JSON-escaped strings; test allowed rich text, encoded attacks and downstream body reads.
- [Issue #718: Simultaneous Content-Security-Policy and Content-Security-Policy-Report-Only Headers](https://github.com/Baroshem/nuxt-security/issues/718)
  - Design separate enforced/report-only policy typing, serialization, nonce/hash handling and legacy flag precedence.
- [PR #715: chore(deps): bump devalue from 5.5.0 to 5.8.1](https://github.com/Baroshem/nuxt-security/pull/715)
  - Refresh compatible dependency ranges and audit the resolved graph. Verify the relevant patched versions and run regressions; do not assume a newer Nuxt removes every advisory.
- [PR #714: chore(deps): bump devalue from 5.1.1 to 5.8.1 in /docs](https://github.com/Baroshem/nuxt-security/pull/714)
  - Update the separate docs dependency graph with its Nuxt/Content/UI migration; audit and build docs, then verify search and navigation in a browser.
- [Issue #681: When installing with bunx incompatible version is detected](https://github.com/Baroshem/nuxt-security/issues/681)
  - Already addressed in main exports; verify packed-package imports, and validate Bun separately.
- [Issue #680: Rate limiter calls useStorage() at module top-level and crashes during prerender](https://github.com/Baroshem/nuxt-security/issues/680)
  - Remove top-level Nitro storage/config access and test import lifecycle plus prerender builds.
- [Issue #678: nuxt-security middleware blocks _payload.json-isr requests on ISR routes, causing 404 errors](https://github.com/Baroshem/nuxt-security/issues/678)
  - Reproduce ISR payload requests and inspect Vercel output before assigning the 404 to middleware.
- [Issue #677: security headers not consistently applied (CSP/Permissions/COOP+COEP+CORP) + unexpected `Access-Control-Allow-Origin: *` during `nuxi preview`](https://github.com/Baroshem/nuxt-security/issues/677)
  - Split into SSR, prerender, static-asset and Origin/no-Origin CORS regressions.
- [Issue #668: Nuxt app hangs after build when using PGlite multi-tab worker with nuxt-security](https://github.com/Baroshem/nuxt-security/issues/668)
  - Reproduce PGlite multi-tab workers in a production browser; inspect worker/connect CSP and cross-origin isolation.
- [Issue #666: Sandbox/iframe issues with Turnstile](https://github.com/Baroshem/nuxt-security/issues/666)
  - No public reproduction/config: provide scoped Turnstile guidance and require a minimal public reproduction for validation.
- [Issue #665: Support for Mixed SSG and SSR Mode with Dynamic Nonce Handling in nuxt-security](https://github.com/Baroshem/nuxt-security/issues/665)
  - Keep static hashes and per-request SSR nonces separate; design dynamic static-response rewriting without nonce cache reuse.
- [Issue #657: SRI compatibility with Nuxt 4 entryImportMap - integrity hash mismatch on dynamic imports](https://github.com/Baroshem/nuxt-security/issues/657)
  - Already addressed on main; rerun the entryImportMap/served-asset digest fixture on current Nuxt.
- [Issue #655: SRI applied incorrectly to <link rel="preload|modulepreload">](https://github.com/Baroshem/nuxt-security/issues/655)
  - Distinguish supported SRI destinations from prefetch/unsupported links with positive and negative browser cases.
- [Issue #646: Exposed Network](https://github.com/Baroshem/nuxt-security/issues/646)
  - Test LAN host/HMR URLs and document development-only configuration.
- [Issue #633: 🔐 Feature Request: Per-Extension Configuration for Nuxt-Security](https://github.com/Baroshem/nuxt-security/issues/633)
  - Design extension precedence, case/query/encoding rules and static export; test public SVG responses.
- [Issue #632: runtime config usage might break on cloudflare](https://github.com/Baroshem/nuxt-security/issues/632)
  - Pass event for request-specific config; separately verify singleton/cold-start behavior with a Cloudflare fixture.
- [Issue #631: excludedUrls is mentioned in docs but not available in csrf options](https://github.com/Baroshem/nuxt-security/issues/631)
  - Remove unsupported excludedUrls; document routeRules.csurf=false.
- [Issue #627: How to pass env variables into `contentSecurityPolicy`](https://github.com/Baroshem/nuxt-security/issues/627)
  - Document private runtimeConfig plus server hooks and verify runtime overrides rather than build-time environment substitution.
- [PR #622: Issue-618: SSG build fails if cdnUrl is relative path](https://github.com/Baroshem/nuxt-security/pull/622)
  - Adopt URL behavior only, without unrelated whitespace churn; add a regression.
- [Issue #618: SSG build fails if cdnUrl is relative path](https://github.com/Baroshem/nuxt-security/issues/618)
  - Handle relative CDN URLs and test ./, /cdn/, HTTPS and baseURL.
- [Issue #613: Nuxt-Security module reads body in middleware and trpc/any other libraries cannot read the body for input validation](https://github.com/Baroshem/nuxt-security/issues/613)
  - Add a downstream body-reader fixture; h3 readBody coverage alone does not prove raw-stream consumers work.
- [PR #611: Fix(nonce): correctly detect valid script elements](https://github.com/Baroshem/nuxt-security/pull/611)
  - Superseded by scanner tag-name, attribute and comment boundary tests.
- [Issue #602: Invalid script-src 'nonce-{{nonce}}' on redirect response](https://github.com/Baroshem/nuxt-security/issues/602)
  - Resolve nonce placeholders on redirects/API responses; test raw 3xx and JSON responses.
- [Issue #583: useCsrfFetch is not working after running "npm run build" in production](https://github.com/Baroshem/nuxt-security/issues/583)
  - Upgrade the supplied production reproduction and compare SSR/client CSRF fetch, cookies and forwarded headers.
- [Issue #575: X-Content-Type-Options nosniff duplicated ?](https://github.com/Baroshem/nuxt-security/issues/575)
  - Test Cloudflare wildcard/specific header merging for duplicate output.
- [Issue #527: NuxtLink Support with custom route rules](https://github.com/Baroshem/nuxt-security/issues/527)
  - Document that SPA navigation does not replace document CSP; test a full-navigation strategy in a browser.
- [Issue #515: Setting `corsHandler.origin` issues](https://github.com/Baroshem/nuxt-security/issues/515)
  - Share origin positive/negative, array/regex and no-Origin tests with #505.
- [Issue #505: The corsHandler is not reflected. Defaults take preference.](https://github.com/Baroshem/nuxt-security/issues/505)
  - Test HTML/API/static header scope separately from CORS and clarify defaults.
- [Issue #504: Too many header rules - Cloudflare Pages](https://github.com/Baroshem/nuxt-security/issues/504)
  - Design shared header grouping without dropping page-specific CSP hashes to evade platform limits.
- [Issue #443: Support enabling/disabling basic auth at runtime](https://github.com/Baroshem/nuxt-security/issues/443)
  - Register middleware independently of the build-time enabled flag, then test runtime toggling with one build.
- [Issue #295: Integration with Nuxt DevTools](https://github.com/Baroshem/nuxt-security/issues/295)
  - Expose only redacted DevTools summaries and verify no password/secret reaches serialized payloads.
- [Issue #260: The server route are not protected by basicAuth](https://github.com/Baroshem/nuxt-security/issues/260)
  - Rerun existing API auth regressions and add include/exclude URL-boundary coverage.
- [Issue #196: Spoofing IP to get around rate limiter is possible](https://github.com/Baroshem/nuxt-security/issues/196)
  - Ignore forwarded IP headers by default; document explicit trusted-proxy opt-in and test spoofed headers.

## Additional source findings

- P1: rate-limit storage remains read/modify/write rather than an atomic operation across workers or instances. Design an atomic consume contract and concurrent tests; sequential passing tests are not a distributed-rate-limit guarantee.
- P1: request size enforcement relies on Content-Length and omits PATCH. Design a byte-counting gate together with raw-stream compatibility, then test absent/invalid lengths, chunked bodies, the exact limit and PATCH.
- P2: CI uses mutable action references such as checkout@master. Update/pin action provenance separately. This change adds Node 24/26, frozen lockfiles, the missing cache id and an audit gate.
- Builds warn about an unresolved cache-driver.mjs. Current tests do not establish caching/ISR execution; investigate with #678.

See [validation](./validation.md) for implemented changes, evidence and remaining work.
