#!/usr/bin/env python3
"""Validate counts and ID sets in the user-provided RC1 reconstruction evidence."""

from pathlib import Path
import re
import sys


SOURCE = (
    Path(__file__).resolve().parents[1]
    / "docs/NANKADIA_P0_Implementation_Package_v1.0_20260912/seed/rc1_reconstructed"
    / "rc1_reconstructed_source_20260913.txt"
)

EXPECTED_CORE = {
    *(f"SC-{n:03d}" for n in range(1, 41)),
} - {"SC-005", "SC-015", "SC-033", "SC-037"}
EXPECTED_PARK = {"SC-005", "SC-015", "SC-033", "SC-037"}


def table_ids(text: str) -> list[str]:
    # Candidate rows use bold IDs; this excludes prose references and the PARK table.
    return re.findall(r"^\|\s+\*\*(SC-\d{3})[★ ]", text, flags=re.MULTILINE)


def park_table_ids(text: str) -> list[str]:
    section = text.split("## PARKされた4件", 1)
    if len(section) != 2:
        return []
    return re.findall(r"^\|\s+(SC-\d{3})\s+\|", section[1], flags=re.MULTILINE)


def main() -> int:
    if not SOURCE.is_file():
        print(f"missing source: {SOURCE}", file=sys.stderr)
        return 1
    text = SOURCE.read_text(encoding="utf-8")
    core = table_ids(text)
    park = park_table_ids(text)
    errors: list[str] = []
    if len(core) != 36:
        errors.append(f"CORE count={len(core)} (want 36)")
    if len(set(core)) != len(core):
        errors.append("CORE contains duplicate IDs")
    if set(core) != EXPECTED_CORE:
        errors.append(f"CORE IDs differ: {sorted(set(core) ^ EXPECTED_CORE)}")
    if len(park) != 4:
        errors.append(f"PARK count={len(park)} (want 4)")
    if len(set(park)) != len(park):
        errors.append("PARK contains duplicate IDs")
    if set(park) != EXPECTED_PARK:
        errors.append(f"PARK IDs differ: {sorted(set(park) ^ EXPECTED_PARK)}")
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print("RC1 reconstruction: CORE=36, PARK=4, IDs=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
