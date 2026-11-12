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

V současné době je zcela běžné, že uživatel vlastní více než jedno elektronické zařízení zároveň. Z pohledu konzumenta takových prostředků, jakými mohou být mobilní telefon, nositelná elektronika a laptop, je běžnou praxí tendence přetrvávat u jednoho poskytovatele služeb či hardwaru, a to i po mnoho let či desetiletí. Pro uživatele je to nejsnazší cesta. Kompletní řešení nabízené technologickými firmami šetří uživatelův čas. Pro něj tak nevzniká povinnost učit se hlubší koncepty počítačových sítí, kybernetické bezpečnosti ani programovacích jazyků a porozumět jim. Pro firmy se jednotné nabízené řešení stává dobře marketingově propagovatelným (viz Apple Inc.). Za dobu prosazování konceptu centralizace si uživatelé od velkých korporací vybudovali očekávání luxusu v této kategorii. Uživatel se tak stává závislý na dodavateli služeb. Tento způsob čerpání výhod však má i svá úskalí.

Uzavřením do jednoho ekosystému se uživatel vystavuje nebezpečí nekontrolovaného nárůstu výdajů. Společnosti využívají centralizace k vytvoření psychické iluze a emocionální vazby k produktu či ekosystému. Často se tak v praxi setkáváme s tolerancí uživatele k nadsazeným cenám poskytovaných služeb a fenoménu „Nebudeš nic vlastnit. A budeš šťastný.“, tedy předpovědi Světového ekonomického fóra z roku 2016 @wef2016, jejíž důsledky pro vlastnictví kriticky rozebírají Stewart, Charles a Page @stewart2023. Rozpor mezi skutečným vlastnictvím a pouhým přístupem ke službě je přitom měřitelný. V reprezentativním experimentu s 1~299 účastníky se více než 83~% z nich po kliknutí na tlačítko „Buy Now“ považovalo za vlastníky zakoupeného digitálního obsahu, přestože jim licenční podmínky přiznávaly pouze omezené právo jej užívat. Za skutečná vlastnická práva jsou přitom zákazníci ochotni zaplatit více @perzanowski2017.

Do jisté míry je zmíněným fenoménem zasažen každý z nás. V západní společnosti se za poslední dekádu setkáváme s normalizací trendu primárně u mladé generace, což si vysvětluji tím, že mladí lidé neměli možnost vlastnictví zažít. Osobně, jakožto autor práce, se cítím ovlivněn také.
To je jeden z důvodů, proč jsem se ponořil do hlubších konceptů self-hosted služeb, decentralizace a technologické nezávislosti.

V komerční sféře softwarových firem je obdobný přístup běžnou praxí.
Firmy shledávají provoz vlastních služeb nejen finančně výhodnějším @wang2021, ale i bezpečnějším a efektivnějším. V praxi k tomu využívají vlastní hardware, síťovou infrastrukturu a software. Firmám tento způsob nabízí absolutní kontrolu nad jejich fungováním. Takový přístup je však pro běžného uživatele příliš složitý a nákladný.

Cílem této práce je nabídnout uživateli možnost sestavit si vlastní infrastrukturu, která bude plně funkční a bezpečná, a to i na základě vlastního hardwaru. Práce je shrnutím mojí cesty s deklarativními systémy včetně blíže rozvedených rozhodnutí, vyvstalých úskalí a klíčových výhod. Blíže je popsán návrh, realizace a testování.

= Analýza obdobných řešení

Výběr technologie pro tvorbu infrastruktury je nejklíčovějším rozhodnutím, protože další postup na něj navazuje. Ačkoliv se rozdíly v technologiích nemusejí zdát velké, chyba při výběru může vést ke zdlouhavému procesu migrace dat a služeb na jiný substrát (rozumí se platformu) @oparamartins2016. Tímto procesem si projde kdokoliv, kdo řeší infrastrukturu.

Řešení je mnoho, problém je aktuální od vzniku internetu a nepolevuje, nýbrž se jen škáluje, a to jak horizontálně (výpočetní výkon v datacentrech pokrývá větší geografickou plochu, větší počet datacenter), tak i vertikálně (jednotlivé uzly jsou výkonnější a mají rychlejší paměť i propojení) @michael2007. Přenosy dat tak mnohdy dosahují až TB/s, viz celotělový ultrazvukový skener Midjourney Medical, nebo moderní AI datacentra @vahdat2025 s akcelerátory TPU @jouppi2017 či NPU @liao2021. Může se zdát, že toto je problém řešitelný na straně síťového připojení, kdy se kladou extrémní nároky na přenosová média (optické kabely, metalické spoje, on-die čipové spoje) @poutievski2022. Pokud ale opomeneme software pohánějící hardware, narazíme na problém softwarové škálovatelnosti.

Vytvoření systému, který se dokáže dle potřeby a vytíženosti adaptovat @verma2015 a zároveň je plně deterministický @dolstra2010, je těžký inženýrský problém, na který existuje mnoho lepších i horších odpovědí. Při své cestě jsem měl možnost vyzkoušet používat a aplikovat více z nich.

== Operační systémy
 zde uvest imperativne nastaveovane os jako ubuntu, jine systemy, windows, a pod. kernel linux, jednoduche popsani

 moznost doplnit o vizualizace

== Deklarativní sestavování
 vysvetleni vyhody deklarativnosti vs imperativnost, vysvetleni teorie za tim, uvest veci jako dockerfile, kube, bazsel a pod. Moznost doplnit o vizualizace

== Kombinace deklarativnosti a operačního systému

zminit nix a nixos, ktery to spojuje, rozebrat do hloubky, pak zduvodnit, proc jsem si to vybral ... pozn, navrh mi to kolega, moje cesta neni retrospektivni, neopak jsem se k tomu dostal omylem a pak jsem zjistoval vyhody


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
  #bibliography("refs.bib", title: none, style: "iso690-numeric-brackets-cs.csl")
]

#heading(numbering: none)[Seznam použitých zkratek]

#[
  #set par(justify: false, first-line-indent: 0pt)
  #grid(
    columns: (4em, 1fr),
    row-gutter: 0.8em,
    [AI], [Artificial Intelligence – umělá inteligence],
    [NPU], [Neural Processing Unit – neuronová procesorová jednotka, procesor specializovaný na výpočty neuronových sítí],
    [TPU], [Tensor Processing Unit – tenzorová procesorová jednotka, specializovaný čip společnosti Google pro urychlení výpočtů neuronových sítí],
  )
]

#heading(numbering: none)[Seznam obrázků, tabulek, grafů]

Vygenerujte seznam obrázků použitých v~dokumentaci (obrázky musí mít zapsané titulky) včetně čísel stránek (stránky menší než polovina stránky mohou být vloženy ve stránce, bez obtékání textu, velké obrázky budou v~příloze).

#heading(numbering: none)[Přílohy]

Use case diagram