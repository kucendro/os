#import "spse/layout.typ": *
#import "spse/headings.typ": heading-rule
#import "spse/toc.typ": contents-page, outline-entry
#import "spse/front.typ": abstract-page, assignment-page, declaration-page, title-page

#let spse-doc(
  title: [NÁZEV MATURITNÍ PRÁCE],
  kind: [MATURITNÍ PRÁCE – WEBOVÉ STRÁNKY],
  date: [březen rok],
  author: [jméno, příjmení a třída],
  city: [Pardubicích],
  abstract-cs: [],
  keywords-cs: [],
  abstract-en: [],
  keywords-en: [],
  body,
) = {
  set page(paper: "a4", margin: margins)
  set text(font: serif, size: body-size, lang: "cs", region: "cz", hyphenate: false, top-edge: top-edge, bottom-edge: bottom-edge)
  show regex(" [aAiIkKoOsSuUvVzZ] "): it => [ #it.text.trim()~]
  set par(leading: 0pt, spacing: para-gap, justify: true, first-line-indent: (amount: hang, all: true))
  set block(spacing: para-gap)
  set heading(numbering: "1.1.1")
  show link: it => if type(it.dest) == str { underline(text(fill: rgb("#0000FF"), it)) } else { it }
  show outline.entry: outline-entry
  show heading: heading-rule

  {
    set par(spacing: 0pt, justify: false, first-line-indent: 0pt)
    set block(spacing: 0pt)

    title-page(kind, title, date, author)
    pagebreak()
    declaration-page(city)
    pagebreak()
    assignment-page[PRVNÍ]
    pagebreak()
    assignment-page[DRUHÁ]
    pagebreak()
    v(6pt)
    v(line-step * front-size)
    abstract-page([Anotace], abstract-cs, [Klíčová slova:], keywords-cs)
    pagebreak()
    abstract-page([Annotation], abstract-en, [Keywords:], keywords-en)
    pagebreak()
    contents-page()
  }

  set page(
    footer: box(width: 2 * footer-tab, align(center)[– #context counter(page).display() –]),
    footer-descent: footer-descent,
  )
  body
}
