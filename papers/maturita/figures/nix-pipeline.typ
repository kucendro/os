#import "style.typ": *

#let phase(y, body) = node((0, y), text(fill: accent, strong(body)), stroke: none)

#canvas(diagram(
  spacing: (8mm, 6mm),
  edge-stroke: stroke-w + ink,
  label-size: 7.5pt,

  phase(0.5, [1 vyhodnocení]),
  phase(2, [2 realizace]),
  phase(4.5, [3 použití]),

  box-node((1, 0), [*Deklarace systému* \ #small[`flake.nix` + `flake.lock` (zamčené verze vstupů)]], width: 5.4cm),
  edge("-|>"),
  box-node((1, 1), [*Derivace* (`.drv`) \ #small[přesný recept: vstupy, sestavovací skript, prostředí]], width: 5.4cm),
  edge("-|>"),
  box-node((1, 2), [Existuje výsledek lokálně \ nebo v binární cache?], fill: paper, width: 5.4cm),
  edge((1, 2), (0, 3), "-|>", small[ano], label-side: left),
  edge((1, 2), (2, 3), "-|>", small[ne], label-side: right),
  box-node((0, 3), [*Stažení* \ #small[ověření kryptografického podpisu]], width: 3.8cm),
  box-node((2, 3), [*Sestavení v sandboxu* \ #small[bez sítě, jen deklarované vstupy]], width: 3.8cm),
  edge((0, 3), (1, 4), "-|>"),
  edge((2, 3), (1, 4), "-|>"),
  box-node(
    (1, 4),
    [`/nix/store/<hash>-název` \ #small[neměnný výsledek, hash odvozený ze všech vstupů]],
    fill: accent-soft,
    stroke: stroke-w + accent,
    width: 5.4cm,
  ),
  edge("-|>"),
  box-node((1, 5), [*Nová generace systému* \ #small[atomické přepnutí, položka v zavaděči]], width: 5.4cm),
))
