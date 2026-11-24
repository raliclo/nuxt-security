# 驗證證據與實作範圍

日期：2026-11-23（Asia/Taipei）。上游基準 `d074467`；本機 Windows、Node 26.13.1、Yarn 1.22.22。

## 已實作與回歸涵蓋

- #770／#771：h3 v1 preflight 回應不再回傳 boolean；測 OPTIONS、origin、空 body 與 Nitro error hook。
- #772／#773／#680：首次請求扣 token、0 token 立即拒絕、到期重置與 reset headers；storage／config 改在 request-time 取得。單元測試確認 import 階段無存取 Nitro。
- #774／#777：literal wildcard 基底與子路徑使用相同 counter；涵蓋 query、trailing slash、exact-rule 優先序與無關路徑。
- #196：預設不信任 forwarded IP；新增 trustProxy 選項、偽造 header 的 HTTP regression 與部署說明。這是行為變更，代理部署需依文件明確啟用或設定可信 ipHeader。
- #760／#776（取代重疊 #738／#611）：nonce tag scanner；涵蓋 Tailwind CSS 引號、attributes、comments、raw text、完整 tag name、existing nonce 各種引號與重複屬性。
- #775：空 renderer 不覆寫已保存的 prerender headers；單元測試同時檢查陣列正規化與內部標頭移除。未執行外部 sitemap zeroRuntime 重現專案或 Vercel 部署。
- #756（與 #759 重疊）、#618／#622：延後計算 SRI，測 late public assets 的最終 bytes 及 relative／absolute CDN URL。
- #732：保留 hints route rule 的 csurf、robots、security 與 false 設定。
- #737：Vite 8 使用 Rolldown／Oxc compression；設定測試涵蓋 Vite 7 fallback 及 terser。
- #720／#736：以原始字串值與 key 做 XSS 檢查；合法富文字、巢狀攻擊、編碼 URL、statusMessage bypass、下游 h3 readBody 保留原始輸入均有測試。沒有採用 PR 的自製 URL detector。
- #768／#631：CSRF 文件 options 對齊 nuxt-csurf 1.6.6；未將原有不存在的 excludedUrls 描述為可用選項。
- 額外相容性：修復 Windows filesystem driver 無法使用含 wildcard 的 storage key，以及新版 Nitro 對舊格式 false／object headers 的字串化；保留 explicit false 的完整 CSP 合併語意。
- 原有 #657／#681／#767 測試也已在最新版環境重跑。SSG／SRI／nonce 測試改驗證實際元素與資產 bytes，避免只鎖定 Nuxt 輸出標籤數。

## 回歸測試的反證

暫時以 `git show HEAD:<path>` 還原原始 rateLimiter 與 context，再執行：

```sh
yarn vitest run test/rateLimiter.unit.test.ts test/securityRoute.test.ts
```

原始程式 exit 1：9 個案例中 6 個失敗，涵蓋 top-level Nitro 存取、首次／到期限流、0 token 與 wildcard base／query／trailing slash。執行後立即還原修補；修補版本全部通過。

## 最新依賴驗證

實際解析：Nuxt／kit／schema 4.6.4、Nitro 2.13.6、h3 1.15.11、Vite 8.3.8、Vitest 4.1.12、test-utils 3.23.0、Vue 3.5.46、defu 6.1.7。

- `yarn upgrade --non-interactive` 與 `yarn install --non-interactive`：exit 0；補齊顯式 peer dependencies。
- 三條 scoped minimatch resolutions 將 typescript-estree、eslint-plugin-import-x、readdir-glob 的有公告版本更新到 11.x，避免破壞仍使用舊 callable API 的其他依賴。
- `yarn audit --json`：exit 0，根目錄 lockfile graph 各 severity 均零公告。這是當日掃描快照，未涵蓋 docs 的獨立 lockfile。
- `yarn dev:prepare`：exit 0。
- `yarn lint`：exit 0、無警告。
- `yarn test --maxWorkers=2`：exit 0；25 個測試檔、228 個案例通過、1 個原有 island nonce 案例略過。
- CI 補 Node 24／26 矩陣、frozen lockfile、cache step id、moderate 以上 audit gate 與最多 2 workers。GitHub Actions 尚未執行，不能把本機 Node 26 結果當作 Node 24／Linux CI 已通過。

## 前輪尚未完成的範圍（歷史紀錄）

以下是前輪留下的範圍；已由下方「後續修復驗證」更新，不能視為目前全部仍未實作。完整來源索引見 [upstream-plan.md](./upstream-plan.md)。

- 文件網站仍是獨立的 Nuxt 3／Content 2／舊 UI Pro stack；未改動它的 package.json／lockfile，尚待整體遷移與 audit。
- Nitro 3 adapter、SSR streaming、同時 enforced/report-only CSP、runtime Basic Auth、extension rules、DevTools 與動態改寫 SSG nonce 尚待實作／驗證。
- Cloudflare／Vercel／ISR、Bun、瀏覽器、Turnstile／PGlite／外部 CSRF reproduction 未執行。
- 本機仍看到 Nuxt cache-driver.mjs unresolved build warning 與 playground package type warning；目前測試通過不證明 caching／ISR 路徑可用。
- 限流跨 worker 原子性、request size 的 chunked／PATCH bytes gate 是已記錄的後續原始碼工作；本輪沒有宣稱提供這些保證。

## 套件建置與差異檢查

`yarn prepack` 在最終依賴下 exit 0；`git diff --check` 通過。建置產物留在被忽略的 `dist/`，未提交產物或測試日誌。

## 後續修復驗證 — 2026-11-23

- 文件站遷移至 Nuxt 4.6.4、Content 3.17.0、UI 4.13.0；改用 server Content API，瀏覽器切換頁面不再因 SQLite WASM 需要 unsafe-eval 而空白。真實 Edge 測安裝頁、導航到限流頁及搜尋 API。
- 原生 Nitro 3 adapter 已實作；獨立 fixture 固定 Nuxt 5x nightly `5.0.0-2611222336-0ed8910`、Nitro `3.0.261103-rc`、h3 `2.0.8`。關閉 Nitro auto-import compatibility，CSRF server imports／middleware 註冊轉為原生 adapter；測 SSR streaming nonce、SSG hashes、下游 body、XSS、缺 token 拒絕與合法 cookie/token，以及 route exemption。
- SSR streaming 的 bootstrap／hydration nonce 已補齊；原本略過的 island 測試已啟用並修復。父 nonce 僅從程序內 localFetch context 繼承，不讀取 HTTP nonce header；平行頁面 nonce 隔離有回歸測試。
- 同時 enforced／report-only CSP、runtime Basic Auth、request-specific runtime overrides、副檔名 headers、development-only redacted inspector、server-backed SSG dynamicNonce 均已補實作與回歸測試。
- 限流以程序內 lock 序列化 storage；Redis Lua 提供跨程序原子扣額度、server time／TTL。真實 Redis 在 localhost:16381，由兩個 OS process 各送 50 次請求，總放行數精確為 10；另測到期與 0 token。壞 counter 與 Redis 故障採 fail closed。一般 storage driver 不提供分散式保證。
- request size 改以實際 bytes gate 檢查 POST／PUT／PATCH／DELETE，測等於上限、超限、Unicode、缺少 Content-Length、chunked PATCH 與 raw Node reader replay。h3 v2 使用有界 clone 保留下游 body。
- SSG HTML headers 不再被同路徑 payload JSON 覆寫；不匯出 prerender 內部的 permissive CORS header。Windows cache driver 的 file URL 改以 build alias 解析，保留 Node runtime 的合法 file URL。
- Vercel 產物測 HTML CSP hashes、content type、移除 X-Powered-By 與 ISR payload 設定；Cloudflare 以 Miniflare/workerd 測 SSR nonce，另驗 static headers。Cloudflare 重疊規則先 detach 再 set；超過平台上限時明確拒絕建置。Bun 1.4.4 實際啟動 fixture，測 SSR nonce 與 SSG hashes。
- `yarn lint`、`yarn dev:prepare`、`yarn prepack` 均 exit 0。最新完整 `yarn test --maxWorkers=2`：33 files、256 tests 全部通過，無 skip。dist consumer 的 Vercel／Cloudflare／Bun／Nitro 3 建置成功；最終相容性 runtime／瀏覽器／Redis／schema 測試 7 files、12 tests 通過。
- CI actions 改用已查核的 commit SHA；增加獨立 docs／Nitro 3 lockfile 安裝、Redis service、Bun、Playwright 與 dist consumer 建置。後續 Linux 結果見下方 2026-11-24 紀錄。

設定與重跑步驟：[compatibility.md](./compatibility.md)。npm 發布計畫：[release-plan.md](./release-plan.md)。

## 外部驗收限制

使用者已確認目前沒有 Vercel／Cloudflare 測試專案及 Turnstile／PGlite reproduction，因此未執行真實雲端部署或聲稱這些外部問題已結案。外部 proxy ingress、CDN／ISR 更新、cookie／CSRF、Turnstile iframe 與 PGlite multi-tab worker 仍需對應目標及最小重現。沒有執行 npm publish。

## npm audit 與依賴修復

依使用者追加要求，分別建立暫時 npm lock、執行 `npm audit --json`，並以 `npm update --package-lock-only --ignore-scripts --legacy-peer-deps` 重新解算修補約束。這不安裝或改寫 node_modules；暫時 lock 已刪除，repo 仍只提交 Yarn lockfiles。npm 與 Yarn 的依賴圖可能不同，因此兩者分別掃描。

- npm 首次 metadata：root 19、docs 11、Nitro 3 fixture 0 個被標記套件（包含傳遞影響，並非 30 個不同 CVE）。npm 不採用 Yarn resolutions，因此加入相同範圍的 npm overrides。
- 修補 minimatch（只覆寫已驗證的 typescript-estree、eslint-plugin-import-x、readdir-glob）、Miniflare 的 undici／sharp；不全域覆寫仍需舊 callable API 的 minimatch。
- docs 明確改用 Zod 4.6.7 的 collection schema adapter，同步 resolution／override，清除 Content 傳遞的 Zod 3 high advisory。沒有改用 zod/v3 alias。額外反證：相同 1000 元素的超限集合，Zod 4 讀取 0 個元素、產生 1 個錯誤；legacy v3 讀取 1000 個、產生 1001 個錯誤。
- 最終 npm audit 三個專案皆 exit 0、各 severity 皆 0；三份 Yarn graph audit 也皆 exit 0、0 公告。這是當日 registry 快照，不是未來安全保證。
- Zod 4 migration 後 docs build exit 0，最終 Edge navigation/search 與 oversized-schema regression 均通過；CI 為 docs／Nitro 3 增加獨立 moderate 以上 audit gate。

## Dependabot

已透過 GitHub API 啟用 fork 的 vulnerability alerts 與 automated security fixes；GET 驗證 alerts HTTP 204、security fixes enabled=true／paused=false。每週一台北時間 09:00 的 npm/Yarn 與 GitHub Actions 設定已實際寫入預設分支：[設定 commit](https://github.com/raliclo/nuxt-security/commit/bf4d1afc1272381c9f56df3a67acd93a505f5517)。directories 包含 root、docs 與 compat wildcard；相容的 minor/patch 更新及 security updates 分組，未設定自動合併。安全警示以預設分支為準，本修復分支尚未合併前，main 的舊依賴仍可能出現警示。

## Linux CI 驗收 — 2026-11-24

乾淨 checkout 的 compatibility job 原先因未產生 `.nuxt/tsconfig.json` 而在 prepack 失敗；commit `c5ddc99` 補上 `yarn dev:prepare`。重跑的 [GitHub Actions](https://github.com/raliclo/nuxt-security/actions/runs/45304207919) 全部成功：Linux／Node 24、Node 26 主測試各 33 files／256 tests；compatibility 7 files／12 tests。三份依賴圖 audit 都為 0，prepare、lint、package 與所有相容性 fixture 建置均完成。這補足 Linux／Node LTS 的實際執行證據，仍不代表真實雲端部署已驗收。
