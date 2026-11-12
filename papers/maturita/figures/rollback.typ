#import "style.typ": *

#let lane(y, title, tools) = node(
  (0, y),
  align(left)[#strong(title) \ #small(tools)],
  width: 4.6cm,
  stroke: none,
)

#let back(from, to, label) = edge(
  from,
  to,
  "--|>",
  text(fill: accent, small(label)),
  stroke: stroke-w + accent,
  bend: 40deg,
  label-side: center,
)

#canvas(diagram(
  spacing: (9mm, 9mm),
  edge-stroke: stroke-w + ink,
  label-size: 7.5pt,

  lane(0, [Změna na místě], [apt, dnf, Ansible \ návrat jen ručně, opačným postupem]),
  box-node((1, 0), [stav systému]),
  edge((1, 0), (3, 0), "-|>", small[přepis souborů]),
  box-node((3, 0), [změněný stav]),

  lane(1, [Snímky souborového systému], [openSUSE MicroOS]),
  box-node((1, 1), [snímek 12 \ #small[běží]]),
  edge((1, 1), (3, 1), "-|>", small[transactional-update]),
  box-node((3, 1), [snímek 13 \ #small[po restartu]]),
  back((3, 1), (1, 1), [starší snímek v zavaděči]),

  lane(2, [Obrazy systému], [Fedora Atomic / bootc]),
  box-node((1, 2), [nasazení A \ #small[běží]]),
  edge((1, 2), (3, 2), "-|>", small[nový obraz]),
  box-node((3, 2), [nasazení B \ #small[po restartu]]),
  back((3, 2), (1, 2), [bootc rollback]),

  lane(3, [Generace], [NixOS \ sdílené úložiště `/nix/store`]),
  box-node((1, 3), [gen. 41]),
  edge((1, 3), (2, 3), "-|>"),
  box-node((2, 3), [gen. 42]),
  edge((2, 3), (3, 3), "-|>", small[switch]),
  box-node((3, 3), [gen. 43 \ #small[aktivní]], fill: accent-soft, stroke: stroke-w + accent),
  back((3, 3), (1, 3), [rollback nebo starší položka v zavaděči]),
))
