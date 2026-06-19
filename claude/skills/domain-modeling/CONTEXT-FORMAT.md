# CONTEXT.md Format

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this project's context.** General programming concepts (timeouts, error types, utility patterns) don't belong even if the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine.

## Per-project scoping

Context is scoped per project. Each project gets its own `CONTEXT.md`, co-located with that project's ADR, defining only the terms that project introduces or sharpens. There is no repo-wide glossary.

When terms are shared across projects, an optional `CONTEXT-MAP.md` alongside the project folders lists each project and how they relate:

```md
# Context Map

## Projects

- [foo](./foo/CONTEXT.md) — receives and tracks customer orders
- [bar](./bar/CONTEXT.md) — generates invoices and processes payments

## Relationships

- **foo → bar**: foo emits `OrderPlaced` events; bar consumes them to generate invoices
- **foo ↔ bar**: shared types for `CustomerId` and `Money`
```

The skill infers which `CONTEXT.md` applies from the project under discussion:

- If a project's `CONTEXT.md` exists, read it for that project's language
- If it doesn't exist yet, create it lazily when the first term is resolved
- If unclear which project a topic relates to, ask

