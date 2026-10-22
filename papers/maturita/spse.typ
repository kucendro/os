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
#let table-width = text-width
#let cell-pad = 5.4pt
#let sig-tab = 13cm
#let author-tab = text-width
#let footer-tab = text-width / 2

#let blank-lines(n) = v(n * line-step * body-size)
#let empty-par = block(height: line-step * 1em)
#let center-at(pos, body) = context place(left, dx: pos - measure(body).width / 2, body)
#let dots(n) = "." * n

#let outline-entry(it) = {
  let level = it.level
  let indent = (0cm, 0.42cm, 1.25cm).at(level - 1)
  let number-width = (1.25cm, 0.83cm, 0.9cm).at(level - 1)
  let prefix = it.prefix()
  block(above: (12pt, 6pt, 0pt).at(level - 1), below: 0pt, pad(left: indent, {
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

#let title-page(kind, title, date, author) = {
  align(center, {
    set text(size: front-size)
    [Střední průmyslová škola elektrotechnická \ a Vyšší odborná škola Pardubice]
  })
  v(66pt)
  align(center, {
    set text(size: front-head, weight: "bold")
    [STŘEDNÍ PRŮMYSLOVÁ ŠKOLA ELEKTROTECHNICKÁ]
  })
  v(160pt)
  align(center, {
    set text(size: front-head, weight: "bold")
    kind
  })
  blank-lines(2)
  align(center, {
    set text(size: front-head, weight: "bold")
    title
  })
  v(1fr)
  set text(size: front-size)
  box(width: author-tab, [#date #h(1fr) #author])
}

#let declaration-page(city) = {
  set text(style: "italic")
  v(1fr)
  par(justify: true)[„Prohlašuji, že jsem maturitní práci vypracoval(a) samostatně a~použil(a) jsem literárních pramenů,  informací a obrázků, které cituji a uvádím v seznamu použité literatury a~zdrojů informací a v~seznamu použitých obrázků a neporušil jsem autorská práva.]
  v(para-gap)
  par(justify: true)[Souhlasím s umístěním kompletní maturitní práce nebo její části na školní internetové stránky a s použitím jejích ukázek pro výuku.“]
  v(24pt)
  block({
    center-at(sig-tab, dots(48))
    [V #city dne #dots(27)]
  })
  block(height: line-step * 1em, center-at(sig-tab, [podpis]))
}

#let assignment-page(which) = align(center, {
  [TADY BUDE #which STRANA ORIGINÁLU ZADÁNÍ]
  v(6pt)
  [S~PODPISEM ŘEDITELE]
})

#let abstract-page(label, abstract, keywords-label, keywords) = {
  set text(style: "italic")
  {
    set text(size: front-size)
    label
  }
  v(12pt)
  par(justify: true, abstract)
  v(24pt)
  par[#keywords-label #keywords]
}

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

  show heading: it => {
    let level = it.level
    if level == 1 { pagebreak(weak: true) }
    block(above: (20pt, 24pt, 24pt).at(level - 1), below: (30pt, 18pt, 18pt).at(level - 1), {
      set text(font: sans, size: head-size.at(level - 1), weight: "bold")
      set par(justify: false, first-line-indent: 0pt, hanging-indent: hang)
      if it.numbering != none { box(width: hang, counter(heading).display(it.numbering)) }
      it.body
    })
  }

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
    {
      set text(font: sans, size: front-size, weight: "bold")
      [Obsah]
    }
    outline(title: none, depth: 3)
  }

  set page(
    footer: box(width: 2 * footer-tab, align(center)[– #context counter(page).display() –]),
    footer-descent: 8.5pt,
  )
  body
}
