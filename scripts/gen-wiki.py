#!/usr/bin/env python3
import shutil
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
from nixdiag import (  # noqa: E402
    REPO,
    discover_hosts,
    nix_eval,
    rel_from_store,
    parse_out_flag,
)

AUTO = "<!-- Auto-generated from the Nix config by gen-wiki.py. Do not edit. -->"

HOST_FACTS = (
    "c: { "
    'platform = c.nixpkgs.hostPlatform.system or ""; '
    'stateVersion = builtins.toString (c.system.stateVersion or ""); '
    "tcp = c.networking.firewall.allowedTCPPorts or []; "
    "udp = c.networking.firewall.allowedUDPPorts or []; "
    "users = builtins.filter (n: c.users.users.${n}.isNormalUser or false) "
    "(builtins.attrNames (c.users.users or {})); "
    "pkgCount = builtins.length (c.environment.systemPackages or []); "
    "vhosts = map (n: let v = c.services.nginx.virtualHosts.${n}; in "
    "{ name = n; listen = v.listenAddresses or []; }) "
    "(builtins.attrNames (c.services.nginx.virtualHosts or {})); "
    "}"
)


DARWIN_FACTS = (
    "c: { "
    "daemons = builtins.attrNames (c.launchd.daemons or {}); "
    "userAgents = builtins.attrNames (c.launchd.user.agents or {}); "
    "casks = map (x: x.name or x) (c.homebrew.casks or []); "
    "}"
)


ENABLED_WITH_FILES = (
    "o: builtins.filter (x: x != null) (map (n: "
    "let d = builtins.tryEval (o.${n}.enable.definitionsWithLocations or []); "
    "defs = if d.success then d.value else []; "
    "on = builtins.filter (e: e.value == true) defs; in "
    "if on != [] then { name = n; files = map (e: e.file) on; } else null) "
    "(builtins.attrNames o))"
)


def repo_files(store_files):
    """Keep only definition files that resolve inside this repo, repo-relative."""
    out = []
    for f in store_files:
        rel = rel_from_store(f)
        if rel is None:
            continue
        if (REPO / rel).is_dir():
            rel = f"{rel}/default.nix"
        if (REPO / rel).exists() and rel not in out:
            out.append(rel)
    return out


def gather(hosts):
    data = {}
    for host, meta in hosts.items():
        if meta["kind"] == "darwin":
            facts = nix_eval(f".#{meta['prefix']}.{host}.config", DARWIN_FACTS) or {}
        else:
            facts = nix_eval(f".#{meta['prefix']}.{host}.config", HOST_FACTS) or {}
            svcs = {}
            for item in (
                nix_eval(
                    f".#{meta['prefix']}.{host}.options.services", ENABLED_WITH_FILES
                )
                or []
            ):
                files = repo_files(item.get("files", []))
                if files:  # only services this repo actually configures
                    svcs[item["name"]] = files
            facts["services"] = svcs
        facts["kind"] = meta["kind"]
        data[host] = facts
    return data


def write(path: Path, text: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.rstrip() + "\n")
    print(f"wrote {path}")


def write_once(path: Path, text: str):
    if path.exists():
        return
    write(path, text)


def fmt_ports(ports):
    return ", ".join(str(p) for p in ports) if ports else "—"


def book_toml(wiki: Path):
    write_once(
        wiki / "book.toml",
        "[book]\n"
        'title = "kucendro infrastructure wiki"\n'
        'authors = ["Ondřej Kučera"]\n'
        'src = "src"\n\n'
        "[output.html]\n"
        'default-theme = "navy"\n'
        'preferred-dark-theme = "navy"\n'
        "no-section-label = true\n",
    )


def page_summary(src: Path):
    write(
        src / "SUMMARY.md",
        "# Summary\n\n"
        "- [Overview](./index.md)\n"
        "- [Architecture](./architecture.md)\n"
        "- [Hosts](./hosts.md)\n"
        "- [Services](./services.md)\n"
        "- [Endpoints](./endpoints.md)\n",
    )


def page_index(src: Path):
    write_once(
        src / "index.md",
        "# Infrastructure wiki\n\n"
        "_Hand-written overview goes here_ — the big picture, where a newcomer "
        "should start, and *why* things are the way they are.\n\n"
        "Everything else in this wiki (Architecture, Hosts, Services, Endpoints) "
        "is **auto-generated from the NixOS configuration** on every commit, so "
        "it is always current. This page is the one you edit by hand.\n",
    )


def page_architecture(src: Path, out_dir: Path):
    for svg in ("topology.svg", "modules.svg"):
        s = out_dir / svg
        if s.exists():
            shutil.copyfile(s, src / svg)
    write(
        src / "architecture.md",
        f"{AUTO}\n\n"
        "# Architecture\n\n"
        "## Data-flow topology\n\n"
        "What talks to what across the fleet.\n\n"
        "![Data-flow topology](./topology.svg)\n\n"
        "## Module tree\n\n"
        "How each host is assembled from the module files in this repo.\n\n"
        "![Module tree](./modules.svg)\n",
    )


def page_hosts(src: Path, data: dict):
    out = [AUTO, "", "# Hosts", ""]
    for host, f in data.items():
        if f.get("kind") == "darwin":
            out += _host_darwin(host, f)
        else:
            out += _host_nixos(host, f)
    write(src / "hosts.md", "\n".join(out))


def _host_nixos(host, f):
    svcs = f.get("services") or {}
    out = [
        f"## 🖥️ {host}",
        "",
        "| | |",
        "|---|---|",
        f"| Platform | `{f.get('platform') or '?'}` |",
    ]
    if f.get("stateVersion"):
        out.append(f"| State version | `{f['stateVersion']}` |")
    out += [
        f"| Users | {', '.join(f.get('users') or []) or '—'} |",
        f"| System packages | {f.get('pkgCount', '?')} |",
        f"| Open TCP ports | {fmt_ports(f.get('tcp'))} |",
        f"| Open UDP ports | {fmt_ports(f.get('udp'))} |",
        f"| Repo-configured services | {len(svcs)} |",
        "",
    ]
    if svcs:
        out += ["**Services** (configured in this repo):", ""]
        for name in sorted(svcs):
            files = " ".join(f"`{x}`" for x in svcs[name])
            out.append(f"- **{name}** — {files}")
        out.append("")
    return out


def _host_darwin(host, f):
    out = [f"## 🍏 {host}", "", "_nix-darwin host._", ""]
    for title, items in (
        ("LaunchDaemons", f.get("daemons")),
        ("User agents", f.get("userAgents")),
        ("Homebrew casks", f.get("casks")),
    ):
        if items:
            out.append(f"**{title}:** {', '.join(sorted(items))}")
            out.append("")
    return out


def page_services(src: Path, data: dict):
    index = {}  # name -> {hosts:set, files:set}
    for host, f in data.items():
        for name, files in (f.get("services") or {}).items():
            e = index.setdefault(name, {"hosts": set(), "files": set()})
            e["hosts"].add(host)
            e["files"].update(files)
    out = [
        AUTO,
        "",
        "# Services",
        "",
        "Every service this repo configures, the host(s) that run it, and the "
        "file that defines it.",
        "",
        "| Service | Hosts | Defined in |",
        "|---|---|---|",
    ]
    for name in sorted(index):
        e = index[name]
        hosts = ", ".join(sorted(e["hosts"]))
        files = " ".join(f"`{x}`" for x in sorted(e["files"]))
        out.append(f"| **{name}** | {hosts} | {files} |")
    if not index:
        out.append("| — | — | — |")
    write(src / "services.md", "\n".join(out))


def page_endpoints(src: Path, data: dict):
    out = [
        AUTO,
        "",
        "# Endpoints",
        "",
        "nginx virtual hosts across the fleet. *tailnet* endpoints are bound to "
        "the mesh IP and only reachable over Tailscale; *public* ones listen on "
        "all interfaces.",
        "",
        "| Endpoint | Scope | Host |",
        "|---|---|---|",
    ]
    rows = []
    for host, f in data.items():
        for v in f.get("vhosts") or []:
            scope = "tailnet" if (v.get("listen") or []) else "public"
            rows.append((v["name"], scope, host))
    for name, scope, host in sorted(rows):
        out.append(f"| `{name}` | {scope} | {host} |")
    if not rows:
        out.append("| — | — | — |")
    write(src / "endpoints.md", "\n".join(out))


def main():
    args = sys.argv[1:]
    out_dir = parse_out_flag(args, REPO / "docs")
    wiki = out_dir / "wiki"
    src = wiki / "src"

    all_hosts = discover_hosts()
    hosts = {h: all_hosts[h] for h in args} if args else all_hosts
    unknown = [h for h in args if h not in all_hosts]
    if unknown:
        sys.exit(f"unknown host(s): {unknown}; known: {list(all_hosts)}")

    data = gather(hosts)
    book_toml(wiki)
    page_summary(src)
    page_index(src)
    page_architecture(src, out_dir)
    page_hosts(src, data)
    page_services(src, data)
    page_endpoints(src, data)


if __name__ == "__main__":
    main()
