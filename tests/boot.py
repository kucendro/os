def skipped(name: str) -> bool:
    return any(
        name == s or name.startswith(f"{s}-") or name.endswith(f"-{s}") for s in skip
    )


def listening() -> set[str]:
    lines = machine.succeed("ss -Htuln").splitlines()
    return {f"{line.split()[0]}/{line.split()[4].rsplit(':', 1)[1]}" for line in lines}


machine.start()
try:
    machine.wait_for_unit("multi-user.target")
except Exception:
    print(machine.succeed("systemctl list-jobs --no-pager"))
    raise
machine.sleep(60)

failed = machine.succeed(
    "systemctl list-units --state=failed,auto-restart --plain --no-legend | cut -d' ' -f1"
).split()
broken = [unit for unit in failed if not skipped(unit.removesuffix(".service"))]
for unit in broken:
    print(machine.succeed(f"journalctl -b -u {unit} -n 40 --no-pager"))

expected = {
    socket for name, sockets in ports.items() if not skipped(name) for socket in sockets
}
missing = expected - listening()
for _ in range(60):
    if not missing:
        break
    machine.sleep(5)
    missing = expected - listening()

print(machine.succeed("free -m"))

assert not broken and not missing, (
    f"failed units: {' '.join(broken) or 'none'}, "
    f"not listening: {' '.join(sorted(missing)) or 'none'}"
)
