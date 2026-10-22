#import "layout.typ": front-size, sans, toc-above, toc-indent, toc-number-width, toc-small

#let outline-entry(it) = {
  let level = it.level
  let number-width = toc-number-width.at(level - 1)
  let prefix = it.prefix()
  block(above: toc-above.at(level - 1), below: 0pt, pad(left: toc-indent.at(level - 1), {
    set text(..if level == 3 { (size: toc-small, style: "italic") } else { (weight: "bold") })
    set par(
      justify: false,
      first-line-indent: 0pt,
      hanging-indent: if prefix == none { 0pt } else { number-width },
    )
    link(it.element.location(), {
      if prefix != none { box(width: number-width, prefix) }
      if level == 3 { it.body() } else { upper(it.body()) }
      box(width: 1fr, repeat[.])
      it.page()
    })
  }))
}

#let contents-page() = {
  {
    set text(font: sans, size: front-size, weight: "bold")
    [Obsah]
  }
  outline(title: none, depth: 3)
}
