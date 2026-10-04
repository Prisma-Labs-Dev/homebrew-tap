# Prisma Labs Homebrew tap

```bash
brew install prisma-labs-dev/tap/<formula>          # CLIs
brew install --cask prisma-labs-dev/tap/<cask>      # Mac apps
```

| Name | Kind | Install |
| --- | --- | --- |
| [context-lens](https://github.com/Prisma-Labs-Dev/context-lens) | Mac app + CLI | `brew install --cask prisma-labs-dev/tap/context-lens` |
| [confluence-cli](https://github.com/Prisma-Labs-Dev/confluence-cli) | CLI | `brew install prisma-labs-dev/tap/confluence-cli` |
| [jira-cli](https://github.com/Prisma-Labs-Dev/jira-cli) | CLI | `brew install prisma-labs-dev/tap/jira-cli` |

Formulas sit at the repo root (`confluence-cli.rb` is updated by GoReleaser). Casks live in
`Casks/`.

## Adding an app to this tap

Every Prisma Labs Mac app ships the same way: built on a Mac, signed with the Prisma Labs
Developer ID, notarized, zipped, attached to a GitHub release, and installed by a cask here.
Homebrew no longer has `--no-quarantine`, so an unsigned or un-notarized app is not an option.
Context Lens is the reference: copy its
[`scripts/release.sh`](https://github.com/Prisma-Labs-Dev/context-lens/blob/main/scripts/release.sh)
and [`Casks/context-lens.rb`](Casks/context-lens.rb).

### One-time setup on the build Mac

- A `Developer ID Application: Prisma Labs (482BX64953)` identity in the login keychain
  (`security find-identity -v -p codesigning`). One certificate signs every app; it expires
  2031-09-17. Only the Account Holder can create one: a team API key gets a 403, so use the
  Account Holder's API key or the portal (Certificates > + > Developer ID Application, G2 Sub-CA,
  upload a CSR).
- An App Store Connect API key in `ASC_KEY_ID`, `ASC_ISSUER_ID` and `ASC_KEY_PATH`, which
  `notarytool` uses.

### The app repo

1. Copy `scripts/release.sh` and edit the block at the top: `APP_NAME` (the product name, so the
   bundle is `$APP_NAME.app`), `SCHEME`, `BUNDLE_ID`, `ZIP_NAME`, and `EXTRA_BINARIES` (nested
   executables such as an embedded CLI, signed before the app). The script assumes an XcodeGen
   `project.yml` with `MARKETING_VERSION`; adjust the build lines otherwise.
2. The app must build with the hardened runtime. `release.sh` re-signs with
   `--options runtime --timestamp`; add an entitlements file only if the app needs one (for
   example to load unsigned plugins).
3. Bump `MARKETING_VERSION`, merge, then on `main`:

   ```bash
   scripts/release.sh 1.2.3       # build, sign, notarize, staple, zip; prints the sha256
   git tag v1.2.3 && git push origin v1.2.3
   gh release create v1.2.3 build/release/<zip-name>-1.2.3.zip --title v1.2.3 --notes "..."
   ```

   Notarization takes a few minutes. If it fails, `xcrun notarytool log <submission id> --key
   "$ASC_KEY_PATH" --key-id "$ASC_KEY_ID" --issuer "$ASC_ISSUER_ID"` says why (usually an
   unsigned nested binary or a missing hardened runtime).

### The cask

Add `Casks/<name>.rb`, modeled on `Casks/context-lens.rb`:

- `version`, `sha256` (from `release.sh`), and a `url` that uses `#{version}`.
- `depends_on macos:` matching the app's deployment target (`:tahoe` for macOS 26 or later).
- `app "<App Name>.app"`, and `binary "#{appdir}/<App Name>.app/Contents/MacOS/<cli>"` if the
  app embeds a CLI.
- `uninstall quit: "<bundle id>"` and a `zap trash:` list of everything the app writes
  (its dot folder, `~/Library/Preferences/<bundle id>.plist`, caches).

For a new version, change `version` and `sha256` only.

### Consumer test (every release)

```bash
brew untap prisma-labs-dev/tap; brew tap prisma-labs-dev/tap
brew style --cask prisma-labs-dev/tap/<name>
brew audit --cask --online prisma-labs-dev/tap/<name>
brew install --cask prisma-labs-dev/tap/<name>
spctl -a -vv "/Applications/<App Name>.app"      # "accepted", "source=Notarized Developer ID"
open "/Applications/<App Name>.app"              # no Gatekeeper prompt
<cli> --help                                     # if it ships a CLI
brew uninstall --zap --cask <name>               # app, binary link and zap paths are gone
```
