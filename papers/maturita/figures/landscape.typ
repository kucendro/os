#import "style.typ": *

#let rows = (
  ([Správa balíčků], [nixpkgs], ([apt / dnf], [Homebrew], [conda / pixi])),
  ([Sestavování softwaru], [derivace, `nix build`], ([Bazel], [Buck2], [Dockerfile])),
  ([Vývojové prostředí], [`nix develop`], ([Dev Containers], [mise / asdf])),
  ([Konfigurace systému], [moduly NixOS], ([Ansible], [Puppet], [Salt])),
  ([Neměnný systém a návrat], [generace NixOS], ([Fedora Atomic / bootc], [openSUSE MicroOS], [Talos])),
  ([Nasazování na více strojů], [deploy-rs, comin], ([Kubernetes], [Ansible], [bootc switch])),
)

#canvas(table(
  columns: (auto, 3.6cm, 1fr),
  align: (left + horizon, center + horizon, left + horizon),
  inset: (x: 6pt, y: 5pt),
  stroke: (x, y) => if y > 0 { (top: 0.4pt + mid) },
  fill: (x, y) => if x == 1 and y > 0 { accent-soft },
  table.header(
    strong[Role],
    text(fill: accent, strong[Nix / NixOS]),
    strong[Specializované alternativy],
  ),
  ..rows
    .map(((role, nix, alts)) => (
      strong(role),
      text(fill: accent, nix),
      alts.map(pill).join(h(4pt)),
    ))
    .flatten(),
))
