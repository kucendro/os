#import "spse.typ": spse-doc, empty-par, table-width, cell-pad

#show: spse-doc.with(
  title: [NÁVRH A REALIZACE OSOBNÍ TECHNOLOGICKÉ INFRASTRUKTURY],
  kind: [MATURITNÍ PRÁCE – HARDWARE A POČÍTAČOVÉ SÍTĚ],
  date: [březen 2027],
  author: [Ondřej Kučera, 4.D],
  city: [Pardubicích],

  abstract-cs:
  [Práce byla vytvořena za účelem důkazu možnosti sestavit state-of-the-art personální řešení softwarových služeb na vlastním či propůjčeném hardwaru. V mnohých aspektech plně nahrazující komerční cloudové služby. Nikterak však nezabraňuje komerčním řešením využívat stejných principů. Klíčem bylo vytvoření silné bezpečnostní vrstvy mezi jednotlivými zařízeními, uživateli a konkrétními službami. Řešení je plně modulární, po destrukci hardwaru je možná obnova do původního stavu. Práce nabízí podrobný popis konceptů využitých při realizaci i návod pro tvorbu obdobného řešení.],

  keywords-cs:
  [automatizace, infrastruktura, linux, mesh síť, monitoring, NixOS, server, ssh, síťové připojení, virtualizace, vzdálená plocha, vzdálený přístup, zálohování dat],

  abstract-en:
  [The work was created to prove the possibility of assembling a state-of-the-art personal solution for software services on one's own or borrowed hardware. In many aspects, it fully replaces commercial cloud services. However, it does not prevent commercial solutions from using the same principles. The key was to create a strong security layer between individual devices, users, and specific services. The solution is fully modular, and after hardware destruction, it is possible to restore it to its original state. The work offers a detailed description of the concepts used in the implementation and a guide for creating a similar solution.],

  keywords-en:
  [automation, data backup, infrastructure, linux, mesh network, monitoring, network connection, NixOS, remote access, remote desktop, server, ssh, virtualization]
)

#heading(numbering: none)[Úvod]

Infrastrukturou se rozumí soubor více než jednoho zařízení, která společně tvoří funkční celek.

V současné době je zcela běžné, že uživatel vlastní více, než jedno elektronické zařízení zároveň. Z pohledu konzumenta takových prostředků, jakými mohou být mobilní telefon, nositelná elektronika a laptop, je zcela běžnou praxí tendence přetrvávat u jednoho poskytovatele služeb či hardware. A to i po mnoho let, dekád. Pro uživatele je to nejsnazší cesta. Kompletní řešení nabízené technologickými firmami šetří uživatelův čas. Pro něj tak nevzniká povinnost učit se a porozumět hlubším konceptům počítačových sítí, kybernetické bezpečnosti ani programovacím jazykům. Firmami se jednotné nabízené řešení stává dobře marketingově propagovatelné viz Apple Inc. Za čas prosazování konceptu centralizace si uživatelé od velkých korporací vybudovali očekávání luxusu v této kategorii. Uživatel se tak stává závislý na dodavateli služeb. Tento způsob čerpání výhod však má i svá úskalí.

Uzavřením do jednoho ekosystému se uživatel vystavuje nebezpečí nekontrolovanému nárůstu výdajů. Společnosti využívají centralizace k vytvoření psychické iluze a emocionální vazby s produktem/ekosystémem. Často se tak v praxi setkáváme s tolerancí uživatele k nadsazeným cenám poskytovaných služeb a fenoménu „Nebudeš nic vlastnit. A budeš šťastný.“, tedy předpovědi Světového ekonomického fóra z roku 2016 @wef2016, jejíž důsledky pro vlastnictví kriticky rozebírají Stewart, Charles a Page @stewart2023. Rozpor mezi skutečným vlastnictvím a pouhým přístupem ke službě je přitom měřitelný. V reprezentativním experimentu s 1299 účastníky se více než 83 % z nich po kliknutí na tlačítko „Buy Now“ považovalo za vlastníky zakoupeného digitálního obsahu, přestože jim licenční podmínky přiznávaly pouze omezené právo jej užívat. Za skutečná vlastnická práva jsou přitom zákazníci ochotni zaplatit více @perzanowski2017.


V komerční sféře softwarových firem je běžnou praxí přesný opak. 
Firmy shledávají za nejen finančně výhodnější, ale i bezpečnější a efektivnější provoz vlastních služeb. V praxi k tomu využívají vlastní hardware, síťovou infrastrukturu a software. Firmám tento způsob nabízí absolutní kontrolu nad jejich fungováním. Takový přístup je však pro běžného uživatele příliš složitý a nákladný. Cílem této práce je nabídnout uživateli možnost sestavit si vlastní infrastrukturu, která bude plně funkční a bezpečná, a to i na základě vlastního hardwaru. V práci je popsán návrh, realizace a testování takového řešení.

(doplnit moje vlastni cile, sitove infra atd).

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

#[
  #set par(justify: false, first-line-indent: 0pt)
  #bibliography("refs.bib", title: none, style: "iso690-numeric-cs.csl")
]

#heading(numbering: none)[Seznam použitých zkratek]

Zkratky řaďte abecedně, malé písmeno má přednost před velkým.

#heading(numbering: none)[Seznam obrázků, tabulek, grafů]

Vygenerujte seznam obrázků použitých v~dokumentaci (obrázky musí mít zapsané titulky) včetně čísel stránek (stránky menší než polovina stránky mohou být vloženy ve stránce, bez obtékání textu, velké obrázky budou v~příloze).

#heading(numbering: none)[Přílohy]

Use case diagram