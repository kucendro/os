#import "layout.typ": hang, head-above, head-below, head-size, sans

#let heading-rule(it) = {
  let level = it.level
  if level == 1 { pagebreak(weak: true) }
  block(above: head-above.at(level - 1), below: head-below.at(level - 1), {
    set text(font: sans, size: head-size.at(level - 1), weight: "bold")
    set par(justify: false, first-line-indent: 0pt, hanging-indent: hang)
    if it.numbering != none { box(width: hang, counter(heading).display(it.numbering)) }
    it.body
  })
}
