# GEN-PT-019 Polyglot CI

Purpose: make the alpha repository communicate that the language folders are monitored, not decorative.

This flat-file patch adds:

- `.github/workflows/polyglot-verified.yml`
- `.github/workflows/polyglot-experimental.yml`
- `docs/ci/README.md`
- a formatted `README.md` with useful public badges and a CI Status section.

No scripts, generated binaries, package publishing steps, tags, GitHub Releases, or algorithm changes are included.

## Intended Meaning

- `conformance.yml` remains the stable required baseline.
- `polyglot-verified.yml` is expected to pass after CI stabilization and should represent the portable verified language set.
- `polyglot-experimental.yml` is monitoring only and is allowed to fail.

## Recommended First Run

After applying this patch, commit to `dev` first and run:

```powershell
gh workflow run polyglot-verified.yml --ref dev
gh workflow run polyglot-experimental.yml --ref dev
gh run list --limit 10
```

If `polyglot-verified` fails, inspect the failed job:

```powershell
gh run view <run-id> --log-failed
```

Fix path/toolchain issues on `dev` before merging to `master`.

## Branch Protection Recommendation

Only make `conformance` required first.

Make `polyglot verified` required only after it has passed repeatedly on both `dev` and `master`.

Never make `polyglot experimental` required in the alpha.
