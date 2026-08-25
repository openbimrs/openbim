#!/usr/bin/env python3
"""Fail if an isolated openbim facade feature pulls another standard family."""

from __future__ import annotations

import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent

# `loin` normatively imports ISO 23387 and therefore intentionally includes DT.
FEATURES: dict[str, frozenset[str]] = {
    "default": frozenset(),
    "dt": frozenset({"openbim-dt"}),
    "ids": frozenset({"openbim-ids"}),
    "gaeb": frozenset({"openbim-gaeb"}),
    "citygml": frozenset({"openbim-citygml"}),
    "openbimrl": frozenset({"openbim-openbimrl"}),
    "bsdd": frozenset({"openbim-bsdd"}),
    "epd": frozenset({"openbim-epd"}),
    "bcf": frozenset({"openbim-bcf"}),
    "icdd": frozenset({"openbim-icdd"}),
    "idm": frozenset({"openbim-idm"}),
    "loin": frozenset({"openbim-loin", "openbim-dt"}),
}
STANDARD_PACKAGES = frozenset().union(*FEATURES.values()) | frozenset(
    {
        "openbim-cde",
        "openbim-ifc",
        "ifc-schema",
        "ifc-step",
        "ifc-xml",
        "ifc-model",
        "ifc-geometry",
        "ifc-properties",
        "ifc-template-catalog",
        "ifc-cost",
        "ifc-schedule",
        "ifc-material",
        "ifc-style",
        "ifc-structural",
        "ifc-resource",
        "ifc-classification",
        "ifc-georef",
        "ifc-systems",
        "ifc-alignment",
        "ifc-validate",
    }
)
PACKAGE_LINE = re.compile(r"^([A-Za-z0-9_-]+) v\d")


def closure(feature: str) -> set[str]:
    command = [
        "cargo",
        "tree",
        "-p",
        "openbim",
        "--no-default-features",
        "--locked",
        "--edges",
        "normal",
        "--prefix",
        "none",
        "--format",
        "{p}",
    ]
    if feature != "default":
        command.extend(("--features", feature))
    result = subprocess.run(
        command,
        cwd=ROOT,
        env=os.environ,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    if result.returncode != 0:
        print(result.stdout, end="", file=sys.stderr)
        raise RuntimeError(f"cargo tree failed for feature {feature!r}")
    return {
        match.group(1)
        for line in result.stdout.splitlines()
        if (match := PACKAGE_LINE.match(line))
    }


def main() -> int:
    failed = False
    for feature, expected in FEATURES.items():
        try:
            packages = closure(feature)
        except RuntimeError as error:
            print(error, file=sys.stderr)
            return 2
        actual = packages & STANDARD_PACKAGES
        if actual != expected:
            missing = sorted(expected - actual)
            unexpected = sorted(actual - expected)
            print(
                f"{feature}: isolation violation; missing={missing}, unexpected={unexpected}",
                file=sys.stderr,
            )
            failed = True
        else:
            print(f"{feature}: isolated ({', '.join(sorted(actual)) or 'core only'})")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
