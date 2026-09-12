#!/usr/bin/env python3
"""Fast, dependency-free checks for P0-01 contract closure."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(path: str, *needles: str) -> None:
    text = (ROOT / path).read_text(encoding="utf-8")
    for needle in needles:
        assert needle in text, f"{path}: missing {needle!r}"


require(
    "contracts/api.ts",
    "RecordExternalOpenInput",
    "AbortExecutionInput",
    "KeepBaselineInput",
    "recommendationImpressionId",
)
require(
    "12_API_COMMAND_CONTRACT.md",
    "authenticated caller is derived at the server boundary",
    "idempotency key",
)
require(
    "database/0003_machine_contract_closure.sql",
    "before insert or update or delete on core_pool_member",
    "state in ('RELEASED', 'RETIRED')",
    "only RELEASED core pools may activate experiment configs",
    "cannot retire a core pool referenced by an ACTIVE experiment config",
)

print("MACHINE CONTRACT VERIFY: PASS")
