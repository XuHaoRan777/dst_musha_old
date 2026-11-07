"""Run slow integration checks against the installed DST Lua sources (no game writes)."""

import argparse
from pathlib import Path
import subprocess
import tempfile
import zipfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scripts-zip", required=True, type=Path)
    parser.add_argument("--lua", default="lua")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    with tempfile.TemporaryDirectory(prefix="musha-native-slow-") as folder:
        with zipfile.ZipFile(args.scripts_zip) as archive:
            for name in ("class.lua", "util/sourcemodifierlist.lua", "components/locomotor.lua"):
                target = Path(folder) / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(archive.read("scripts/" + name))
        result = subprocess.run(
            [args.lua, "tools/tests/test_combat_slow_native.lua", Path(folder).as_posix()],
            cwd=root,
            check=False,
        )
        return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
