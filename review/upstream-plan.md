# 上游問題總體檢視與修復計畫

日期：2026-11-23。來源：Baroshem/nuxt-security，起點 d074467。開放項目快照含 38 issues 與 35 PRs。分支：codex/nuxt-latest-security-fixes；fork：raliclo/nuxt-security。

這是有優先序的修復／驗收計畫；列出項目不代表已完成。原始報告的版本與重現需以目前程式和測試重新確認。主線已修項目、重複 PR、功能要求與部署限制分開判讀。

## 驗收門檻

- 每個修復要有可重現缺陷的測試，合法流量不得遭誤擋；不得靠放寬 CSP／CORS／認證消除錯誤。
- 根目錄以 Nuxt 4.6.4 驗證 lint、prepare、unit／integration、package build；記錄 exit code 和實際依賴版本。
- docs 獨立處理 Nuxt 4、Content 2 與舊 UI Pro 的相容性及兩份 lockfile，未完成前不能宣稱全專案升級完畢。
- Windows 本機通過不等同 Linux、Cloudflare、Vercel、Bun 或 browser streaming 已通過。

## P0 — 請求安全與資料完整性 / Request security

先固定安全語意，再用合法／惡意輸入、首個請求、到期與路徑隔離案例驗證。

- [Issue #770: corsHandler throws ERR_HTTP_HEADERS_SENT on every preflight with h3 v1 since 2.7.0](https://github.com/Baroshem/nuxt-security/issues/770)
  - 採用 #771 的 h3 v1 boolean／v2 Response 分流；測試 OPTIONS 204、空 body、origin 與 Nitro error hook。
- [PR #771: fix(cors): stop returning true from the preflight handler on h3 v1](https://github.com/Baroshem/nuxt-security/pull/771)
  - 與 #770 同一修復，保留回歸 fixture。
- [Issue #772: Rate limiter allows `tokensPerInterval + 1` requests in the first interval](https://github.com/Baroshem/nuxt-security/issues/772)
  - 採用 #773，第一個請求也扣 token；測試 0 token、首次與後續 interval、remaining/reset。
- [PR #773: fix(rateLimiter): count the first request of an interval](https://github.com/Baroshem/nuxt-security/pull/773)
  - 與 #772 同一修復，並將 storage/config 延後到 handler 執行。
- [Issue #774: Rate limiter: a `/path/**` rule sets the limit for `/path` but not its counter, so `/path` shares the global counter and can shrink it](https://github.com/Baroshem/nuxt-security/issues/774)
  - 採用 #777 的 literal wildcard base-path 修復；另測 exact rule、trailing slash、query 與參數路由。
- [PR #777: fix(rateLimiter): count the base path of a wildcard route with its sub-paths](https://github.com/Baroshem/nuxt-security/pull/777)
  - 與 #774 同一修復；不宣稱已涵蓋 param catch-all。
- [Issue #680: Rate limiter calls useStorage() at module top-level and crashes during prerender](https://github.com/Baroshem/nuxt-security/issues/680)
  - 移除 top-level useStorage/useRuntimeConfig；用 prerender build 與 disabled limiter 案例驗證。
- [Issue #732: nuxt-security overwrites user routeRules['/__nuxt_hints/**'] instead of merging](https://github.com/Baroshem/nuxt-security/issues/732)
  - 深層合併 hints 設定並保留 csurf、robots、nonce 與 explicit false；新增 unit regression。
- [Issue #720: XSS validator returns 400 for valid rich-text JSON payload in POST body](https://github.com/Baroshem/nuxt-security/issues/720)
  - 改為遞迴檢查字串值與 key，避免 JSON serialization 誤判；保留 xss sanitizer 的實際安全語意。
- [PR #736: Fix/xss rich text and statusmessage bypass](https://github.com/Baroshem/nuxt-security/pull/736)
  - 不直接採用：其自製 URL regex／callback 覆寫可能漏掉編碼 payload，須先通過 adversarial corpus。
- [Issue #196: Spoofing IP to get around rate limiter is possible](https://github.com/Baroshem/nuxt-security/issues/196)
  - 設計明確 trusted-proxy 選項；測試直連無法以偽造 forwarded header 切換 counter，反向代理部署需明確設定。
- [Issue #613: Nuxt-Security module reads body in middleware and trpc/any other libraries cannot read the body for input validation](https://github.com/Baroshem/nuxt-security/issues/613)
  - 建立下游直接讀取 body 的 fixture；評估 stream clone／cache，不只測 h3 readBody。
- [Issue #443: Support enabling/disabling basic auth at runtime](https://github.com/Baroshem/nuxt-security/issues/443)
  - 常態註冊 middleware，request-time 檢查 enabled；測試同一 build 不同 runtime config。
- [Issue #260: The server route are not protected by basicAuth](https://github.com/Baroshem/nuxt-security/issues/260)
  - 目前已有 API Basic Auth 測試；再驗證 include／exclude 優先序與 URL boundary，不能只看舊版報告。
## P1 — CSP／SSR／SSG／SRI

用最終 HTTP 回應與實際資產 bytes 驗證；不可只計算標籤數量。跨平台部署另列驗證。

- [Issue #775: Prerendered pages lose their security headers when `@nuxtjs/sitemap` runs with `zeroRuntime`](https://github.com/Baroshem/nuxt-security/issues/775)
  - 空 renderer 不寫入 headers.json；測試主 renderer 保存後 auxiliary close，並另驗 sitemap zeroRuntime 的 Node／Vercel 模組順序。
- [Issue #760: CSP Nonce breaks on inline styles with tailwind classes](https://github.com/Baroshem/nuxt-security/issues/760)
  - 採用 #776 tag scanner，跳過 CSS／JS raw text 與 attributes；測試 Tailwind escaped quotes。
- [PR #776: fix(nonce): don't pair up quotes from CSS when injecting the nonce](https://github.com/Baroshem/nuxt-security/pull/776)
  - 優先於 #738／#611；補既有 nonce 單引號、無引號、重複屬性及 fake closing tag 測試。
- [PR #738: refactor(cspSsrNonce): refactor html injection](https://github.com/Baroshem/nuxt-security/pull/738)
  - 與 #776 重疊，不疊加 quote-placeholder 實作。
- [PR #611: Fix(nonce): correctly detect valid script elements](https://github.com/Baroshem/nuxt-security/pull/611)
  - 由 scanner 的完整 tag-name／attribute／comment 測試取代，避免 custom-element 誤配。
- [Issue #757: Nonce not injected on bodyAppend scripts when experimental.ssrStreaming is enabled](https://github.com/Baroshem/nuxt-security/issues/757)
  - 獨立 streaming fixture；驗 bodyAppend hydration/config script 與 CSP nonce 一致，必要時使用 Nuxt 提供的 streaming hook。
- [PR #759: fix(sri): re-hash public assets after modules have populated them](https://github.com/Baroshem/nuxt-security/pull/759)
  - 與 #756 重疊；僅提早 rollup hook 無法保證後註冊模組已完成，優先 lazy virtual module。
- [PR #756: fix: hash finalized public assets for SRI](https://github.com/Baroshem/nuxt-security/pull/756)
  - 採用 lazy SRI hash；以 rollup:before 改寫資產驗證最終 bytes。
- [Issue #657: SRI compatibility with Nuxt 4 entryImportMap - integrity hash mismatch on dynamic imports](https://github.com/Baroshem/nuxt-security/issues/657)
  - 主線已有 entryImportMap 修復與 asset digest fixture；在最新 Nuxt 重跑，不重複套舊 patch。
- [Issue #655: SRI applied incorrectly to <link rel="preload|modulepreload">](https://github.com/Baroshem/nuxt-security/issues/655)
  - 區分支援 SRI 的 script／stylesheet／preload destination 與 prefetch；加入正反例後調整 matcher。
- [PR #740: Don't add preload links to CSP](https://github.com/Baroshem/nuxt-security/pull/740)
  - 避免不必要 preload hash 膨脹；測實際可執行 script／style 被 CSP 允許且沒有無關來源。
- [Issue #618: SSG build fails if cdnUrl is relative path](https://github.com/Baroshem/nuxt-security/issues/618)
  - 處理相對 cdnURL，不能將有效 relative URL 傳給 URL constructor；測 ./、/cdn/、https URL、baseURL。
- [PR #622: Issue-618: SSG build fails if cdnUrl is relative path](https://github.com/Baroshem/nuxt-security/pull/622)
  - 只採 URL 行為修復，不採無關空白變更；補 build regression。
- [Issue #602: Invalid script-src 'nonce-{{nonce}}' on redirect response](https://github.com/Baroshem/nuxt-security/issues/602)
  - redirect／API response 亦需消除 nonce placeholder；新增 3xx raw response 與 JSON fixture。
- [Issue #718: Simultaneous Content-Security-Policy and Content-Security-Policy-Report-Only Headers](https://github.com/Baroshem/nuxt-security/issues/718)
  - 新增獨立 report-only policy 型別／serialization／nonce 與 hash 更新；保留 legacy boolean 優先序並測雙 header。
- [Issue #665: Support for Mixed SSG and SSR Mode with Dynamic Nonce Handling in nuxt-security](https://github.com/Baroshem/nuxt-security/issues/665)
  - SSG hashes／SSR nonce 維持分流；動態改寫靜態 HTML 需避免 CDN 快取 nonce 重用，獨立功能設計。
- [Issue #678: nuxt-security middleware blocks _payload.json-isr requests on ISR routes, causing 404 errors](https://github.com/Baroshem/nuxt-security/issues/678)
  - 建立 ISR payload fixture 與 Vercel output 檢查；不把 404 直接假定是 middleware 阻擋。
- [Issue #677: security headers not consistently applied (CSP/Permissions/COOP+COEP+CORP) + unexpected `Access-Control-Allow-Origin: *` during `nuxi preview`](https://github.com/Baroshem/nuxt-security/issues/677)
  - 拆為 SSR、prerender、static asset 與 CORS origin 測試；明確區分 origin header 有無。
- [Issue #575: X-Content-Type-Options nosniff duplicated ?](https://github.com/Baroshem/nuxt-security/issues/575)
  - 檢查 Cloudflare _headers wildcard／specific 合併，測同一 header 不被重複輸出。
- [Issue #504: Too many header rules - Cloudflare Pages](https://github.com/Baroshem/nuxt-security/issues/504)
  - 評估共用 header 分組與 hashes 的每頁差異；不得為規避供應商限制丟棄不同頁面的 CSP。
## P1 — 最新 Nuxt 與依賴

使用 Nuxt 4.6.4／Nitro 2 的預設環境建立基準；Nitro 3 需獨立矩陣，不直接合併舊 lockfile。

- [Issue #737: [Vite 8] Both esbuild and oxc options were set](https://github.com/Baroshem/nuxt-security/issues/737)
  - Vite 8 使用 rolldownOptions.output.minify.compress；保留舊 Vite／terser 路徑，驗 bundle 中 logger 移除。
- [Issue #681: When installing with bunx incompatible version is detected](https://github.com/Baroshem/nuxt-security/issues/681)
  - 主線已修 package exports；執行 package export regression 與打包後 import，Bun 另列驗證。
- [Issue #767: `xssValidator` crashes every request with `escapeHtml is not a function` since xss@1.0.16](https://github.com/Baroshem/nuxt-security/issues/767)
  - 主線已移除 undefined escapeHtml；測目前解析的 xss 版本與 escapeHtml=false。
- [PR #751: chore(deps-dev): bump nuxt from 4.2.1 to 4.5.1](https://github.com/Baroshem/nuxt-security/pull/751)
  - 由最新穩定 Nuxt 4.6.4 取代舊 4.5.1 bump，同步 kit/schema 與 lockfile。
- [PR #754: chore(deps): bump @nuxt/devtools from 3.1.0 to 3.4.1](https://github.com/Baroshem/nuxt-security/pull/754)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #721: chore(deps-dev): bump vitest from 4.0.8 to 4.1.0](https://github.com/Baroshem/nuxt-security/pull/721)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #726: chore(deps): bump vite from 7.2.2 to 7.3.5](https://github.com/Baroshem/nuxt-security/pull/726)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #715: chore(deps): bump devalue from 5.5.0 to 5.8.1](https://github.com/Baroshem/nuxt-security/pull/715)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #734: chore(deps): bump @babel/core from 7.28.0 to 7.29.7](https://github.com/Baroshem/nuxt-security/pull/734)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #728: chore(deps): bump launch-editor from 2.12.0 to 2.14.1](https://github.com/Baroshem/nuxt-security/pull/728)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #748: chore(deps): bump postcss from 8.5.6 to 8.5.25](https://github.com/Baroshem/nuxt-security/pull/748)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #746: chore(deps): bump seroval from 1.3.2 to 1.5.6](https://github.com/Baroshem/nuxt-security/pull/746)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #745: chore(deps): bump tar from 7.4.3 to 7.5.22](https://github.com/Baroshem/nuxt-security/pull/745)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #744: chore(deps): bump shell-quote from 1.8.3 to 1.10.0](https://github.com/Baroshem/nuxt-security/pull/744)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #742: chore(deps): bump svgo from 4.0.0 to 4.0.2](https://github.com/Baroshem/nuxt-security/pull/742)
  - 以最新 Nuxt 依賴圖重新解算 lockfile，查核修補版本是否仍存在；用 audit 與完整回歸確認，不能僅用新 Nuxt 版本推論漏洞消失。
- [PR #769: fix: run the server runtime on Nitro v3 without Nuxt 5's compatibility layer](https://github.com/Baroshem/nuxt-security/pull/769)
  - 大型 adapter PR，須獨立測 Nitro 2／3、h3 1／2、CSRF/body、SSR／SSG 與 disabled auto-import；不盲目混入 stable 修復。
## P2 — 文件網站與整合

先建立最小重現與文件說明；不為整合案例放寬全站安全預設。docs 升級需同時處理 Content／UI 的主要版本相容性。

- [PR #768: docs(csrf): align ModuleOptions with nuxt-csurf](https://github.com/Baroshem/nuxt-security/pull/768)
  - 已對照已安裝 nuxt-csurf options 修正文檔，另補 config example 型別驗證。
- [Issue #631: excludedUrls is mentioned in docs but not available in csrf options](https://github.com/Baroshem/nuxt-security/issues/631)
  - 由 #768 移除不存在的 excludedUrls；提供 routeRules.csurf=false 範例。
- [Issue #583: useCsrfFetch is not working after running "npm run build" in production](https://github.com/Baroshem/nuxt-security/issues/583)
  - 以使用者提供 production repro 升級 Nuxt；比較 SSR／client useCsrfFetch、cookie secure 與 forwarded headers。
- [Issue #668: Nuxt app hangs after build when using PGlite multi-tab worker with nuxt-security](https://github.com/Baroshem/nuxt-security/issues/668)
  - PGlite multi-tab worker 獨立 production browser fixture，檢查 worker-src／connect-src／COOP／COEP；不擅自全站 allow。
- [Issue #666: Sandbox/iframe issues with Turnstile](https://github.com/Baroshem/nuxt-security/issues/666)
  - 無公開設定／重現；提供 Turnstile frame-src/script-src 指引，取得可公開的最小重現後驗證。
- [Issue #646: Exposed Network](https://github.com/Baroshem/nuxt-security/issues/646)
  - 測 LAN host 與 HMR URL；文件提供只限 development 的設定。
- [Issue #632: runtime config usage might break on cloudflare](https://github.com/Baroshem/nuxt-security/issues/632)
  - request-time config 必須傳 event；route-rule singleton 與 cold-start hook 的架構需配合 Cloudflare fixture 驗證。
- [Issue #627: How to pass env variables into `contentSecurityPolicy`](https://github.com/Baroshem/nuxt-security/issues/627)
  - 使用 private runtimeConfig 與 server hook 範例，測 runtime override，不把 process.env build-time 替換說成 runtime。
- [Issue #633: 🔐 Feature Request: Per-Extension Configuration for Nuxt-Security](https://github.com/Baroshem/nuxt-security/issues/633)
  - 設計 extension rule precedence、case／query／encoded path 與 static hosting export；新增 public SVG 正反例。
- [Issue #527: NuxtLink Support with custom route rules](https://github.com/Baroshem/nuxt-security/issues/527)
  - HTTP CSP 由 document response 決定；文件說明 SPA navigation 不會切換 document policy，提供 full navigation 策略與 browser test。
- [Issue #515: Setting `corsHandler.origin` issues](https://github.com/Baroshem/nuxt-security/issues/515)
  - 與 #505 共用 origin 正反例、regex／array、無 Origin 與預設值合併 fixture。
- [Issue #505: The corsHandler is not reflected. Defaults take preference.](https://github.com/Baroshem/nuxt-security/issues/505)
  - 分開測 HTML／API／static headers 與 CORS；文件明示標頭適用資源範圍。
- [Issue #295: Integration with Nuxt DevTools](https://github.com/Baroshem/nuxt-security/issues/295)
  - DevTools 僅公開經過遮罩的安全摘要；測密碼／secret 不出現在序列化 payload。
- [PR #755: chore(deps): bump js-yaml from 4.1.0 to 4.3.1 in /docs](https://github.com/Baroshem/nuxt-security/pull/755)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。
- [PR #753: chore(deps-dev): bump @nuxt/devtools from 1.6.0 to 3.3.1 in /docs](https://github.com/Baroshem/nuxt-security/pull/753)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。
- [PR #752: chore(deps-dev): bump nuxt from 3.14.1592 to 3.21.10 in /docs](https://github.com/Baroshem/nuxt-security/pull/752)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。
- [PR #749: chore(deps): bump socket.io-parser from 4.2.4 to 4.2.7 in /docs](https://github.com/Baroshem/nuxt-security/pull/749)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。
- [PR #747: chore(deps): bump postcss from 8.4.49 to 8.5.25 in /docs](https://github.com/Baroshem/nuxt-security/pull/747)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。
- [PR #743: chore(deps): bump svgo from 3.3.2 to 3.3.4 in /docs](https://github.com/Baroshem/nuxt-security/pull/743)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。
- [PR #739: chore(deps): bump shell-quote from 1.8.1 to 1.10.0 in /docs](https://github.com/Baroshem/nuxt-security/pull/739)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。
- [PR #733: chore(deps): bump @babel/core from 7.26.0 to 7.29.7 in /docs](https://github.com/Baroshem/nuxt-security/pull/733)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。
- [PR #727: chore(deps): bump launch-editor from 2.9.1 to 2.14.1 in /docs](https://github.com/Baroshem/nuxt-security/pull/727)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。
- [PR #714: chore(deps): bump devalue from 5.1.1 to 5.8.1 in /docs](https://github.com/Baroshem/nuxt-security/pull/714)
  - 文件網站依賴：與 Nuxt／Content／UI migration 一起更新獨立 lockfile，檢查 advisory、build 與搜尋／導航 browser smoke test。

## 原始碼審查額外發現與待辦

- P1：限流 storage 仍是 read／modify／write，跨 worker／多 instance 不具原子性；下一步需設計 driver 的 atomic consume 契約及並發測試，不能將序列測試通過解讀為分散式限流保證。
- P1：request size limiter 目前依賴 Content-Length，且方法清單未涵蓋 PATCH；缺少標頭或 chunked body 的實際 bytes gate 與 raw-stream 相容性需一起設計，補超限、等於上限、缺失／非法長度及 PATCH 測試。
- P2：CI 使用 checkout@master 等非 SHA 固定的 actions，需另行更新並固定來源；本輪先補 Node 24／26、frozen lockfile、cache id 與依賴漏洞 gate。
- 環境限制：Nuxt 建置仍警告 cache-driver.mjs 無法解析；目前測試沒有建立其 caching／ISR 執行保證，需與 #678 一起追查。

本輪已實作的修復與尚待實作／重現項目，以 [validation.md](./validation.md) 的證據與限制為準。
