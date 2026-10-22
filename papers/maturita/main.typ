#import "spse.typ": spse-doc, empty-par, table-width, cell-pad

#show: spse-doc.with(
  title: [NÁVRH A REALIZACE OSOBNÍ TECHNOLOGICKÉ INFRASTRUKTURY],
  kind: [MATURITNÍ PRÁCE – HARDWARE A POČÍTAČOVÉ SÍTĚ],
  date: [březen 2027],
  author: [Ondřej Kučera, 4.D],
  city: [Pardubicích],

  abstract-cs:
  [Práce byla vytvořena za účelem důkazu možnosti sestavit state-of-art personální řešení softwarových služeb na vlastním či propůjčeném hardwaru. V mnohých aspektech plně nahrazující komerční cloudové služby. Nikterak však nezabraňuje komerčním řešením využívat stejných principů. Klíčem bylo vytvoření silné bezpečnostní vrztvy mezi jednotlivými zařízeními, uživateli a konkrétními službami. Řešení je plně modulární, po destrukci hardwaru je možná obnova do původního stavu. Práce nabízí podrobný popis konceptů využitých při realizaci i návod pro tvorbu obdobného řešení.],

  keywords-cs:
  [automatizace, infrastruktura, linux, mesh síť, monitoring, NixOS, server, ssh, síťové připojení, virtualizace, vzdálená plocha, vzdálený přístup, zálohování dat],

  abstract-en:
  [The work was created to prove the possibility of assembling a state-of-art personal solution for software services on one's own or borrowed hardware. In many aspects, it fully replaces commercial cloud services. However, it does not prevent commercial solutions from using the same principles. The key was to create a strong security layer between individual devices, users, and specific services. The solution is fully modular, and after hardware destruction, it is possible to restore it to its original state. The work offers a detailed description of the concepts used in the implementation and a guide for creating a similar solution.],

  keywords-en:
  [automation, data backup, infrastructure, linux, mesh network, monitoring, network connection, NixOS, remote access, remote desktop, server, ssh, virtualization]
)

#heading(numbering: none)[Úvod]
toto by melo byt napsane v kontextu ze tuto praci budu teprve psat


= Analýza obdobných řešení

Analyza podobnych reseni jako Bazel, Freeform apod.

== Bazel

Adresa: http:// …

Popište web …

=== Kladné stránky

#empty-par

=== Záporné stránky
#empty-par

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

#heading(numbering: none)[Seznam použité literatury a zdrojů informací]

Vložte seznam literatury a on-line stránek, které jste použili pro vyhledávání informací a studium.

Do seznamu zahrňte zdroje obrázků použité v~písemné práci i v~samotném webu (uveďte práva k~použití – používejte pouze obrázky zdarma použitelné pro komerční i nekomerční využití). Pokud jste některé obrázky vytvořili sami (vlastní grafika či vlastní fotografie), uveďte jejich seznam nebo popis a zdroj vlastní.

Seznam můžete vygenerovat na #link("http://www.citace.com")[www.citace.com]

#heading(numbering: none)[Seznam použitých zkratek]

Zkratky řaďte abecedně, malé písmeno má přednost před velkým.

#heading(numbering: none)[Seznam obrázků, tabulek, grafů]

Vygenerujte seznam obrázků použitých v~dokumentaci (obrázky musí mít zapsané titulky) včetně čísel stránek (stránky menší než polovina stránky mohou být vloženy ve stránce, bez obtékání textu, velké obrázky budou v~příloze).

#heading(numbering: none)[Přílohy]

Use case diagram

#pagebreak()

E-R diagram

#pagebreak()

Responzivita – vložte obrázek webu na počítači, na mobilu, příp. na tabletu.

#pagebreak()

Obrázky dalších stránek webu – vložte screenshoty všech hlavních stránek webu včetně ukázek administrace.
