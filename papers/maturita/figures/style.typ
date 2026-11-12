#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "../spse/layout.typ": sans

#let ink = black
#let paper = white
#let soft = luma(240)
#let mid = luma(215)
#let accent = rgb("#2f5d8a")
#let accent-soft = rgb("#e3ebf3")
#let stroke-w = 0.6pt

#let canvas(body) = {
  set text(font: sans, size: 9pt, hyphenate: false, top-edge: "cap-height", bottom-edge: "baseline")
  set par(justify: false, first-line-indent: 0pt, leading: 0.45em)
  body
}

#let small(body) = text(size: 7.5pt, body)

#let box-node(pos, body, fill: soft, ..args) = node(
  pos,
  align(center, body),
  fill: fill,
  stroke: stroke-w + ink,
  shape: fletcher.shapes.rect,
  corner-radius: 2pt,
  inset: 6pt,
  ..args,
)

#let pill(body, fill: paper, stroke: stroke-w + ink) = box(
  fill: fill,
  stroke: stroke,
  radius: 2pt,
  inset: (x: 5pt, y: 3pt),
  body,
)
