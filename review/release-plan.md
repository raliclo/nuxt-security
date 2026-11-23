# next-security-new 發布計畫

英文：[release-plan.en.md](./release-plan.en.md)。這是發布計畫；本輪不改套件名稱、不執行 npm publish。

## 套件身分

使用明確指定的 `next-security-new`；內容仍是 Nuxt security module。2026-11-23 registry 查詢 HTTP 404，僅表示當時未查到公開套件，不代表名稱已保留或帳號具發布權限。發布前重查名稱、npm owner 與 2FA／trusted publishing 設定。若名稱不可用，先使用自己擁有的 scope。

在專用 release commit 修改 package.json 的 name、repository（fork）、homepage、bugs、description，保留 MIT license 與上游作者／來源說明。`security` config key 保持一致；Nuxt module metadata name 改為新名稱。更新安裝文件，說明不得同時註冊原套件與 fork；可用 npm alias 安裝，但 nuxt.config 應只載入一次。

## 版本與相容性

建議以 `3.0.0-rc.0`、npm `next` tag 開始：Node >=24、Nuxt 4.6.4 為 stable 驗證基線；不宣稱 Nuxt 3 已驗證。Nitro 3 與 Nuxt 5x nightly 是獨立實驗矩陣。文件需明示 forwarded IP 預設不可信、Redis 失敗回覆 503，以及 dynamicNonce 需要 server runtime。

## 發布門檻

1. 根目錄 frozen install、prepare、lint、完整回歸、audit、prepack 全部成功；dist consumer fixtures 也必須成功。
2. docs 獨立 build、導覽／搜尋瀏覽器測試與依賴審查。已切換至 Content 的 Zod 4 schema adapter，新增過大集合提早拒絕測試；不得重新引入 v3 schema API。npm overrides 與 Yarn resolutions 必須保持一致，並對三份依賴圖分別掃描。
3. Node 24／26 的 Linux CI、Nitro 3 原生 imports／CSRF、Redis 多程序、Cloudflare workerd、Vercel CSP／ISR artifact、Bun 均通過。GitHub Actions 必須實際執行後才可標示完成。
4. 取得測試專案後，補真實 Vercel／Cloudflare 部署與 proxy ingress、ISR 更新、快取、cookies／CSRF 驗收。Turnstile／PGlite 需最小重現。缺少這些驗收時，RC 發布說明需明列限制，不能宣稱全部上游問題已關閉。
5. `npm pack --dry-run` 檢查只有 dist 與 npm 自動納入的 license／README／package metadata；解開 tarball，在獨立 Nuxt app 安裝該 tarball，測 SSR、SSG、streaming、POST、nonce／hash、SRI 與型別。不要只測工作區 source。

## 執行與回復

先以 release commit 產生 tarball 與 checksum，固定 lockfile 與 commit。確認 npm 身分後，於受保護的 release workflow 用 OIDC trusted publishing（若支援），或最小權限短效憑證發布 `npm publish --tag next --access public --provenance`；憑證不寫入 repo。將實際 registry 下載的 package 再裝入 smoke app，確認 exports、dist helpers、版本與 provenance。

RC 穩定後才發布 `3.0.0` 到 `latest`，並標記 fork git tag／changelog。先前 RC 留在 `next` 或更新 tag。出問題時回退 dist-tag 至上一個已驗證版本、對壞版本 `npm deprecate`，提供升級指引；不依賴任意 unpublish。正式發布與 npm 帳號操作需另有明確授權。
