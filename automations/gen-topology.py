#!/usr/bin/env python3
"""
Usage: gen-topology.py [--out DIR] [HOST ...]
"""

import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
from nixdiag import (  # noqa: E402
    REPO,
    discover_hosts,
    nix_eval,
    sanitize,
    write_and_render,
    parse_out_flag,
)

NIXOS_PROJECT = (
    "c: { "
    "tailscale = c.services.tailscale.enable or false; "
    "routes = c.services.tailscale.extraSetFlags or []; "
    "headscale = c.services.headscale.enable or false; "
    "headscalePort = c.services.headscale.port or 0; "
    "baseDomain = c.services.headscale.settings.dns.base_domain or "
    '(c.services.headscale.settings.base_domain or ""); '
    'policyPath = c.services.headscale.settings.policy.path or ""; '
    "beszelHub = c.services.beszel.hub.enable or false; "
    "beszelHubPort = c.services.beszel.hub.port or 0; "
    "beszelAgent = c.services.beszel.agent.enable or false; "
    "prometheus = c.services.prometheus.enable or false; "
    "blackbox = c.services.prometheus.exporters.blackbox.enable or false; "
    "grafana = c.services.grafana.enable or false; "
    "promTargets = builtins.concatLists (map (s: builtins.concatLists "
    "(map (sc: sc.targets or []) (s.static_configs or []))) "
    "(c.services.prometheus.scrapeConfigs or [])); "
    'vhosts = map (n: let v = c.services.nginx.virtualHosts.${n}; l = v.locations."/" or {}; in '
    "{ name = n; listen = v.listenAddresses or []; pass = l.proxyPass or null; "
    'extra = (v.extraConfig or "") + (l.extraConfig or ""); }) '
    "(builtins.attrNames (c.services.nginx.virtualHosts or {})); }"
)

DARWIN_PROJECT = (
    "c: { "
    "casks = map (x: x.name or x) (c.homebrew.casks or []); "
    "daemons = builtins.attrNames (c.launchd.daemons or {}); "
    "userAgents = builtins.attrNames (c.launchd.user.agents or {}); }"
)


COUNT_SERVICES = (
    "o: builtins.length (builtins.filter (n: "
    "let d = builtins.tryEval (o.${n}.enable.definitionsWithLocations or []); in "
    "d.success && builtins.any (e: e.value == true) d.value) "
    "(builtins.attrNames o))"
)


def resolve_upstream(pass_url, extra):
    """proxyPass + extraConfig -> 'host:port' (follows `set $var target;`)."""
    if not pass_url:
        return None
    m = re.match(r"https?://\$([A-Za-z0-9_]+)", pass_url)
    if m:
        sm = re.search(rf"set\s+\${m.group(1)}\s+([^;\s]+)\s*;", extra or "")
        return sm.group(1) if sm else None
    m2 = re.match(r"https?://([^/]+)", pass_url)
    return m2.group(1) if m2 else None


def split_host_port(hostport):
    host, _, port = hostport.rpartition(":")
    return (host, port) if host else (hostport, "")


def gather(hosts):
    facts = {}
    for host, meta in hosts.items():
        ref = f".#{meta['prefix']}.{host}.config"
        if meta["kind"] == "nixos":
            f = nix_eval(ref, NIXOS_PROJECT) or {}
            f["svc_count"] = (
                nix_eval(f".#{meta['prefix']}.{host}.options.services", COUNT_SERVICES)
                or 0
            )
        else:
            f = nix_eval(ref, DARWIN_PROJECT) or {}
            f["svc_count"] = len(f.get("daemons", [])) + len(f.get("userAgents", []))
        f["kind"] = meta["kind"]
        facts[host] = f
    return facts


def build_address_book(hosts, facts):
    base = ""
    policy_path = ""
    for f in facts.values():
        if f.get("headscale"):
            base = f.get("baseDomain", "") or base
            policy_path = f.get("policyPath", "") or policy_path
    book = {}
    if base:
        for h in hosts:
            book[f"{h}.{base}"] = h
    if policy_path and Path(policy_path).exists():
        try:
            data = json.loads(Path(policy_path).read_text())
            for name, cidr in (data.get("hosts") or {}).items():
                book[cidr.split("/")[0]] = name
        except (OSError, json.JSONDecodeError):
            pass
    return book


def generate_topology(hosts, out_dir: Path):
    facts = gather(hosts)
    book = build_address_book(hosts, facts)

    vhost_host = {}
    for host, f in facts.items():
        for vh in f.get("vhosts", []):
            vhost_host[vh["name"]] = host

    control_host = next((h for h in hosts if facts[h].get("headscale")), None)
    hub_host = next((h for h in hosts if facts[h].get("beszelHub")), None)

    def resolve(hostport, local_host):
        """'host:port' -> (host_id or None, port). 127.0.0.1 == local."""
        host, port = split_host_port(hostport)
        if host in ("127.0.0.1", "localhost", "::1", ""):
            return local_host, port
        if host in book:
            return book[host], port
        if host in vhost_host:
            return vhost_host[host], port
        return None, port

    host_nodes = {h: [] for h in hosts}
    present = set()
    edges = []
    internet_used = False
    lan_used = False

    def node(host, nid, label, cls):
        ref = f"{sanitize(host)}.{sanitize(nid)}"
        key = (host, sanitize(nid))
        if key not in present:
            present.add(key)
            safe = label.replace('"', "'").replace("\n", "\\n")
            host_nodes[host].append(f'  {sanitize(nid)}: "{safe}" {{ class: {cls} }}')
        return ref

    for host in hosts:
        f = facts[host]
        if f.get("headscale"):
            node(host, "headscale", "headscale\n(mesh control)", "infra")
        if any(
            resolve_upstream(v.get("pass"), v.get("extra")) for v in f.get("vhosts", [])
        ):
            node(host, "nginx", "nginx\n(reverse proxy)", "infra")
        if f.get("beszelHub"):
            node(host, "beszel_hub", "beszel hub", "infra")
        if f.get("prometheus"):
            node(host, "prometheus", "prometheus", "infra")
        if f.get("blackbox"):
            node(host, "blackbox", "blackbox exporter", "infra")
        if f.get("grafana"):
            node(host, "grafana", "grafana", "infra")
        if any("--advertise-routes=" in fl for fl in f.get("routes", [])):
            node(host, "subnet_router", "subnet router", "infra")

    for host in hosts:
        f = facts[host]
        local_infra = {}
        if f.get("headscale"):
            local_infra[str(f.get("headscalePort", 0))] = "headscale"
        if f.get("beszelHub"):
            local_infra[str(f.get("beszelHubPort", 0))] = "beszel_hub"
        for vh in f.get("vhosts", []):
            up = resolve_upstream(vh.get("pass"), vh.get("extra"))
            if not up:
                continue
            thost, port = resolve(up, host)
            sub = vh["name"].split(".")[0]

            public = not vh.get("listen")
            if thost == host and port in local_infra:
                app = f"{sanitize(host)}.{local_infra[port]}"
            elif thost in hosts:
                app = node(thost, sub, sub, "app")
            else:
                app = node(host, f"ext_{sub}", f"{up}", "app")
            edges.append((f"{sanitize(host)}.nginx", app, f"{sub} :{port}", "#4a76c4"))
            if public:
                internet_used = True
                edges.append(("internet", f"{sanitize(host)}.nginx", sub, "#c0392b"))

    for host in hosts:
        f = facts[host]
        member = f.get("tailscale") or any("tailscale" in c for c in f.get("casks", []))
        if member and control_host and host != control_host:
            edges.append(
                (
                    sanitize(host),
                    f"{sanitize(control_host)}.headscale",
                    "tailnet",
                    "#7a4fb5",
                )
            )

    for host in hosts:
        for fl in facts[host].get("routes", []):
            m = re.search(r"--advertise-routes=(\S+)", fl)
            if m:
                lan_used = True
                for net in m.group(1).split(","):
                    edges.append(
                        (
                            f"{sanitize(host)}.subnet_router",
                            "lan",
                            f"advertise {net}",
                            "#27893f",
                        )
                    )

    for host in hosts:
        f = facts[host]
        agent = f.get("beszelAgent") or any("beszel" in d for d in f.get("daemons", []))
        if agent and hub_host and host != hub_host:
            edges.append(
                (sanitize(host), f"{sanitize(hub_host)}.beszel_hub", "metrics", "#888")
            )

    for host in hosts:
        f = facts[host]
        if not f.get("prometheus"):
            continue
        seen = set()
        for t in f.get("promTargets", []):
            hp = re.sub(r"^https?://", "", t).rstrip("/")
            th, _ = resolve(hp, host)
            if th and th != host and th not in seen:
                seen.add(th)
                edges.append(
                    (
                        f"{sanitize(host)}.prometheus",
                        sanitize(th),
                        "scrape / probe",
                        "#888",
                    )
                )

    # --- emit ------------------------------------------------------------
    o = [
        "# Auto-generated data-flow topology from the Nix config. Do not edit.",
        "# Regenerate: nix run .#diagram (or the lefthook pre-commit hook)",
        "direction: right",
        "classes: {",
        '  app: { style: { fill: "#e6f0ff"; stroke: "#4a76c4" } }',
        '  infra: { style: { fill: "#ffe9cc"; stroke: "#c47a29" } }',
        '  base: { style: { fill: "#f0f0f0"; stroke: "#999"; font-size: 13 } }',
        "}",
        "",
    ]
    if internet_used:
        o.append('internet: "🌐 Internet" { shape: cloud; style.fill: "#fdecea" }')
    if lan_used:
        o.append('lan: "🏠 LAN" { shape: cloud; style.fill: "#eafaf1" }')
    o.append("")
    for host in hosts:
        f = facts[host]
        icon = "🍏" if f["kind"] == "darwin" else "🖥️"
        host_nodes[host].append(
            f'  base: "+ {f.get("svc_count", 0)} system services" {{ class: base }}'
        )
        o.append(f'{sanitize(host)}: "{icon} {host}" {{')
        o.append('  style: { fill: "#fbfbfe"; stroke: "#333"; bold: true }')
        o.extend(host_nodes[host])
        o.append("}")
    o.append("")
    o.append("# data-flow edges")
    for a, b, label, color in edges:
        lbl = label.replace('"', "'")
        o.append(f'{a} -> {b}: "{lbl}" {{ style.stroke: "{color}" }}')

    write_and_render(out_dir, "topology", o)


def main():
    args = sys.argv[1:]
    out_dir = parse_out_flag(args, REPO / "docs")
    all_hosts = discover_hosts()
    hosts = {h: all_hosts[h] for h in args} if args else all_hosts
    unknown = [h for h in args if h not in all_hosts]
    if unknown:
        sys.exit(f"unknown host(s): {unknown}; known: {list(all_hosts)}")
    generate_topology(hosts, out_dir)


if __name__ == "__main__":
    main()
