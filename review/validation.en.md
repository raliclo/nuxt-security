# Validation evidence and implementation scope

Date: 2026-11-23 (Asia/Taipei). Upstream baseline: d074467. Local environment:
Windows, Node 26.13.1, Yarn 1.22.22.

## Implemented changes

- #770/#771: correct h3 v1 preflight return handling with response/error-hook tests.
- #772/#773/#680: first-request accounting, zero tokens, renewal/reset headers and request-time Nitro storage/config access.
- #774/#777: literal wildcard base/child counters, queries, trailing slashes, exact precedence and unrelated paths.
- #196: ignore forwarded IP by default; explicit trustProxy opt-in, spoof regression and migration documentation.
- #760/#776 (overlapping #738/#611): tag-scanning nonce injection with CSS quotes, comments, raw text, attributes, existing/duplicate nonce and tag-boundary tests.
- #775: an empty renderer does not erase collected headers; persistence/normalization tests. The external sitemap zeroRuntime app and Vercel deployment were not executed.
- #756 (overlapping #759), #618/#622: lazy final-asset SRI hashes and relative/absolute CDN URL regressions.
- #732: preserve user hints route rules and explicit false values.
- #737: Vite 8 Rolldown/Oxc logger configuration, with Vite 7 fallback and terser tests.
- #720/#736: inspect original string values/keys rather than JSON-escaped markup; test permitted rich text, nested/encoded attacks, statusMessage bypass and downstream h3 body access. The PR's custom URL detector was not adopted.
- #768/#631: align CSRF option documentation with nuxt-csurf 1.6.6.
- Also fix Windows filesystem counter keys and current Nitro legacy false/object header normalization. Existing #657/#681/#767 regressions were rerun. Nonce/SRI/SSG assertions inspect actual elements and asset bytes instead of fixed Nuxt tag counts.

## Failing-before evidence

Temporarily restore the baseline rateLimiter/context files with git show, run
`yarn vitest run test/rateLimiter.unit.test.ts test/securityRoute.test.ts`, then
restore the patched files. The baseline exits 1 with six failures out of nine
cases: Nitro import lifecycle, first/renewed intervals, zero tokens and wildcard
base/query/trailing-slash routing. The fixed version passes all nine.

## Dependency and check results

Resolved Nuxt/kit/schema 4.6.4, Nitro 2.13.6, h3 1.15.11, Vite 8.3.8, Vitest
4.1.12, test-utils 3.23.0, Vue 3.5.46 and defu 6.1.7.

- Upgrade/install: exit 0, explicit build peer dependencies included.
- Scoped minimatch 11.x resolutions cover typescript-estree, eslint-plugin-import-x and readdir-glob without overriding older callable consumers globally.
- `yarn audit --json`: exit 0, zero advisories in the root lockfile graph on this date. The separate docs lockfile is excluded.
- `yarn dev:prepare`: exit 0.
- `yarn lint`: exit 0, no warnings.
- `yarn test --maxWorkers=2`: exit 0; 25 files, 228 passing tests, one pre-existing island-nonce skip.
- CI adds Node 24/26, frozen lockfiles, the missing cache step id, a moderate-or-higher audit gate and two test workers. GitHub Actions has not run; local Node 26 does not establish Node 24/Linux CI results.

## Previous remaining work (historical)

The following records the previous round and is superseded by the follow-up below. See the [item-by-item source index](./upstream-plan.en.md).
The docs site still uses a separate Nuxt 3/Content 2/old UI Pro stack and has not
been migrated or audited. Nitro 3, streaming, dual CSP policies, runtime Basic
Auth, extension rules, DevTools and dynamic SSG nonce rewriting remain pending.
External Cloudflare/Vercel/ISR, Bun, browsers, Turnstile/PGlite and CSRF repros
were not executed. Builds still warn about an unresolved Nuxt cache driver and
the playground package type. Cross-worker rate-limit atomicity and chunked/PATCH
request-byte enforcement remain recorded source work; no such guarantees are
claimed here.

## Package build and diff check

`yarn prepack` exits 0 with the final dependency graph; `git diff --check` passes.
Generated dist files and test logs are excluded from the commit.

## Follow-up validation — 2026-11-23

- Docs migrated to Nuxt 4.6.4, Content 3.17.0 and UI 4.13.0. A server Content API supports browser navigation without weakening CSP for SQLite WASM. Real Edge tests cover installation, navigation and search.
- Native Nitro 3 has a separate fixture: Nuxt 5x nightly `5.0.0-2611222336-0ed8910`, Nitro `3.0.261103-rc`, h3 `2.0.8`, with auto-import compatibility disabled. CSRF server copies use explicit native imports/registration. Tests cover streaming nonces, static hashes, body preservation, XSS, CSRF rejection/valid token and route exemption.
- Streaming hydration/bootstrap nonces and island inheritance are fixed. The previously skipped island test is enabled; parallel requests remain isolated. Inheritance uses only in-process localFetch context, never a client nonce header.
- Independent enforced/report-only CSP, runtime Basic Auth, per-request runtime overrides, extension headers, a redacted development inspector and server-backed dynamic SSG nonces have regression coverage.
- Local counters are serialized. Real Redis Lua tests use two OS processes issuing 100 requests and admit exactly 10, with server-time expiry and zero-token tests. Corrupt counters and unavailable Redis fail closed. Ordinary storage drivers do not provide distributed atomicity.
- Actual byte limits cover POST/PUT/PATCH/DELETE, exact/oversized bodies, Unicode, missing lengths, chunked PATCH and raw Node replay. h3 v2 uses bounded request clones.
- Prerender payloads cannot overwrite HTML headers; internal permissive CORS headers are not exported. Windows cache drivers retain valid runtime file URLs and use build aliases.
- Vercel artifact tests cover CSP hashes, HTML type, powered-by removal and ISR payload configuration. Cloudflare workerd tests exercise SSR and static exports; overlapping headers detach before setting and unsupported platform limits fail builds. Bun 1.4.4 runs SSR/SSG checks.
- Prepare, lint and prepack exit 0. The latest full root run has 33 files and 256 passing tests, no skips. Dist consumer builds succeed for native Nitro 3, Vercel, Cloudflare and Bun; the final compatibility run passes seven files/12 tests, including the schema regression.
- CI uses verified action commit SHAs and adds independent installs, Redis, Bun, Playwright and dist consumers. Linux/Node 24 results require an actual GitHub Actions run.

Configuration: [compatibility.en.md](./compatibility.en.md). Publishing plan: [release-plan.en.md](./release-plan.en.md).

## External acceptance limits

The user confirmed they do not yet have cloud test projects or Turnstile/PGlite reproductions. No live cloud deployment is claimed. Ingress, CDN/ISR updates, external cookie/CSRF behavior, Turnstile iframes and PGlite multi-tab workers still require targets/reproductions. No npm package was published.

## npm audit and dependency fixes

Temporary npm locks were generated and audited separately, then refreshed with `npm update --package-lock-only --ignore-scripts --legacy-peer-deps` to apply the patched constraints. These commands do not install node_modules. Temporary npm locks were removed; only Yarn locks are committed. npm and Yarn may resolve different graphs, so both were audited.

Initial npm metadata flagged 19 root packages and 11 docs packages, including transitive impact, with zero in the Nitro 3 fixture. npm does not apply Yarn resolutions; equivalent scoped overrides now cover minimatch and Miniflare's undici/sharp without breaking older callable minimatch consumers.

Docs explicitly use Content's Zod 4.6.7 collection-schema adapter, with matching resolution/override and no v3 alias. The constrained-array regression rejects before walking elements: a 1000-element counterexample reads zero elements and creates one issue on Zod 4, versus 1000 reads/1001 issues on legacy v3. The migrated docs build and Edge navigation/search pass.

Final npm audits for all three projects exit 0 with zero findings; all three Yarn audits also exit 0 with zero findings. This is a dated registry snapshot. CI adds independent docs/Nitro 3 audit gates.

## Dependabot

Fork vulnerability alerts and automated security fixes were enabled through GitHub API and verified: alerts HTTP 204, fixes enabled=true/paused=false. The default branch now contains the weekly Monday 09:00 Asia/Taipei npm/Yarn and GitHub Actions configuration: [configuration commit](https://github.com/raliclo/nuxt-security/commit/bf4d1afc1272381c9f56df3a67acd93a505f5517). It covers root, docs and compat wildcards, groups compatible and security updates, and does not enable automatic merging. Alerts track the default branch; its older dependencies may remain flagged until this fixes branch is merged.
