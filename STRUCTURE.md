# Structure

## Layout

- `.github/workflows/` and `.github/actions/setup-mod-build/` - synced hosted CI and dispatch-only release automation.
- `.ci/mod.json` - release identity, NeoForge 1.21.1 profile, datagen policy, pack side, and Ars Instrumentum jar checks; `.ci/port-provenance.json` records the upstream and pack baseline.
- `gradle/`, `gradlew*`, `.gitattributes`, and `.gitignore` - synced workspace build/release helpers and wrapper files.
- `docs/releases/` - versioned release notes required by the release workflow.
- `tools/test-world/datapack/` - synced profile-specific test-world resources; they are excluded from release jars.

- `src/main/java/de/sarenor/arsinstrumentum/` - preserved upstream package layout, organized by gameplay responsibility (`blocks`, `items`, `network`, `setup`, `datagen`, and client code).
- `src/main/resources/` - NeoForge metadata and hand-authored assets/data.
- `src/generated/resources/` - checked-in datagen output; CI regenerates it and rejects drift.
- `docs/UPSTREAM.md` - fork ancestry, compatibility baseline, and retained licensing notice.
- `build/` and `run/` - ignored local outputs.

This fork remains a standalone repository and builds without the parent workspace or local compile-time jars.
