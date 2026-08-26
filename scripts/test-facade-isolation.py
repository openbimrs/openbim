#!/usr/bin/env python3
"""Mutation-test every isolated openbim facade feature."""

from __future__ import annotations

import importlib.util
from pathlib import Path
import re
import subprocess
import sys

# Import the checker without leaving __pycache__ in a clean source checkout.
sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parent.parent
CHECKER = ROOT / "scripts/check-facade-isolation.py"
MANIFEST = ROOT / "packages/facade/openbim/Cargo.toml"
LOCKFILE = ROOT / "Cargo.lock"
FAMILY_PACKAGES = (
    "openbim-dt",
    "openbim-ids",
    "openbim-gaeb",
    "openbim-citygml",
    "openbim-openbimrl",
    "openbim-bsdd",
    "openbim-epd",
    "openbim-bcf",
    "openbim-icdd",
    "openbim-idm",
    "openbim-loin",
    "openbim-mvd",
)


def load_features() -> dict[str, frozenset[str]]:
    spec = importlib.util.spec_from_file_location("openbim_facade_isolation", CHECKER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot import {CHECKER}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.FEATURES


def run_checker() -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(CHECKER)],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )


def mutate_feature(source: str, feature: str, foreign_package: str) -> str:
    pattern = re.compile(rf"(?m)^{re.escape(feature)} = \[(?P<body>[^\n]*)\]$")
    match = pattern.search(source)
    if match is None:
        raise RuntimeError(f"feature definition not found: {feature}")
    body = match.group("body")
    injected = f'{body}, "dep:{foreign_package}"' if body else f'"dep:{foreign_package}"'
    return source[: match.start()] + f"{feature} = [{injected}]" + source[match.end() :]


def main() -> int:
    features = load_features()
    test_features = {name: expected for name, expected in features.items() if name != "default"}
    if set(test_features) != {
        "dt", "ids", "gaeb", "citygml", "openbimrl", "bsdd",
        "epd", "bcf", "icdd", "idm", "loin", "mvd",
    }:
        print(f"unexpected facade isolation feature set: {sorted(test_features)}", file=sys.stderr)
        return 1

    original_manifest = MANIFEST.read_bytes()
    original_lockfile = LOCKFILE.read_bytes()
    killed = 0
    try:
        source = original_manifest.decode("utf-8")
        for feature, expected in test_features.items():
            foreign_package = next(
                package for package in FAMILY_PACKAGES if package not in expected
            )
            MANIFEST.write_text(
                mutate_feature(source, feature, foreign_package), encoding="utf-8"
            )
            result = run_checker()
            MANIFEST.write_bytes(original_manifest)
            if result.returncode != 1 or f"{feature}: isolation violation" not in result.stdout:
                print(
                    f"facade isolation gate failed to kill {feature!r} -> "
                    f"{foreign_package!r} mutation (exit {result.returncode})\n{result.stdout}",
                    file=sys.stderr,
                )
                return 1
            killed += 1

        clean = run_checker()
        if clean.returncode != 0:
            print(f"facade isolation checker failed after restoration:\n{clean.stdout}", file=sys.stderr)
            return 1
    finally:
        MANIFEST.write_bytes(original_manifest)
        if LOCKFILE.read_bytes() != original_lockfile:
            LOCKFILE.write_bytes(original_lockfile)

    print(f"facade isolation mutations: killed {killed}/{len(test_features)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
