# Structure

## Layout

```text
.
|-- .ci/                 CI profiles, fork policy, provenance, and scripts
|-- .github/             hosted verification and release workflows
|-- docs/                fork decisions, provenance, and release notes
|-- gradle/              shared build/profile/release helpers
|-- src/main/            Java and hand-authored resources
|-- src/generated/       checked-in datagen output
`-- tools/               compatibility audit and staged test-world datapack
```

- `.ci/build-profiles.json` and `.ci/scripts/` - synced profile selection, verification, GameTest, and release scripts.
- `.ci/mod.json` - fork-specific release identity, NeoForge profile, datagen policy, pack side, and jar checks.
- `.ci/port-provenance.json` - the only source for upstream, baseline jar/version/hash, dependency, and target-version provenance.
- `.ci/compatibility-baseline.json` - registry and normalized data ID lists that the port must preserve.
- `.github/workflows/` and `.github/actions/setup-mod-build/` - synced hosted CI and dispatch-only release automation.
- `gradle/`, `gradlew*`, `.gitattributes`, and `.gitignore` - synced workspace build/release helpers and wrapper files.
- `docs/DECISIONS.md`, `docs/UPSTREAM.md`, and `docs/releases/` - fork rulings, ancestry/licensing, and versioned release notes.
- `tools/verify-id-compatibility.ps1` - compares the live `runData` registry dump and resource IDs with the compatibility baseline.
- `tools/test-world/datapack/` - the synced, profile-selected NeoForge 1.21.1 test datapack staged into test worlds and excluded from release jars.
- `src/main/java/de/sarenor/arsinstrumentum/` - preserved upstream package layout, organized by gameplay responsibility (`blocks`, `items`, `network`, `setup`, `datagen`, and client code).
- `src/main/resources/` - NeoForge metadata and hand-authored assets/data.
- `src/generated/resources/` - checked-in datagen output; CI regenerates it and rejects drift.
- `build/`, `run/`, and `logs/` - ignored local build, game-run, and runtime-log output.

This fork remains a standalone repository and builds without the parent workspace or local compile-time jars.
