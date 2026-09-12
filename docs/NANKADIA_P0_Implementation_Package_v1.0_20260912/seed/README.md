# Seed package notes

The actual historical RC1 candidate payloads are not duplicated here because the complete machine-readable RC1 files were not available in the current container export. The audited source establishes the 40/36/4 state and Human Review gate. Use the original RC1 payloads as input, then migrate each released candidate to `schemas/seed-resolution.schema.json` without guessing missing semantics.

Release must fail closed if any CORE member has `REVIEW_REQUIRED`, missing required v2.4.1 metadata, invalid hash, duplicate ID, or unresolved safety/privacy review.
