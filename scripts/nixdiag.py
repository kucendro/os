"""
Shared helpers for the auto-derived config diagrams (gen-diagram.py /
gen-topology.py). Nothing host-, domain-, or service-specific lives here or in
the generators: the host list, addresses and module layout are all read out of
the flake and the evaluated config, so growing the config needs no edits.
"""

import json
import re
import shutil
import subprocess
import sys
from pathlib import Path


def find_repo() -> Path:
    """Flake root. Prefer the invocation cwd (this file may live in a read-only
    store path when run via `nix run`)."""
    for base in (Path.cwd(), Path(__file__).resolve().parent.parent):
        p = base
        while True:
            if (p / "flake.nix").exists():
                return p
            if p.parent == p:
                break
            p = p.parent
    return Path(__file__).resolve().parent.parent


REPO = find_repo()


def nix_eval(ref: str, apply: str | None = None, timeout: int = 600):
    """`nix eval --json REF [--apply APPLY]` -> parsed JSON, or None on error."""
    cmd = ["nix", "eval", "--json", ref]
    if apply is not None:
        cmd += ["--apply", apply]
    try:
        r = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        print(f"  ! eval {ref}: timed out", file=sys.stderr)
        return None
    if r.returncode != 0:
        tail = r.stderr.strip().splitlines()[-1:] if r.stderr else ["(no stderr)"]
        print(f"  ! eval {ref}: {tail}", file=sys.stderr)
        return None
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError:
        return None


def discover_hosts() -> dict:
    """Every host in the flake -> {prefix, kind}. Fully dynamic."""
    hosts = {}
    for prefix, kind in (("nixosConfigurations", "nixos"),
                         ("darwinConfigurations", "darwin")):
        for name in nix_eval(f".#{prefix}", "builtins.attrNames") or []:
            hosts[name] = {"prefix": prefix, "kind": kind}
    return hosts


def sanitize(seg: str) -> str:
    return re.sub(r'[^A-Za-z0-9_]', '_', seg)


def rel_from_store(path: str):
    """/nix/store/HASH-source/services/x.nix -> services/x.nix (None if the
    path is not inside a flake source tree)."""
    marker = "-source/"
    i = path.find(marker)
    return None if i == -1 else path[i + len(marker):]


def write_and_render(out_dir: Path, stem: str, lines, layout: str = "elk"):
    out_dir.mkdir(parents=True, exist_ok=True)
    d2_file = out_dir / f"{stem}.d2"
    d2_file.write_text("\n".join(lines) + "\n")
    print(f"wrote {d2_file}")
    d2bin = shutil.which("d2")
    if not d2bin:
        print("(d2 binary not on PATH -- skipped SVG render)")
        return
    svg = out_dir / f"{stem}.svg"
    # elk handles many nodes far better than the default dagre layout
    r = subprocess.run([d2bin, "--layout", layout, str(d2_file), str(svg)],
                       capture_output=True, text=True)
    if r.returncode == 0:
        print(f"wrote {svg}")
    else:
        print(f"d2 render failed:\n{r.stderr}", file=sys.stderr)


def parse_out_flag(args, default: Path):
    """Pull `--out DIR` out of an argv list, mutating it. Returns the dir."""
    if "--out" in args:
        i = args.index("--out")
        d = Path(args[i + 1]).resolve()
        del args[i:i + 2]
        return d
    return default
