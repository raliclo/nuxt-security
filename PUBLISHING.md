# Publish next-security-new / 發布步驟

This release branch prepares `next-security-new@3.0.0-rc.0`; publication is manual. 此分支不會自動發布套件。

1. Validate release-branch CI. Run `yarn dev:prepare`, `yarn release`, and the compatibility matrix in `review/compatibility.md`. 檢查 release 分支 CI 與所有驗證。
2. Run `npm pack --ignore-scripts --pack-destination <artifact-directory>`. Review files and SHA-256 checksum, then install the tarball in an independent Nuxt consumer. 檢查 tarball，並以獨立 consumer 安裝驗證。
3. Run `npm login --registry=https://registry.npmjs.org/`, complete browser/2FA authentication, then `npm whoami`. Never paste credentials into chat or commit them. 在終端機登入，不要將憑證貼入聊天或 repo。
4. Recheck `npm view next-security-new name versions --json`. A 404 does not reserve the name. If unavailable, use an owned scope. 若名稱已被占用，停止並改用自己擁有的 scope。
5. Publish the verified tarball, replacing its path below. RC uses `next`; do not move `latest`. 發布已驗證的 tarball，RC 使用 next tag。

```sh
npm publish /absolute/path/next-security-new-3.0.0-rc.0.tgz --tag next --access public
npm view next-security-new@3.0.0-rc.0 dist.integrity dist.tarball --json
```

Install the registry copy in a clean consumer before announcing it. Then tag the exact release commit. 發布後先從 registry 安裝複驗，再標記對應 git commit。

For later automation, configure npm Trusted Publishing for repository `raliclo/nuxt-security` and the exact GitHub workflow filename, preferably protected by a release environment. Package repository metadata must match the publishing repository. Supported public OIDC CI publishing generates provenance; local manual publication cannot claim CI provenance. 後續可改用受保護的 OIDC workflow；本機手動發布不可宣稱具備 CI provenance。

Official references: [publishing](https://docs.npmjs.com/creating-and-publishing-unscoped-public-packages/), [trusted publishing](https://docs.npmjs.com/trusted-publishers/), [provenance](https://docs.npmjs.com/generating-provenance-statements/).

## Consumer dependency audit / 使用端依賴掃描

Library overrides do not propagate into the application's root manifest. The Nuxt 4.6.4 tarball-consumer test uses this scoped application override for its readdir-glob/minimatch dependency chain. It does not override older callable minimatch users globally. 套件的 overrides 不會自動套用到應用程式；Nuxt 4.6.4 consumer 驗證使用以下限縮範圍的設定，未全域替換 minimatch。

```json
{
  "overrides": {
    "readdir-glob": { "minimatch": "^11.0.5" }
  }
}
```

For Yarn 1, use `"resolutions": { "**/readdir-glob/minimatch": "^11.0.5" }` in the app root instead. Re-run the application's own audit and regressions; remove the override when its dependency chain is fixed. 使用端需自行執行 audit 與回歸測試，依賴鏈修復後再移除 override。
