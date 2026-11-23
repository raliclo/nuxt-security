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

## 尚未完成的範圍

本輪不是所有 73 個開放項目的結案。完整逐項修復／驗收設計見 [upstream-plan.md](./upstream-plan.md)。

- 文件網站仍是獨立的 Nuxt 3／Content 2／舊 UI Pro stack；未改動它的 package.json／lockfile，尚待整體遷移與 audit。
- Nitro 3 adapter、SSR streaming、同時 enforced/report-only CSP、runtime Basic Auth、extension rules、DevTools 與動態改寫 SSG nonce 尚待實作／驗證。
- Cloudflare／Vercel／ISR、Bun、瀏覽器、Turnstile／PGlite／外部 CSRF reproduction 未執行。
- 本機仍看到 Nuxt cache-driver.mjs unresolved build warning 與 playground package type warning；目前測試通過不證明 caching／ISR 路徑可用。
- 限流跨 worker 原子性、request size 的 chunked／PATCH bytes gate 是已記錄的後續原始碼工作；本輪沒有宣稱提供這些保證。

## 套件建置與差異檢查

`yarn prepack` 在最終依賴下 exit 0；`git diff --check` 通過。建置產物留在被忽略的 `dist/`，未提交產物或測試日誌。
