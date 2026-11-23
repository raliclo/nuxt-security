# 相容性與部署驗收

英文：[compatibility.en.md](./compatibility.en.md)。此檔說明本分支新增功能與可重跑的驗證；測試結果以 validation.md 為準。

## 分散式限流

預設 storage 透過程序內佇列序列化；多 worker／多 instance 必須使用共用 Redis，不能把一般 storage driver 當成原子操作。

```ts
export default defineNuxtConfig({
  security: {
    rateLimiter: {
      tokensPerInterval: 100,
      interval: 60000,
      redis: { url: process.env.REDIS_URL!, prefix: 'my-app:rate:' },
      trustProxy: false,
    },
  },
})
```

Redis 必須在建置時啟用，部署時可透過 private runtimeConfig 覆寫連線資訊。URL 不可放在 public runtimeConfig。原子 Lua 操作使用 Redis 時鐘、扣額度及 TTL；無法連線時回覆 503。各 instance 應使用相同設定與 prefix；不同應用應使用不同 prefix。TCP Redis 不適用所有 edge runtime；Cloudflare 的 worker 測試未啟用 Redis。

`trustProxy` 仍預設 false；只有在入口代理會清除／重寫 forwarded headers，且應用無法繞過代理直接連入時才啟用。明確的 `ipHeader` 也需要同等的入口限制。

## CSP、streaming 與 SSG

- `security.headers.contentSecurityPolicyReportOnly` 可與 `contentSecurityPolicy` 同時使用；各自保留不同 directives。舊的頂層 `contentSecurityPolicyReportOnly: true` 仍表示將 enforced policy 移至 report-only；明確 report-only policy 優先。
- `security.ssg.dynamicNonce: true` 將預渲染 HTML 留在 server assets，由 middleware 每次產生 nonce，並回覆 `private, no-store`；HTML 不輸出至公開靜態目錄。需保留 server runtime，不能部署成純靜態網站；不要在 CDN 強制快取 HTML。`nonce: false` 的路由交由正常 renderer 處理。
- SSR streaming 的 bootstrap／hydration script 共用請求 nonce；SSG 仍使用 hashes。SSG payload 不得覆寫同一路徑的 HTML headers。
- `security.byFileExtension: { '.svg': { headers: { contentSecurityPolicy: { 'default-src': ["'none'"] } } } }` 提供副檔名預設；明確 route rule 優先，並保留 false。
- Cloudflare `_headers` 會先輸出廣泛規則，再以 detach／set 覆寫；超過 100 rules 或單行 2000 字元時建置失敗，避免平台靜默忽略。可減少預渲染路由或使用具 server runtime 的 dynamicNonce。[平台規則](https://developers.cloudflare.com/pages/configuration/headers/)

## 文件站與 DevTools

文件站使用 Nuxt 4／Content 3／UI 4 與 server SQLite API；頁面切換不需要放寬 CSP 允許 WASM。root 與 docs 的 lockfile 分開安裝。`/__nuxt_security` 與 DevTools tab 僅在 development 提供功能名稱、是否啟用、路由及 header 名稱；不輸出設定值。可用 `security.devtools: false` 關閉。

Content collection 明確使用 Zod 4 schema adapter；docs 的 Zod resolution 與 npm override 對齊至 4.6.7 以上，不能改回 Content 的 legacy v3 schema export。測試會檢查超過 `.max()` 的大型集合不走訪元素，避免回歸為逐項累積錯誤的 DoS。

## 執行驗證

Node 24 以上、Yarn 1、Bun 1.4.4、localhost:16381 的 Redis，以及 Playwright browser 為完整相容性測試前置需求。Windows 使用已安裝 Edge；Linux 執行 `yarn playwright install --with-deps chromium`。

```sh
yarn install --frozen-lockfile --non-interactive
yarn --cwd docs install --frozen-lockfile --non-interactive
yarn --cwd compat/nitro3 install --frozen-lockfile --non-interactive
yarn dev:prepare
yarn lint
yarn test --maxWorkers=2
yarn prepack
NUXT_SECURITY_DIST=1 yarn --cwd compat/nitro3 build
yarn --cwd docs build
node compat/clean-deployments.mjs
NUXT_SECURITY_DIST=1 yarn nuxi build compat/deployments --preset vercel
NUXT_SECURITY_DIST=1 yarn nuxi build compat/deployments --preset cloudflare-module
NUXT_SECURITY_DIST=1 NUXT_SECURITY_OUTPUT=.output-bun yarn nuxi build compat/deployments --preset bun
yarn test:compat
```

切換 preset 前應從乾淨的 fixture 產物開始：舊 `.output/public` 可能被下一個 preset 當成公開資產。只清除 `compat/deployments` 內的生成目錄，不刪除 source／public。CI 從乾淨 checkout 依上述順序建置。相容性 fixture 可用 `NUXT_SECURITY_DIST=1` 驗證實際 dist，避免只有 source 能建置。

Nitro 3 fixture 固定 Nuxt nightly 5x 與 Nitro RC，關閉 Nitro auto-import compatibility；這不是 Nuxt 4 預設 Nitro 2 環境，也不是正式 Nuxt 5 發行宣告。CSRF 的 server 副本由已安裝 nuxt-csurf 產生，僅替換 server imports 與 handler 註冊，仍使用原套件 token/cookie 驗證。

真實雲端、Turnstile 與 PGlite reproduction 仍需測試專案／最小重現。使用者目前尚無這些專案；本機 workerd、Vercel artifact 與 Bun 測試不能代替雲端驗收。
