# Domain Docs

**Layout:** single-context

## Files

| File | Purpose |
|---|---|
| `CONTEXT.md` | Ubiquitous language, domain model, key constraints |
| `docs/adr/` | Architecture Decision Records |

## Consumer rules for agents

1. Read `CONTEXT.md` before making design decisions or writing specs.
2. Check `docs/adr/` for decisions that constrain implementation choices.
3. When adding a new ADR, follow the naming convention `docs/adr/NNNN-<slug>.md`.
4. Do not contradict terms defined in `CONTEXT.md` — open an issue if the domain model needs updating.
