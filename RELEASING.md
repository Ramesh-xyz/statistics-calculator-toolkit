# Releasing

Every package is released on its own from the **Actions** tab. Each
`.github/workflows/publish-<lang>.yml` runs that language's tests, then
creates the release tag from the manifest version (Go and PHP: from the
`version` input), pushes it, and publishes with that tag. If the tag already
exists on a different commit the run fails; bump the version. Pushing the tag
yourself still works and runs the same workflow.

## Release steps

1. Bump the version in the manifest(s) listed below and add a
   `CHANGELOG.md` entry. Merge to `main`.
2. **Actions → publish-<lang> → Run workflow** on `main`
   (`gh workflow run publish-js.yml`, or
   `gh workflow run publish-go.yml -f version=0.1.1`).

3. Watch the run under **Actions**, then check the registry page: version,
   README, homepage and repository links.

## Tags, manifests and secrets

Add the secrets under **Settings → Secrets and variables → Actions**.

| language | tag | version lives in | secrets |
|---|---|---|---|
| Python | `py-v0.1.0` | `pyproject.toml`, `src/sdtoolkit/__init__.py` | `PYPI_API_TOKEN` |
| JavaScript | `js-v0.1.0` | `js/package.json` | `NPM_TOKEN` |
| Rust | `rust-v0.1.0` | `rust/Cargo.toml` | `CARGO_REGISTRY_TOKEN` |
| Go | `go/sdtoolkit/v0.1.0` | `version` input | none |
| R | `r-v0.1.0` | `r/DESCRIPTION` | none (see below) |
| Java | `java-v0.1.0` | `java/pom.xml` | `CENTRAL_TOKEN_USERNAME`, `CENTRAL_TOKEN_PASSWORD`, `MAVEN_GPG_PRIVATE_KEY`, `MAVEN_GPG_PASSPHRASE` |
| .NET | `dotnet-v0.1.0` | `dotnet/src/SdToolkit/SdToolkit.csproj` | `NUGET_API_KEY` |
| Ruby | `ruby-v0.1.0` | `ruby/lib/sdtoolkit/version.rb` | `RUBYGEMS_API_KEY` |
| PHP | `v0.1.0` | `version` input | `PACKAGIST_USERNAME`, `PACKAGIST_TOKEN` |
| Dart | `dart-v0.1.0` | `dart/pubspec.yaml` | none (OIDC) |

PHP uses plain `vX.Y.Z` tags because Packagist reads versions from tag names
and ignores tags like `php-v0.1.0`. Do not add any other workflow that
triggers on `v*`.

## One-time setup per registry

- **PyPI:** create an account, then an API token (first upload needs an
  account-wide token; replace it with a project-scoped one afterwards).
  Trusted publishing is an alternative: add a publisher for workflow
  `publish-python.yml`, environment `pypi`, then delete the `password:` line.
- **npm:** the package is `@rameshxyz/sdtoolkit`; npm refused the unscoped
  name `sdtoolkit` as too similar to `es-toolkit`. Create a granular access
  token with read-and-write access to all packages and "Bypass two-factor
  authentication" ticked. Provenance is attached automatically.
- **crates.io:** log in with GitHub, create a token with the `publish-new`
  and `publish-update` scopes.
- **Go:** nothing. The workflow asks proxy.golang.org for the new version so
  pkg.go.dev lists it.
- **R / CRAN:** CRAN has no upload API. The workflow runs
  `R CMD check --as-cran` and attaches the source tarball to the GitHub
  release. Before the first submission, set a real maintainer email in
  `r/DESCRIPTION` (CRAN emails a confirmation link), then upload the tarball
  at <https://cran.r-project.org/submit.html>.
- **Maven Central:** sign in at <https://central.sonatype.com> with the
  `Ramesh-xyz` GitHub account so the `io.github.ramesh-xyz` namespace is
  verified, and generate a user token (username + password secrets). Create
  a GPG key, publish the public key to `keyserver.ubuntu.com`, and store the
  armored private key and its passphrase as secrets.
- **NuGet:** create an API key on nuget.org with push rights, glob
  `SdToolkit`.
- **RubyGems:** create an API key with the "Push rubygem" scope. If the
  account's MFA level is "UI and API", CI pushes are rejected; use
  "UI and gem signin" or switch to RubyGems trusted publishing (see the
  comment in `publish-ruby.yml`).
- **Packagist:** submit the repository URL once at
  <https://packagist.org/packages/submit>, then add your username and API
  token (Profile → Show API Token). Packagist installs download GitHub's zip
  of the whole repository.
- **pub.dev:** the first version must be published by hand
  (`cd dart && dart pub publish`). Then on pub.dev → sdtoolkit → Admin →
  Automated publishing, enable GitHub Actions for
  `Ramesh-xyz/statistics-calculator-toolkit` with tag pattern
  `dart-v{{version}}`, and enable publishing from `workflow_dispatch`
  events. The workflow re-runs itself on the new tag so pub.dev sees a tag ref.

## Documentation site

`docs/` is built with Jekyll by `.github/workflows/pages.yml` and deployed to
<https://ramesh-xyz.github.io/statistics-calculator-toolkit/> on every push to
`main` that touches `docs/`. Settings → Pages → Source must be
**GitHub Actions**.
