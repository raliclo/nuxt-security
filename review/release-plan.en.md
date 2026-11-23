# Publishing next-security-new

Chinese: [release-plan.md](./release-plan.md). This is a plan; no rename or npm publication is performed in this change.

Use the requested name `next-security-new` for this Nuxt module. The registry returned HTTP 404 on 2026-11-23; this neither reserves the name nor proves account ownership. Recheck availability, ownership, 2FA and trusted-publishing configuration before release, or use an owned scope.

In a release-specific commit, update package name, fork repository, homepage, bugs, description and module metadata name. Preserve MIT licensing and upstream attribution. Retain the `security` configuration key and document that the original module and fork must not both be registered.

Start with `3.0.0-rc.0` on npm's `next` tag. Node >=24 and Nuxt 4.6.4 form the stable validation baseline; Nuxt 3 is not verified. Nuxt 5x nightly/Nitro 3 RC have a separate experimental matrix. Document trusted-proxy requirements, Redis fail-closed behavior and server-backed dynamic nonces.

Release gates:

1. Frozen installs, prepare, lint, full regression tests, root audit, package build and dist consumer builds pass.
2. The independent docs build, browser navigation/search and audits pass. Docs now use Content's Zod 4 schema adapter with an early-rejection regression for oversized collections; do not reintroduce v3 schemas. Keep npm overrides and Yarn resolutions aligned, auditing all three dependency graphs independently.
3. Actual Node 24/26 Linux CI, native Nitro 3/CSRF, Redis cross-process concurrency, workerd, Vercel CSP/ISR artifacts and Bun pass. Local Windows evidence does not establish CI success.
4. Run live Vercel/Cloudflare, ingress, ISR/cache and cookie/CSRF checks when test projects exist. Obtain Turnstile/PGlite reproductions. RC notes must disclose missing checks instead of claiming every upstream issue is closed.
5. Review `npm pack --dry-run`; unpack and install the tarball into an independent Nuxt application and validate SSR, SSG, streaming, bodies, nonces, hashes, SRI, types and exports. Source builds alone are insufficient.

Build a checksummed tarball from the release commit. With explicit publication authorization, prefer a protected OIDC trusted-publishing workflow and `npm publish --tag next --access public --provenance`; keep credentials out of the repository. Install the registry-downloaded package again for smoke testing. Promote a subsequent stable version to `latest` only after acceptance. Roll back dist-tags to a verified release and deprecate a broken version with guidance instead of relying on unpublish.
