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

## Remaining work and limits

This does not close all 73 open items. See the [item-by-item plan](./upstream-plan.en.md).
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
