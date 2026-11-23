## Project Shell And Test App Policy

- Use zsh for project commands, scripts, builds, tests, and temporary automation.

## Local csv2 Policy

- Prefer `csv2` for structured edits to `.csv`, `.csv2`, and Markdown tables when the change can be expressed as record/field operations.
- For Markdown tables, use the verified two-step workflow: edit into `.csv` or `.csv2`, then render back with `csv2 -r -t -md`. The current binary refuses direct edit-to-`.md` output.
- For source files, `csv2` may be used as a line-list inspection tool or for deliberately line-addressed edits. Do not treat it as a syntax-aware TypeScript/Vue editor; use normal source editing tools for structural code changes.
- Remember that `-contains` searches every column and is not column-scoped. Use `--json` plus a column-aware pass when column identity matters.


## 專案定位 / Project Scope

- 本專案為 `nuxt-security`：以 Nuxt module 整合安全 HTTP headers、CSP nonce／SSG hashes、Subresource Integrity，以及 CORS、限流、request size、XSS、Basic Auth 與 CSRF 防護。
- This repository contains the `nuxt-security` Nuxt module, its Nitro runtime, regression fixtures, playground, and documentation site.
- `src/module.ts` 負責 Nuxt 註冊、設定合併、型別範本與建置 hooks；`src/runtime/` 處理請求／回應；`src/utils/` 與 `src/types/` 放共用工具與公開型別。
- `test/*.test.ts` 與 `test/fixtures/` 是回歸測試；`playground/` 用於手動驗證；`docs/` 是獨立的文件網站，有自己的依賴與 lockfile。

## 修復與安全規則 / Fixes And Security Rules

- 先檢查 git status、分支、remotes 與既有變更。保留使用者變更；只修改與要求相關的範圍。
- 使用最新穩定版 Nuxt 驗證，記錄實際 Nuxt／Nitro／h3／Vite 版本；不要把 Nuxt 5 compatibility mode 或 Nitro 3 測試等同於 Nuxt 4 預設環境。
- 對上游 issue／PR 先檢查現有實作與重複修補；維護來源編號、採用方式與驗證證據。未重現、未執行或依賴外部部署的項目必須明示。
- 每項行為修復新增可重現原缺陷的回歸測試；優先使用最小 unit test，跨 hooks、SSR／SSG 或 HTTP 行為則加入 fixture integration test。安全測試同時涵蓋合法輸入與攻擊／邊界輸入。
- 不為通過測試而停用安全預設、擴大 CORS、加入 unsafe CSP 來源或跳過認證。不要在 client、公開 runtimeConfig、日誌或 DevTools 中暴露 Basic Auth 密碼、CSRF secrets 或其他私密設定。
- 設定合併需保留使用者 route rules 與明確的 false 值；nonce 每次 SSR 請求產生，SSG 使用最終 HTML hashes；SRI 必須對應實際送出的資產 bytes。
- Nitro storage／runtime config 避免在 module import 時存取；需要 request-specific 設定時傳入 event。h3 v1／v2、Nitro v2／v3 的差異需各自測試。
- Markdown／結構化資料優先遵循上方 csv2 規則；一般 TypeScript／Vue 結構變更使用正常 source editor。

## 驗證 / Validation

- 安裝：`yarn install --non-interactive`；CI 應使用與 lockfile 一致的安裝。
- 準備：`yarn dev:prepare`；靜態檢查：`yarn lint`；回歸測試：`yarn test`；套件建置：`yarn prepack`。
- 測試可用 `yarn vitest run test/<name>.test.ts` 縮小範圍；整合測試會建置並啟動 fixture，必要時限制 workers，避免資源競爭。
- 根目錄與 docs 的依賴分開驗證。Windows 與 Linux、Node LTS 與部署 preset 的差異不可僅靠一個本機結果推論。
- 回覆使用繁體中文；新增專案說明或長期規範提供英文對照。不要聲稱測試已通過，除非命令確實完成且 exit code 為零。

英文對照：[AGENTS.en.md](./AGENTS.en.md)。
