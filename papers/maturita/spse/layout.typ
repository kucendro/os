#let serif = ("Times New Roman", "Liberation Serif")
#let sans = ("Arial", "Liberation Sans")

#let font-ascent = 1824 / 2048
#let font-descent = 443 / 2048
#let font-line-gap = 87 / 2048
#let line-step = 1.35 * (font-ascent + font-descent + font-line-gap)
#let top-edge = (font-ascent + font-line-gap) * 1em
#let bottom-edge = (font-ascent + font-line-gap - line-step) * 1em

#let margins = (top: 25mm, left: 30mm, right: 20mm, bottom: 25mm)
#let text-width = 210mm - margins.left - margins.right

#let body-size = 13pt
#let head-size = (body-size + 4pt, body-size + 2pt, body-size)
#let front-size = 14pt
#let front-head = 16pt
#let toc-small = body-size - 2pt

#let para-gap = 12pt
#let hang = 1.25cm
#let head-above = (20pt, 24pt, 24pt)
#let head-below = (30pt, 18pt, 18pt)

#let toc-indent = (0cm, 0.42cm, 1.25cm)
#let toc-number-width = (1.25cm, 0.83cm, 0.9cm)
#let toc-above = (12pt, 6pt, 0pt)

#let table-width = text-width
#let cell-pad = 5.4pt
#let sig-tab = 13cm
#let author-tab = text-width
#let footer-tab = text-width / 2
#let footer-descent = 8.5pt

#let blank-lines(n) = v(n * line-step * body-size)
#let empty-par = block(height: line-step * 1em)
#let center-at(pos, body) = context place(left, dx: pos - measure(body).width / 2, body)
#let dots(n) = "." * n
