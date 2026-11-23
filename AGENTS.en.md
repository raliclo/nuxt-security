# Repository guidance: nuxt-security

`nuxt-security` is a Nuxt module providing HTTP security headers, CSP SSR nonces
and SSG hashes, Subresource Integrity, CORS, rate limiting, request size limits,
XSS validation, Basic Auth and CSRF integration.

## Shell and editing

Use zsh for commands, scripts, builds, tests and temporary automation. On this
Windows host explicitly select `C:/Users/lowei/scoop/shims/zsh.exe`. Do not switch
shells silently when tooling fails.

Prefer csv2 for structured CSV/CSV2 and Markdown table edits. For Markdown tables,
edit a CSV/CSV2 intermediate then render with `csv2 -r -t -md`; the current binary
does not support direct edit-to-Markdown output. `-contains` searches all columns;
use JSON and column-aware processing when needed. Use normal source editing tools
for structural TypeScript/Vue changes rather than treating csv2 as a syntax-aware
editor. Inspect status, branches and remotes first and preserve user changes.

## Source layout

- `src/module.ts`: module setup, configuration, build hooks and generated types.
- `src/runtime/`: Nitro request/response plugins, middleware and composables.
- `src/utils/` and `src/types/`: helpers and public option types.
- `test/` and `test/fixtures/`: unit and production fixture regression tests.
- `playground/`: manual integration application.
- `docs/`: independent documentation site with its own dependencies and lockfile.

## Security changes

Use the latest stable Nuxt and record actual Nuxt/Nitro/h3/Vite versions.
Distinguish Nuxt 4 defaults from Nuxt 5 compatibility mode and Nitro 3 tests.
Review upstream issues/PRs against current source, track overlapping fixes and
record evidence. Identify unexecuted tests and external deployment requirements.

Add a regression that reproduces each behavioral defect. Prefer small unit tests;
use fixture integration tests for HTTP, SSR/SSG and hook ordering. Include valid
inputs, attacks and boundary cases. Never weaken CSP, CORS or authentication just
to make a test pass. Never expose credentials or CSRF secrets in clients, public
runtime config, logs or DevTools.

Preserve user route rules and explicit false values. SSR nonces must be fresh per
request; SSG hashes must match finalized HTML; SRI must match served asset bytes.
Avoid Nitro storage/config access at module import time. Pass the request event
when reading request-specific runtime config. Test Nitro 2/3 and h3 1/2 separately.

## Validation and communication

Use `yarn install --non-interactive`, `yarn dev:prepare`, `yarn lint`, `yarn test`
and `yarn prepack`. CI installation must agree with the lockfile. Scope a test run
with `yarn vitest run test/<name>.test.ts`; limit workers when fixture builds
compete for resources. Validate docs dependencies separately. A Windows result
alone does not establish Linux, Node LTS, Bun or deployment-preset compatibility.

Reply in Traditional Chinese and provide English counterparts for new project
guidance. Claim a passing check only after it completes with exit code zero.
The primary policy file is [AGENTS.md](./AGENTS.md).
