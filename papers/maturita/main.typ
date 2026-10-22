#import "spse.typ": spse-doc, empty-par, table-width, cell-pad

#show: spse-doc.with(
  title: [NÁZEV MATURITNÍ PRÁCE],
  kind: [MATURITNÍ PRÁCE – WEBOVÉ STRÁNKY],
  date: [březen rok],
  author: [jméno, příjmení a třída],
  city: [Pardubicích],
  abstract-cs: [Vložte popis webu (description).],
  keywords-cs: [Zapište klíčová slova (keywords)],
  abstract-en: [Insert a translation of the description.],
  keywords-en: [],
)

#heading(numbering: none)[Úvod]

Zapište účel webu, a proč jste si toto téma vybrali.

= Analýza obdobných webových stránek

Zapište důvod, proč je vhodné provést analýzu obdobných stránek…

== Zapište název prvního webu

Adresa: http:// …

Popište web …

=== Kladné stránky

#empty-par

=== Záporné stránky

= Návrh projektu

== Cílové skupiny

Popište, pro koho budou webové stránky určeny.

== Administrace webu

Popište, kdo bude spravovat obsah webu a vložte odkaz na use~case diagram vložený jako obrázek do příloh.

== Databáze

Popište strukturu databáze a vložte odkaz na E-R diagram s~viditelnou strukturou tabulek a vyznačenými spojnicemi relací, vložený jako obrázek do příloh.

== Design a responzivita

Popište způsob řešení responzivního zobrazení, uveďte rozlišení, při kterém se bude měnit menu, sloupcové uspořádání obsahu apod. Vložte schématické návrhy designu a~odkaz na screenshoty stránek zobrazených na různých zařízeních, vložené do příloh.

= Popis projektu

Uveďte členění následujícího popisu.

== Frontend

Uveďte popis jednotlivých webových stránek.

== Backend

Uveďte popis a způsob administrace webových stránek (co kdo a jak může vkládat, mazat, editovat).

#heading(numbering: none)[Závěr]

Popište význam projektu, zdůvodněte problémy při řešení daného tématu a~odchylky od zadání, popište využití maturitní práce a plány do budoucna.

#heading(numbering: none)[Seznam přístupových údajů]

URL adresa webu:

#pad(left: -cell-pad, block(width: table-width, breakable: false, {
  set par(first-line-indent: 0pt)
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: 0.5pt + black,
    inset: (x: cell-pad, y: 6pt),
    [Úroveň oprávnění], [Přihlašovací jméno], [Heslo],
    [Administrátor], [], [],
    [Redaktor, trenér, vedoucí apod. - upravte], [], [],
    [Registrovaný uživatel], [], [],
  )
}))

#heading(numbering: none)[Seznam použité literatury a zdrojů obrázků]

Vložte seznam literatury a on-line stránek, které jste použili pro vyhledávání informací a studium.

Do seznamu zahrňte zdroje obrázků použité v~písemné práci i v~samotném webu (uveďte práva k~použití – používejte pouze obrázky zdarma použitelné pro komerční i nekomerční využití). Pokud jste některé obrázky vytvořili sami (vlastní grafika či vlastní fotografie), uveďte jejich seznam nebo popis a zdroj vlastní.

Seznam můžete vygenerovat na #link("http://www.citace.com")[www.citace.com]

#heading(numbering: none)[Seznam obrázků]

Vygenerujte seznam obrázků použitých v~dokumentaci (obrázky musí mít zapsané titulky) včetně čísel stránek (stránky menší než polovina stránky mohou být vloženy ve stránce, bez obtékání textu, velké obrázky budou v~příloze).

#heading(numbering: none)[Přílohy]

Use case diagram

#pagebreak()

E-R diagram

#pagebreak()

Responzivita – vložte obrázek webu na počítači, na mobilu, příp. na tabletu.

#pagebreak()

Obrázky dalších stránek webu – vložte screenshoty všech hlavních stránek webu včetně ukázek administrace.
