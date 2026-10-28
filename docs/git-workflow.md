# Git and release workflow

The intended repository is [jgYro/yrodev](https://github.com/jgYro/yrodev), with `master` as the primary branch. Work from the Flutter project root, not the historical `.site/yro-overview` checkpoint directory.

## Initial setup

The repository was confirmed public and empty on 2026-10-28. This environment denied creation of the project's root `.git` directory, so initial setup must run from the owner's terminal:

```sh
cd /Users/jerichogregory/Yro/projects/yro
sh scripts/setup-git.sh
```

The script initializes `master`, configures the requested `origin`, uses the business commit identity `Yro LLC <business@yro.dev>`, stages the project according to its ignore rules, and creates the initial commit. It stops if a root repository already exists. It does not change global Git settings or rewrite the historical checkpoint repository.

Publish the initial branch after authenticating with GitHub:

```sh
git push -u origin master
```

The GitHub CLI reported invalid credentials during setup. If using `gh` to reauthenticate, run its browser flow from your terminal. An invalid environment token can override stored credentials, so these commands omit those overrides for this operation:

```sh
env -u GH_TOKEN -u GITHUB_TOKEN gh auth login --hostname github.com --git-protocol https --web
env -u GH_TOKEN -u GITHUB_TOKEN gh auth setup-git --hostname github.com
env -u GH_TOKEN -u GITHUB_TOKEN git push -u origin master
env -u GH_TOKEN -u GITHUB_TOKEN gh repo edit jgYro/yrodev --default-branch master
```

The default branch change requires a successful first push so `master` exists remotely. Never force-push over an unexpected remote history; fetch and review it first.

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
