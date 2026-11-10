# Git and release workflow

The repository is [jgYro/yrodev](https://github.com/jgYro/yrodev), with local `master` tracking `origin/master`. The `origin` URL is `https://github.com/jgYro/yrodev.git`. Work from the Flutter project root. The ignored `.site/yro-overview` directory contains historical checkpoints and is not the active repository.

Root initialization is complete. The one-time setup script has been removed. Fetch and review unexpected remote changes before integrating them; preserve shared history.

## Tracked files and local state

Commit Flutter source, platform scaffolding, the app's `pubspec.lock`, `.flutter-version`, `firebase.json`, `.firebaserc`, source assets, scripts, and project documentation. The Firebase project/site IDs are configuration identifiers, not authentication credentials.

Ignore generated builds and Flutter caches, Firebase cache and debug logs, local environment files, service-account credentials, signing keys, IDE state, and review screenshots. The Tunings preview under `assets/` remains tracked because the application uses it. Historical `.site/` checkpoints remain local. `.gitattributes` normalizes text to LF, keeps Windows command scripts at CRLF, and treats binary assets as binary.

## Changes and validation

```sh
git switch master
git pull --ff-only
git switch -c update/short-description
```

Use the approved Flutter version recorded in `.flutter-version`. Before proposing dependency changes, follow the project's supply-chain assessment instructions. Existing dependencies should match `pubspec.lock`.

```sh
sh scripts/check.sh
git diff --check
git add <changed-files>
git commit -m 'Describe the resulting change'
git push -u origin HEAD
```

`scripts/check.sh` enforces the Flutter version, runs static analysis and the existing tests, and builds the web release without dependency resolution or remote renderer assets. Run it on a machine where the Flutter test runner can bind its loopback socket. Review changes before merging into `master`.

## Deployment

Deploy the tested build from the reviewed `master` commit:

```sh
git switch master
git pull --ff-only
sh scripts/check.sh
firebase deploy --only hosting --project yro-llc
```

The existing Firebase MCP integration can perform the same deployment. See [firebase-deployment.md](firebase-deployment.md) for the live project and verification procedure. The Hosting configuration publishes only `build/web`; it applies security headers and excludes source maps, debug symbols, and hidden build files.
