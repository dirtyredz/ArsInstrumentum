# Upstream and port provenance

This NeoForge 1.21.1 line descends from
[Sarenor/Ars-Instrumentum](https://github.com/Sarenor/Ars-Instrumentum), branch
`1.21.x`, at commit `ec06fb0f1da3fd3b7daf0f520c7f92dcd4fe8ee5`. Upstream had already
completed the Minecraft 1.21.1/NeoForge migration and assigned version `5.0.0`.

The Evil Eye pack baseline is CurseForge project 580179, file 5047343,
`ars_instrumentum-1.20.1-4.1.0.jar` (SHA-256
`1ff7923640b80d27726ab864937b1342c7bbfb1d424185e9cfcb25ca5894d2b5`). Its
item, block, block-entity, recipe, and data identifiers are the save and recipe
compatibility contract for this fork.

## Fork changes

- Pin Minecraft 1.21.1 to NeoForge 21.1.265 and Java 21.
- Pin Ars Nouveau to `1.21.1-5.13.3` and adapt to its APIs.
- Preserve the 4.1.0 registry and recipe identifiers or document an explicit
  replacement when Minecraft 1.21's data-pack layout requires one.
- Produce `ars_instrumentum-1.21.1-neoforge-5.0.0.jar`.
- Record a reproducible identifier comparison in the port job artifacts.

## License and notices

The upstream project is licensed under GNU LGPL v3.0. The repository's
`LICENSE` file and upstream source notices are retained. Fork changes remain
under the same license; no upstream authorship is claimed by the fork.
