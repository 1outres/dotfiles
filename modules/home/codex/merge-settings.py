"""Merge managed preferences into Codex's writable local configuration."""

import os
import sys
import tempfile
from collections.abc import Mapping
from pathlib import Path

import tomlkit


def merge(destination, source):
    for key, value in source.items():
        if isinstance(value, Mapping) and isinstance(destination.get(key), Mapping):
            merge(destination[key], value)
        else:
            destination[key] = value


def apply(source, target):
    if target.is_symlink():
        raise ValueError(f"Refusing to replace a symlink: {target}")
    original = target.read_text() if target.exists() else ""
    document = tomlkit.parse(original)
    merge(document, tomlkit.parse(source.read_text()))
    updated = tomlkit.dumps(document)
    if updated == original:
        return

    target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    if target.exists():
        descriptor, backup = tempfile.mkstemp(
            prefix="config.toml.backup-", dir=target.parent
        )
        with os.fdopen(descriptor, "w") as output:
            output.write(original)
        print(f"Codex configuration backup: {backup}")

    descriptor, temporary = tempfile.mkstemp(prefix=".config.toml-", dir=target.parent)
    try:
        with os.fdopen(descriptor, "w") as output:
            output.write(updated)
        os.replace(temporary, target)
    finally:
        Path(temporary).unlink(missing_ok=True)


if __name__ == "__main__":
    apply(Path(sys.argv[1]), Path(sys.argv[2]))
