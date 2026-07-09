#!/usr/bin/env python3
"""
Auto-derive a D2 diagram of the module import tree from the Nix config.

Two signals, both read from the config (nothing host-specific baked in):

  1. Static import graph  -- parse `imports = [ ... ]` across the .nix files,
     starting from each host's target/hardware module (discovered from the
     flake, not a hard-coded table). This is the parent/child module tree.

  2. Evaluated provenance -- `nix eval` the merged config and, for every enabled
     services.*.enable / programs.*.enable, read definitionsWithLocations to
     find the file that turned it on. These become leaves under their file.

Output: docs/modules.d2 (+ docs/modules.svg if the `d2` binary is present).

Usage: gen-diagram.py [--out DIR] [HOST ...]
"""

import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
from nixdiag import (  # noqa: E402
    REPO, discover_hosts, nix_eval, sanitize, rel_from_store, write_and_render,
    parse_out_flag,
)

IMPORT_TOKEN = re.compile(r'\.\.?/[^\s\]"\';]+')

# Keep every <name> whose `enable` has a definition set to true, with the files
# those definitions came from. We read enable.definitionsWithLocations (per-def
# {file,value}) rather than the merged enable.value: the merged value forces
# submodule assertions and some renamed-option aliases (services.frp, ...)
# `abort` when forced, which tryEval cannot catch. Per-definition reads are
# abort-free and yield provenance in one pass.
ENABLED_WITH_FILES = (
    'o: builtins.filter (x: x != null) (map (n: '
    'let d = builtins.tryEval (o.${n}.enable.definitionsWithLocations or []); '
    'defs = if d.success then d.value else []; '
    'on = builtins.filter (e: e.value == true) defs; in '
    'if on != [] then { name = n; files = map (e: e.file) on; } else null) '
    '(builtins.attrNames o))'
)


# --- discover each host's entry + hardware module from the flake -----------

def host_entry_modules(host: str, flake_text: str):
    """Parse flake.nix for `<host> = { targetModule = ...; hardwareModule = ...; }`
    and resolve the referenced paths. Returns a list of repo-relative .nix files."""
    m = re.search(rf'\b{re.escape(host)}\s*=\s*\{{(.*?)\n\s*\}};', flake_text, re.DOTALL)
    block = m.group(1) if m else ""
    files = []
    for key in ("targetModule", "hardwareModule"):
        km = re.search(rf'{key}\s*=\s*(\.\S+?)\s*;', block)
        if km:
            p = (REPO / km.group(1)).resolve()
            if p.is_dir():
                p = p / "default.nix"
            elif p.suffix != ".nix":
                p = p.with_suffix(".nix")
            if p.exists():
                files.append(p)
    if not files:  # convention fallback
        cand = REPO / "targets" / host / "default.nix"
        if cand.exists():
            files.append(cand)
    return files


# --- static import graph ---------------------------------------------------

def resolve(base: Path, token: str):
    p = (base.parent / token).resolve()
    if p.is_dir():
        p = p / "default.nix"
    if p.suffix != ".nix":
        p = p.with_suffix(".nix")
    return p


def parse_imports(nix_file: Path):
    try:
        text = nix_file.read_text()
    except OSError:
        return []
    out = []
    for m in re.finditer(r'imports\s*=', text):
        seg = text[m.end():]
        semi = seg.find(";")
        seg = seg[:semi] if semi != -1 else seg
        out.extend(IMPORT_TOKEN.findall(seg))
    return out


def build_import_graph(entries):
    """BFS the import graph from entry files. Returns (nodes, edges) as
    repo-relative path strings."""
    nodes, edges, seen = set(), set(), set()
    stack = list(entries)
    while stack:
        f = stack.pop()
        rf = f.relative_to(REPO).as_posix() if f.is_relative_to(REPO) else str(f)
        if rf in seen:
            continue
        seen.add(rf)
        nodes.add(rf)
        for tok in parse_imports(f):
            child = resolve(f, tok)
            if not child.exists():
                continue
            rc = child.relative_to(REPO).as_posix() if child.is_relative_to(REPO) else str(child)
            nodes.add(rc)
            edges.add((rf, rc))
            stack.append(child)
    return nodes, edges


def d2_path(rel: str) -> str:
    return ".".join(sanitize(s) for s in rel.split("/"))


class Tree:
    """Nested directory container tree for emitting D2."""
    def __init__(self):
        self.dirs = {}
        self.files = {}

    def add_file(self, rel: str):
        parts = rel.split("/")
        node = self
        for d in parts[:-1]:
            node = node.dirs.setdefault(d, Tree())
        return node.files.setdefault(parts[-1], {"label": parts[-1], "svcs": [], "progs": []})

    def emit(self, out, indent=0):
        pad = "  " * indent
        for name, sub in sorted(self.dirs.items()):
            out.append(f'{pad}{sanitize(name)}: "{name}" {{')
            sub.emit(out, indent + 1)
            out.append(f'{pad}}}')
        for fname, meta in sorted(self.files.items()):
            fid = sanitize(fname)
            if not (meta["svcs"] or meta["progs"]):
                out.append(f'{pad}{fid}: "{fname}" {{ shape: page }}')
                continue
            out.append(f'{pad}{fid}: "{fname}" {{ shape: page')
            for s in sorted(meta["svcs"]):
                out.append(f'{pad}  svc_{sanitize(s)}: "{s}" {{ shape: oval; style.fill: "#e6f0ff" }}')
            for p in sorted(meta["progs"]):
                out.append(f'{pad}  prog_{sanitize(p)}: "{p}" {{ shape: hexagon; style.fill: "#eaffea" }}')
            out.append(f'{pad}}}')


def generate_modules(hosts, out_dir: Path):
    tree = Tree()
    host_edges = []
    import_edges = set()
    flake_text = (REPO / "flake.nix").read_text()

    for host, meta in hosts.items():
        entries = host_entry_modules(host, flake_text)
        nodes, edges = build_import_graph(entries)
        for n in nodes:
            tree.add_file(n)
        for a, b in edges:
            import_edges.add((d2_path(a), d2_path(b)))
        for e in entries:
            host_edges.append((host, d2_path(e.relative_to(REPO).as_posix())))

        # provenance -> attach enabled services/programs to their defining file
        for kind, group in (("svcs", "services"), ("progs", "programs")):
            ref = f".#{meta['prefix']}.{host}.options.{group}"
            for item in nix_eval(ref, ENABLED_WITH_FILES) or []:
                for f in item.get("files", []):
                    rel = rel_from_store(f)
                    if rel is None or not (REPO / rel).exists():
                        continue  # nixpkgs internals, not this repo
                    if (REPO / rel).is_dir():  # dir-imported module -> default.nix
                        rel = f"{rel}/default.nix"
                        if not (REPO / rel).exists():
                            continue
                    m = tree.add_file(rel)
                    if item["name"] not in m[kind]:
                        m[kind].append(item["name"])

    out = [
        "# Auto-generated from the Nix config. Do not edit by hand.",
        "# Regenerate: nix run .#diagram (or the lefthook pre-commit hook)",
        "direction: right",
        "",
    ]
    for host in hosts:
        out.append(f'{sanitize(host)}: "{host}" {{ shape: cloud; style.fill: "#fff3cd"; style.bold: true }}')
    out.append("")
    tree.emit(out)
    out.append("")
    out.append("# host -> entry module")
    for host, fid in host_edges:
        out.append(f'{sanitize(host)} -> {fid}')
    out.append("")
    out.append("# module imports")
    for a, b in sorted(import_edges):
        out.append(f'{a} -> {b}')

    write_and_render(out_dir, "modules", out)


def main():
    args = sys.argv[1:]
    out_dir = parse_out_flag(args, REPO / "docs")
    all_hosts = discover_hosts()
    hosts = {h: all_hosts[h] for h in args} if args else all_hosts
    unknown = [h for h in args if h not in all_hosts]
    if unknown:
        sys.exit(f"unknown host(s): {unknown}; known: {list(all_hosts)}")
    generate_modules(hosts, out_dir)


if __name__ == "__main__":
    main()
