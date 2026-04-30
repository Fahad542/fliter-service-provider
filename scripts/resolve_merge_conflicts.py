#!/usr/bin/env python3
"""Resolve Git stash-style conflict markers: pick upstream or stashed chunk."""
from __future__ import annotations

import sys
from pathlib import Path


def resolve(text: str, pick: str) -> str:
    start = "<<<<<<< Updated upstream\n"
    mid = "\n=======\n"
    end = "\n>>>>>>> Stashed changes\n"
    pick_up = pick == "upstream"
    while True:
        i = text.find(start)
        if i < 0:
            return text
        m = text.find(mid, i)
        if m < 0:
            raise ValueError(f"Missing separator after marker at {i}")
        e = text.find(end, m)
        if e < 0:
            raise ValueError("Missing closing conflict marker")
        upstream = text[i + len(start) : m]
        stashed = text[m + len(mid) : e]
        choice = upstream if pick_up else stashed
        text = text[:i] + choice + text[e + len(end) :]


ROOT = Path(__file__).resolve().parent.parent

# Files where "Updated upstream" should win (referenced undefined ids or better l10n).
UPSTREAM_ONLY = {
    ROOT / "lib/views/Workshop pos app/Technician Screen/technician_view_model.dart",
    ROOT / "lib/views/Workshop owner/POS Monitoring/pos_monitoring_view_model.dart",
}


def main(argv: list[str]) -> None:
    files = argv[1:]
    if not files:
        # All tracked dart under lib that still have markers (bash finds them).
        sys.exit(
            "Usage: resolve_merge_conflicts.py FILE [FILE …]\n"
            "Typically: rg -l '^<<<<<<<' lib | while read f; do ..."
        )

    for f in files:
        p = Path(f).expanduser().resolve()
        if not p.exists():
            print(f"SKIP missing {p}")
            continue
        if "inventory_sales_view_model.dart" in str(p):
            print(f"SKIP manual merge {p}")
            continue
        txt = p.read_text(encoding="utf-8")
        if "<<<<<<< Updated upstream" not in txt:
            continue
        pick = "upstream" if p.resolve() in {x.resolve() for x in UPSTREAM_ONLY} else "stashed"
        out = resolve(txt, pick)
        p.write_text(out, encoding="utf-8")
        print(f"OK {pick:8} {p.relative_to(ROOT)}")


if __name__ == "__main__":
    main(sys.argv)
