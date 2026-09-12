# Technology and Boundary Binding

## 1. Canonical vs replaceable

The current v2.4.1 parent defines Product/runtime behavior, not a cloud vendor. The prior 2026-09-09 implementation SoT used Expo/TypeScript + managed PostgreSQL/Supabase as a concrete implementation binding. This package preserves the **technical properties** that matter while keeping provider choice replaceable.

## 2. Required properties

### Client

- mobile-first client capable of stable local session/identity persistence;
- typed contracts shared with server where practical;
- client cannot directly mutate proof-critical records.

### Server/API boundary

Must support:

- authorization/ownership verification;
- schema validation;
- atomic state + event transaction;
- idempotency key/event ID handling;
- policy/config version verification;
- deterministic recommendation rules;
- server-side SELF_MOMENT qualification.

REST vs RPC is not Product-canonical.

### Database

Must provide PostgreSQL-equivalent semantics for:

- transactions;
- foreign keys/check constraints/unique keys;
- immutable-state enforcement or equivalent command-boundary enforcement;
- JSON payload storage for traces/events;
- indexed timestamp/user/moment lookups.

The supplied SQL is PostgreSQL. Supabase is compatible but not mandatory unless the implementation project separately freezes it.

### Analytics

First-party event log is mandatory for Product Proof. Third-party analytics may be added for convenience only if it cannot become the sole proof source and does not receive prohibited private data.

### Runtime recommendation

- synchronous Heavy LLM calls = 0;
- synchronous Supply Harness calls = 0;
- use frozen, pre-audited supply + deterministic domain rules.

## 3. Slice A does not require

- public web landing;
- media pipeline;
- UGC storage;
- continuous crawler;
- vector database;
- online feature store;
- streaming/event bus infrastructure.

Do not add these because they appeared in older Slice B/full-P0 technical plans.
