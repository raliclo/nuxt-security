# CLAUDE.md — nuxt-security
Rules for this repository. The user's global `~/.claude/CLAUDE.md` still applies;
nothing here contradicts it.

## Project: nuxt-security

This repository implements a Nuxt security module and its test/docs applications.
It provides HTTP security headers, CSP nonces and SSG hashes, SRI, and request
middleware for CORS, rate limiting, request sizes, XSS, Basic Auth, and CSRF.

Read `AGENTS.md` for the shared shell, csv2, security, regression-test, and
validation policies. Keep the policies consistent instead of maintaining a
second divergent checklist here.

- `src/module.ts`: Nuxt setup, config merging, build hooks and generated types.
- `src/runtime/`: Nitro plugins, middleware and composables.
- `src/utils/`, `src/types/`: shared helpers and public option types.
- `test/` and `test/fixtures/`: unit and production fixture regression tests.
- `playground/`: manual integration app; `docs/`: separately installed docs site.

Use the latest stable Nuxt for fixes and record actual resolved versions.
Add a failing-before/passing-after regression for each behavioral fix. Preserve
secure defaults, user route rules, and explicit false options. Never expose
secrets in public config, logs, generated HTML, or DevTools. Do not claim fixes
for untested platforms or external deployments.

使用繁體中文回覆。每項修復加入回歸測試，記錄上游 issue／PR 對照，並清楚區分
已驗證、僅原始碼檢查與尚待重現的項目。完整共用規範見 `AGENTS.md`。
