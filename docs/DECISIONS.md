# Decisions

## Registry and data IDs are a compatibility contract

The installed 4.1.0 pack release defines the item, block, block-entity, recipe,
advancement, loot-table, and tag IDs that this fork preserves. The ID-only
contract lives in `.ci/compatibility-baseline.json`; baseline version, jar, and
SHA-256 metadata live only in `.ci/port-provenance.json`.

`runData` reads the live built-in registries after NeoForge registration and
writes sorted `ars_instrumentum` IDs to
`build/reports/ars_instrumentum/registry-ids.json`. Its final verification step
compares that dump and the normalized hand-authored/generated data IDs with the
baseline. Bytecode string literals are not registration evidence.

## Ars Nouveau uses the installed-pack Curse Maven artifact

The port compiles against CurseForge file 9052154, Ars Nouveau
`1.21.1-5.13.3`, because that is the exact pack-selected binary. The dependency
is non-transitive; Curios, GeckoLib, and Nuggets API dependencies are declared
directly so the compile and development runtime classpaths stay explicit.

## Unused mapping and viewer dependencies stay dropped

The fork does not use Parchment mappings or compile against JEI or Patchouli
APIs, so those repositories, properties, and dependencies were removed during
the port. Patchouli book JSON remains a runtime resource consumed through Ars
Nouveau; it does not require a compile-time Patchouli dependency.

## Upstream runtime logs are not source

Upstream tracked empty `logs/debug.log` and `logs/latest.log` files. Runtime
logs are machine output, so the fork removed those files and ignores `logs/`.
