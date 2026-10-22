#import "layout.typ": author-tab, blank-lines, center-at, dots, front-head, front-size, line-step, para-gap, sig-tab

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
