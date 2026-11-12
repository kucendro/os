#import "style.typ": *

#let panel(title, subtitle, body) = block(width: 100%, {
  align(center)[#strong(title) \ #small(subtitle)]
  v(6pt)
  align(center, body)
})

#let step(pos, body) = box-node(pos, small(body), fill: paper, inset: 4pt)

#let imperative = diagram(
  spacing: (5mm, 5mm),
  edge-stroke: stroke-w + ink,
  box-node((0.5, 0), [výchozí instalace]),
  edge((0.5, 0), (0, 1), "-|>"),
  edge((0.5, 0), (1, 1), "-|>"),
  step((0, 1), [\+ balíček X]),
  step((1, 1), [\+ úprava konfigurace]),
  edge((0, 1), (0, 2), "-|>"),
  edge((1, 1), (1, 2), "-|>"),
  step((0, 2), [\+ úprava konfigurace]),
  step((1, 2), [\+ ruční oprava]),
  edge((0, 2), (0, 3), "-|>"),
  edge((1, 2), (1, 3), "-|>"),
  box-node((0, 3), [hostitel A]),
  box-node((1, 3), [hostitel B]),
  edge((0, 3), (1, 3), "<|-|>", small[A ≠ B], label-side: left, stroke: (paint: ink, dash: "dashed", thickness: stroke-w)),
)

#let declarative = diagram(
  spacing: (5mm, 5mm),
  edge-stroke: stroke-w + ink,
  box-node((0.5, 0), [konfigurace v gitu \ #small[verze N]], fill: accent-soft, stroke: stroke-w + accent),
  edge((0.5, 0), (0.5, 1), "-|>", small[sestavení], label-side: left),
  step((0.5, 1), [jeden výsledek \ `/nix/store/<hash>-system`]),
  edge((0.5, 1), (0, 2), "-|>"),
  edge((0.5, 1), (1, 2), "-|>"),
  box-node((0, 2), [hostitel A \ #small[generace N]]),
  box-node((1, 2), [hostitel B \ #small[generace N]]),
  edge((0, 2), (1, 2), "<|-|>", small[A = B], label-side: left, stroke: (paint: accent, thickness: stroke-w)),
  node((0.5, 3), small[verze N+1 vytvoří novou generaci, \ návrat na N je kdykoli možný], stroke: none),
)

#canvas(grid(
  columns: (1fr, 1fr),
  column-gutter: 6mm,
  panel([Imperativní správa], [stav = výchozí instalace + historie změn], imperative),
  panel([Deklarativní správa], [stav = funkce konfigurace], declarative),
))
