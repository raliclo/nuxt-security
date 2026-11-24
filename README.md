# next-security-new

An independent fork of [nuxt-security](https://github.com/Baroshem/nuxt-security), a **Nuxt** security module. This is not a Next.js module or an official upstream release. MIT licensing and upstream attribution are retained. The RC is not available on npm until publication is completed.

本套件是 nuxt-security 的獨立 Nuxt fork，並非 Next.js 套件或上游官方版本；保留 MIT 授權與上游來源。RC 尚未發布前，npm 安裝指令不會成功。

Automatically configure your app to follow OWASP security patterns and principles by using HTTP Headers and Middleware.

> Node >=24; verified stable baseline: Nuxt 4.6.4 / Nitro 2.13.6 / h3 1.15.11 / Vite 8.3.8. This fork has not verified Nuxt 3. Native Nitro 3 uses a separate experimental Nuxt 5x nightly fixture.
>
> 本 fork 未驗證 Nuxt 3；Nitro 3 為獨立實驗矩陣，不是 Nuxt 4 預設環境。

- [📖 &nbsp;Read the documentation](https://nuxt-security.vercel.app)
- [👾 &nbsp;Playground](https://nuxt-security.vercel.app/playground)

## Features

- Security response headers (including CSP for SSG apps)
- Request Size & Rate Limiters
- Cross Site Scripting (XSS) Validation
- Cross-Origin Resource Sharing (CORS) support
- Hide `X-Powered-By` header and remove console loggers utils
- `[Optional]` Allowed HTTP Methods, Basic Auth, CSRF

## Usage

Install the module:

```sh
npm install next-security-new@next
```

Register `next-security-new` in `modules` as shown below. Remove the original `nuxt-security` registration first; load only one security module. Keep the `security` configuration key. 註冊此 fork 前移除原套件，不能同時啟用兩者。

## Configuration

You can pass configuration to the module in the `nuxt.config.ts` like following:

```ts
export default defineNuxtConfig({
  modules: ["next-security-new"],
  security: {
    // options
  }
})
```

For all available configuration options check out the [docs](https://nuxt-security.vercel.app/getting-started/configuration).

## Fork migration / Fork 遷移

- Forwarded IP is untrusted by default. Enable `trustProxy` only behind an ingress that rewrites headers and blocks direct bypass. 代理部署須明確設定可信入口。
- Multi-instance limiting needs shared Redis; local storage only serializes within one process. Redis failure returns 503. 分散式限流需共用 Redis。
- Dynamic SSG nonces require a server runtime and uncached HTML. 動態 SSG nonce 不適用純靜態部署。
- Live cloud deployment and external Turnstile/PGlite reproductions remain unverified. 不將本機測試視為真實雲端驗收。
- Publication instructions: [PUBLISHING.md](./PUBLISHING.md). 發布流程見該文件。
- Dependency overrides in a library are not inherited by consuming apps. Until Nuxt's readdir-glob chain is patched, apply the consumer override in PUBLISHING.md and audit your app independently. 套件的 overrides 不會傳遞給使用端，請依發布說明處理並獨立掃描應用程式。

## Development

- Run `yarn dev:prepare` to generate type stubs.
- Use `yarn dev` to start playground in development mode.

## License

[MIT License](./LICENSE.md)

<!-- Badges -->

[npm-version-src]: https://img.shields.io/npm/v/nuxt-security/latest.svg
[npm-version-href]: https://npmjs.com/package/nuxt-security
[npm-downloads-src]: https://img.shields.io/npm/dt/nuxt-security.svg
[npm-downloads-href]: https://npmjs.com/package/nuxt-security
[github-actions-ci-src]: https://github.com/baroshem/nuxt-security/actions/workflows/ci.yml/badge.svg
[github-actions-ci-href]: https://github.com/baroshem/nuxt-security/actions?query=workflow%3Aci
[license-src]: https://img.shields.io/npm/l/nuxt-security.svg
[license-href]: https://npmjs.com/package/nuxt-security
[nuxt-src]: https://img.shields.io/badge/Nuxt-18181B?logo=nuxt
[nuxt-href]: https://nuxt.com
