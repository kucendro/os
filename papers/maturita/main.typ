#import "spse.typ": spse-doc, empty-par, table-width, cell-pad

#show: spse-doc.with(
  title: [NÁVRH A REALIZACE OSOBNÍ TECHNOLOGICKÉ INFRASTRUKTURY],
  kind: [MATURITNÍ PRÁCE – HARDWARE A POČÍTAČOVÉ SÍTĚ],
  date: [březen 2027],
  author: [Ondřej Kučera, 4.D],
  city: [Pardubicích],

  abstract-cs:
  [Práce byla vytvořena s cílem prokázat, že lze na vlastním či propůjčeném hardwaru sestavit moderní osobní řešení softwarových služeb, kterým mohou být v mnohých aspektech plně nahrazeny komerční cloudové služby. Komerčním řešením však nikterak není zabráněno využívat stejných principů. Klíčovým bodem bylo vytvoření silné bezpečnostní vrstvy mezi jednotlivými zařízeními, uživateli a konkrétními službami. Řešení je navrženo jako plně modulární a po zničení hardwaru může být obnoveno do původního stavu. V práci jsou podrobně popsány koncepty využité při realizaci a je předložen návod pro tvorbu obdobného řešení.],

  keywords-cs:
  [automatizace, infrastruktura, linux, mesh síť, monitoring, NixOS, server, ssh, síťové připojení, virtualizace, vzdálená plocha, vzdálený přístup, zálohování dat],

  abstract-en:
  [The thesis was created to demonstrate that a modern personal solution for software services can be built on one's own or borrowed hardware, by which commercial cloud services can be fully replaced in many aspects. Commercial solutions are, however, in no way prevented from using the same principles. The key element was the creation of a strong security layer between individual devices, users and specific services. The solution is designed to be fully modular and can be restored to its original state after the hardware is destroyed. The concepts used in the implementation are described in detail, and a guide for building a similar solution is provided.],

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

= Analýza

Výběr technologie pro tvorbu infrastruktury se stává již zprvu nejklíčovějším rozhodnutím, protože další postup navazuje. Ačkoliv se rozdíly v technologiích nemusejí zdát velké, chyba při výběru může vést ke zdlouhavému procesu migrace dat a služeb na jiný substrát (rozumí se platformu) @oparamartins2016. Vyvarování se migraci vhodným výběrem je v praxi preferováno, protože se tím šetří náklady, ale ne úplně běžné. Technologie se ve svých vlasnostech překrývají. Pověřená osoba tak musí pochopit požadavky a nároky na insrastrukturu kladené, zpracovat je, predikovat, a občasně i tvořit kompromisy. 

Řešení je mnoho. Problém je aktuální již od vzniku internetu a nepolevuje, naopak se škáluje, a to jak horizontálně (výpočetní výkon v datacentrech pokrývá větší geografickou plochu, větší počet datacenter), tak i vertikálně (jednotlivé uzly jsou výkonnější, mají rychlejší paměť i propojení) @michael2007. Přenosy dat tak mnohdy dosahují až TB/s, viz ultrazvukový skener Midjourney Medical @midjourney2026, nebo současná AI datacentra @vahdat2025 s akcelerátory TPU @jouppi2017 či NPU @liao2021. Software se musí nárokům přizpůsobit. Může se zdát, že problém je řešitelný pouze na straně síťového připojení, kde jsou kladeny extrémní nároky na přenosová média (optické kabely, metalické spoje, on-die čipové spoje) @poutievski2022. Pokud se však opomene software, vyvstane problém škálovatelnosti mnohem obtížněji řešitelný.

Vytvoření systému, který by se dokázal dle potřeby a vytíženosti adaptovat @verma2015 a zároveň by byl plně deterministický @dolstra2010, je těžkým inženýrským problémem, jehož existenci potvrzuje mnoho lepších i horších odpovědí.

== Operační systémy

=== Linux Kernel

Operační systém (OS) tvoří vrstvu mezi hardwarem a aplikacemi. Úkolem OS je zajistit, aby programy mohly sdílet procesor (CPU), operační paměť (RAM), disk i síťové rozhraní, aniž by o sobě musely nutně vzájemně vědět. Základem systémů, kterými se tato práce zabývá, je jádro Linux (kernel). @kernelreadme.

Linux je dominantem především na serverech. Podle průzkumu běží na Linuxu 63,7~% webových stránek, u nichž je OS serveru znám @w3techslinux, a v žebříčku 500 nejvýkonnějších superpočítačů světa jej využívají všechny @top500os. Na stolních počítačích je trend opačný, Linuxu připadá jen asi 2~% provozu @statcounteros. Kernel však používá i Android @androidkernel, který je s podílem 44,6~% nejrozšířenějším operačním systémem na světě @statcounteros.

=== Distribuce OS

Samotný kernel však k provozu nestačí. Obsluhuje hardware a spouští procesy. O tom, jaké programy jsou nainstalovány, jejich verze a jak jsou nastaveny, ale nerozhoduje. To je úkolem distribuce#footnote[Celek složený z jádra, základních nástrojů, správce balíčků a výchozí konfigurace.], jakou je například Ubuntu, nebo Fedora. Ty na kernelu staví. Rozdíly nevznikají v kernelu samotném, ale ve způsobu, jakým distribuce spravuje vše, co nad ním běží.

Nejrozšířenější je imperativní#footnote[Sekvence příkazů $p_1, ..., p_n$ aplikovaná na aktuální stav: $S_n = p_n (... p_2 (p_1 (S_0)))$. Výsledek závisí na výchozim stavu $S_0$ a na pořadí příkazů.] způsob správy distribuce. Pro demonstrační účely lze využít OS Ubuntu na nejž se aplikace a jiný software instalují a aktualizují s pomocí nástroje APT. @ubuntuapt. Každý příkaz mění soubory v systému za běhu na místě. Obdobné použití aplikuje i OS Windows: instalátory aplikací, systémové aktualizace i změny nastavení se postupně vrší. Výsledný stav počítače tak není nikde centralizovaně popsán. Je dán pouze výchozí instalací a celou historií změn, kterou uživatel v průběhu užívání uskutečnil.

=== Drift konfigurace

Problém vyvstane ve chvíli, kdy je strojů více než jeden. Dva počítače nainstalované ze stejného média se po několika měsících běžného používání téměř jistě liší, protože každý prošel jinou posloupností aktualizací, instalací a oprav. Tento jev se označuje jako drift konfigurace (z angl. _configuration drift_). Důsledkem je, že nikdo nedokáže s jistotou říct, co přesně na daném stroji je a hlavně, proč.

S tím souvisí i obnova. Pokud aktualizace neproběhne, jak se předpokládalo, imperativní systém obvykle nenabízí jednoduchou cestu zpět. Předchozí verze souborů byly přepsány. Windows tento problém částečně řeší funkcí Obnovení systému, která pracuje s body obnovy#footnote[(z angl. _snapshot_), Snímky konfigurace a nastavení systému v určitém okamžiku @windowsrestore].

Přirozenou reakcí na drift by mohl být zápis postupu do předpisu, který lze spustit na libovolném počtu strojů. Tímto směrem jdou nástroje pro správu konfigurace, z nichž nejznámější je Ansible. Základem je idempotence#footnote[Binární operace je idempotentní, pokud je výsledek jednoho jejího provedení stejný jako výsledek opakovaného provedení: $x * x = x quad forall x in S$]. Dokumentace Ansible uvádí, že uvede systém do požadovaného stavu bez ohledu na aktuální stav, místo aby uživatel musel popisovat, jak se k němu dostat @ansibleglossary. Ansible tedy není čistě imperativní. Požadovaný stav ale popisuje pouze pro ty části systému, které jsou v předpisu uvedeny. Co bylo na stroj nainstalováno mimo předpis, Ansible neodstraní, protože o tom neví.

Jiná skupina systémů řeší obnovu tím, že si předchozí stavy uchovává. Distribuce openSUSE MicroOS využívá nástroj transactional-update, který před každou aktualizací vytvoří pomocí nástroje snapper nový snímek kořenového souborového systému a aktualizaci provede v něm. Změny se projeví až po restartu a příkaz `rollback` umožňuje nastavit jako výchozí některý z předchozích snímků @transactionalupdate. Projekt bootc, na kterém staví Fedora Atomic, jde ještě dál a aktualizuje celý operační systém pomocí obrazů kontejnerů ve formátu OCI @bootcreadme. Nová verze systému se připraví jako další nasazení vedle stávajícího a příkaz `bootc rollback` pouze změní pořadí položek v zavaděči, takže se při dalším startu spustí nasazení předchozí @bootc.

#figure(
  include "figures/rollback.typ",
  caption: [Modely aktualizace a návratu operačního systému. Zdroj: vlastní zpracování dle @transactionalupdate, @bootc a @nixosmanual.],
) <obr-modely>

Rozdíly mezi popsanými přístupy shrnuje @obr-modely[obrázek]. Snímky i obrazy přinášejí to, co klasickým systémům chybí, totiž atomickou změnu a možnost návratu. Stále však platí, že systém nepopisují, pouze uchovávají jeho stavy. Snímek je kopií výsledku, nikoli předpisem, jak k němu dojít, a obraz systému vzniká sestavením, které samo může být imperativní. Otázkou, jak systém popsat tak, aby šel kdykoli znovu vytvořit, se zabývá následující kapitola.

== Deklarativní sestavování

Rozdíl mezi imperativním a deklarativním přístupem lze shrnout jednou otázkou: popisuji, jak se k výsledku dostat, nebo jaký má výsledek být? Imperativní předpis je posloupnost kroků (nainstaluj, uprav, restartuj), jejichž výsledek závisí na tom, v jakém stavu systém na začátku byl. Deklarativní předpis popisuje požadovaný výsledek a cestu k němu ponechává nástroji. Dokumentace Kubernetes tento rozdíl vysvětluje na příkladu termostatu: uživatel nastaví požadovanou teplotu, tedy požadovaný stav, a termostat zapíná a vypíná topení tak, aby se aktuální stav požadovanému přiblížil @k8scontroller.

#figure(
  include "figures/drift.typ",
  caption: [Imperativní a deklarativní správa více hostitelů. Zdroj: vlastní zpracování.],
) <obr-sprava>

Pro správu více strojů má tento rozdíl zásadní důsledek, který ilustruje @obr-sprava[obrázek]. Při imperativní správě je stav každého stroje dán jeho historií, a dva stroje se proto mohou lišit, i když vznikly ze stejné instalace. Při deklarativní správě je stav funkcí konfigurace: ze stejné konfigurace vznikne stejný výsledek, a pokud stroje sdílejí konfiguraci, sdílejí i stav. To ovšem platí jen za předpokladu, že je samotné sestavení reprodukovatelné.

Projekt Reproducible Builds definuje sestavení jako reprodukovatelné, pokud může kdokoli ze stejného zdrojového kódu, stejného sestavovacího prostředí a stejných instrukcí znovu vytvořit bit po bitu identické kopie všech určených výstupů @reproduciblebuilds. Význam této vlastnosti přesahuje pohodlí správce: pokud lze výsledek sestavení nezávisle ověřit, zvyšuje se důvěryhodnost celého dodavatelského řetězce softwaru @lamb2022.

Aby bylo sestavení reprodukovatelné, nesmí jeho výsledek záviset na ničem, co není výslovně deklarováno. Tuto vlastnost označuje dokumentace nástroje Bazel jako hermetičnost: hermetický sestavovací systém při stejném vstupním kódu a stejné konfiguraci vždy vrátí stejný výstup, protože sestavení izoluje od změn hostitelského systému @bazelhermeticity. Pokud by sestavení mohlo nahlédnout do hostitelského systému (například použít knihovnu, která na něm náhodou je nainstalována), jeho výsledek by se lišil podle toho, na jakém stroji proběhlo.

Dobrým příkladem, že deklarativní vzhled ještě neznamená deklarativní chování, je Dockerfile. Na první pohled popisuje obraz kontejneru: z jakého základního obrazu vychází, jaké soubory obsahuje a jaký program se v něm spustí. Základní obraz se ale obvykle uvádí pomocí značky (angl. _tag_), která není neměnná. Dokumentace Dockeru proto doporučuje připnout obraz ke konkrétnímu otisku (angl. _digest_), protože jedině tak je zaručeno použití stále stejné verze, i když vydavatel pod stejnou značku vydá obraz nový @dockerbest. Obdobně se chovají i instrukce `RUN`, které typicky spouštějí správce balíčků (například `apt-get install`) a stahují balíčky v té verzi, která je dostupná v okamžiku sestavení. Tato druhá část je mou vlastní úvahou, nikoli tvrzením dokumentace. Dockerfile je tak ve skutečnosti spíše skriptem, jehož výsledek se ukládá po vrstvách, a stejný Dockerfile může za měsíc vytvořit jiný obraz.

Kubernetes je deklarativní v plném smyslu slova, ale na jiné úrovni. Objekty v něm lze vytvářet, aktualizovat a mazat uložením konfiguračních souborů do adresáře a jejich předáním příkazu `kubectl apply` @k8sdeclarative a takzvané kontrolery pak průběžně přibližují aktuální stav požadovanému @k8scontroller. Kubernetes však spravuje běžící kontejnery, nikoli sestavení softwaru ani operační systém strojů, na kterých kontejnery běží. Stejný princip, tedy deklarativní popis uložený ve verzovaném úložišti, který si agenti sami stahují a průběžně s ním srovnávají skutečný stav, formalizuje přístup GitOps @opengitops. K němu se vrátím při popisu nasazování vlastní infrastruktury.

Bazel naopak řeší právě sestavení. Izoluje ho od hostitelského systému @bazelhermeticity, operační systém ani jeho konfiguraci však nespravuje, protože to není jeho účelem.

Zda deklarativní a hermetický přístup funguje i ve velkém, zkoumala studie, která znovu sestavila 709~816 balíčků z historických snímků repozitáře nixpkgs z let 2017 až 2023. Bitově identický výsledek autoři získali v 69 až 91~% případů s rostoucím trendem a úspěšnost samotného opětovného sestavení přesáhla 99~% @malka2025. Přibližně 15~% neúspěchů přitom způsobilo pouhé vložení data sestavení do výsledku.

#figure(
  include "figures/landscape.typ",
  caption: [Role ve správě infrastruktury a nástroje, které je pokrývají. Zdroj: vlastní zpracování.],
) <tab-role>

Přehled nástrojů zmíněných v této a předchozí kapitole podává @tab-role[tabulka]. Je z ní patrné, že každý z nich pokrývá jednu roli: Ansible konfiguraci systému, Bazel a Dockerfile sestavení, Kubernetes nasazování, bootc neměnný systém. Jedinými nástroji, které tyto role spojují do jednoho modelu, jsou Nix a jemu příbuzný GNU Guix. Jejich spojení s operačním systémem se věnuje následující kapitola.

== Kombinace deklarativnosti a operačního systému

Nix vznikl na Univerzitě v Utrechtu. Jeho autoři ho v roce 2004 představili jako systém pro nasazování softwaru, který řeší dva hlavní problémy tehdejších nástrojů: nemožnost spolehlivě vynutit popis závislostí mezi komponentami a chybějící podporu pro více verzí nebo variant téže komponenty. Řešení stojí na jednoduché myšlence, totiž na použití kryptografických hashů k výpočtu jedinečné cesty pro každou instanci komponenty @dolstra2004. Celý model pak Eelco Dolstra podrobně rozpracoval ve své disertační práci @dolstra2006.

Každý výsledek sestavení se ukládá do adresáře `/nix/store` pod cestou, jejíž součástí je zmíněný hash. Změní-li se vstup, vznikne nová cesta a ta původní zůstane nedotčena. Díky tomu lze mít nainstalováno více verzí nebo variant téhož balíčku současně, a protože Nix stávající balíčky nikdy nepřepisuje, ale pouze přidává nové verze do jiných cest, jsou jeho operace atomické a lze se vrátit k verzi předchozí @nixmanual. Pokud už výsledek existuje v binární cache, tedy na webovém serveru s předem sestavenými balíčky, Nix ho místo sestavování stáhne @nixmanual, přičemž stažený obsah musí být podepsán důvěryhodným klíčem @nixconf.

Pokud výsledek v cache není, Nix ho sestaví sám. Sestavení přitom probíhá v izolovaném prostředí (angl. _sandbox_), ve kterém vidí pouze své závislosti v `/nix/store`, dočasný adresář pro sestavení a soukromé verze několika systémových adresářů. Na Linuxu navíc běží ve vlastních jmenných prostorech, mimo jiné i v síťovém, a k síti tak nemá přístup. Výjimkou jsou pouze derivace s pevně daným výstupem, typicky stažení zdrojového kódu @nixconf. Celý proces od deklarace po hotový výsledek znázorňuje @obr-nix[obrázek].

#figure(
  include "figures/nix-pipeline.typ",
  caption: [Cesta od deklarace k nové generaci systému v Nix. Zdroj: vlastní zpracování dle @dolstra2006.],
) <obr-nix>

Pro opakovatelnost je klíčové, aby se neměnily ani samotné vstupy, například repozitář nixpkgs s definicemi balíčků. K tomu slouží takzvané flakes: Nix pro zajištění reprodukovatelnosti automaticky vytváří a používá soubor `flake.lock`, do kterého zapíše uzamčené specifikace všech vstupů @nixflake. Aktualizace pak znamená vědomou změnu tohoto souboru, kterou lze, stejně jako jakoukoli jinou změnu v repozitáři, kdykoli vrátit. Je ovšem třeba zmínit, že příkaz `nix flake` je dosud označen jako experimentální a jeho rozhraní se může měnit @nixflake.

NixOS přenáší stejný princip z jednotlivých balíčků na celý operační systém. Jeho autoři vycházejí z toho, že stávající nástroje pro správu balíčků a konfigurace trpí imperativním modelem, ve kterém akce správce destruktivně mění stav systému. To vede k problémům, jako je nemožnost snadno vrátit změny, provozovat více verzí balíčku vedle sebe, deterministicky zopakovat konfiguraci na jiném stroji nebo spolehlivě aktualizovat systém. NixOS proto všechny statické části systému, tedy balíčky, konfigurační soubory i spouštěcí skripty, sestavuje čistými funkcemi a ukládá je jako neměnné @dolstra2010.

Výsledkem je, že každá sestavená konfigurace je samostatnou generací systému. Do předchozí konfigurace se lze přepnout za běhu příkazem `nixos-rebuild switch --rollback`, případně ji vybrat v nabídce zavaděče při startu a příkazem `switch-to-configuration boot` ji nastavit jako výchozí @nixosmanual. NixOS tak spojuje obě vlastnosti, které se v předchozích kapitolách vyskytovaly odděleně: systém je popsán deklarací (jako u Kubernetes, nebo při disciplinovaném použití u Ansible) a zároveň lze kdykoli atomicky přejít na jinou verzi (jako u snímků nebo obrazů v @obr-modely[obrázku]).

Stejný model přebírá i GNU Guix, čistě funkcionální správce balíčků určený pro celou distribuci GNU/Linux. Staví na nízkoúrovňové vrstvě pro sestavování a nasazování ze systému Nix a jako programovací rozhraní používá jazyk Scheme @courtes2013. Transakčním aktualizacím a návratu podléhá i celková konfigurace systému Guix @guixmanual.

K Nixu jsem se ale nedostal systematickým srovnáním všech výše popsaných možností. Doporučil mi ho kolega  a k celému přístupu jsem se tak dostal spíše náhodou. Výhody popsané v této kapitole jsem zjišťoval až postupně, při jeho používání.  Analýzu v této kapitole proto nelze číst jako zdůvodnění rozhodnutí, které předcházelo realizaci. Je spíše zpětným ověřením, že volba, ke které jsem dospěl zčásti náhodou, obstojí i ve srovnání s alternativami.

Pro úplnost je třeba zmínit i nevýhody. Jazyk Nix a celý model vyžadují nemalé úsilí, než jim člověk porozumí. Rozhraní flakes je, jak bylo zmíněno, stále experimentální @nixflake. A konečně, neměnné jsou podle autorů NixOS statické části systému @dolstra2010. Data, která systém vytváří za běhu (například databáze nebo soubory uživatelů), generace nepokrývají a vyžadují vlastní řešení. Jak tyto principy využívám při stavbě vlastní infrastruktury, včetně síťového propojení jednotlivých strojů a zálohování dat, popisuji v následujících kapitolách.

#heading(numbering: none)[Závěr]

Popište význam projektu, zdůvodněte problémy při řešení daného tématu a~odchylky od zadání, popište využití maturitní práce a plány do budoucna.


#heading(numbering: none)[Seznam použité literatury a zdrojů informací]

#[
  #set par(justify: false, first-line-indent: 0pt)
  #bibliography("refs.bib", title: none, style: "iso690-numeric-brackets-cs.csl")
]

#heading(numbering: none)[Seznam použitých zkratek]

#let zkratky = (
  AI:  [Artificial Intelligence – umělá inteligence],
  NPU: [Neural Processing Unit – neuronová procesorová jednotka, procesor specializovaný na výpočty neuronových sítí],
  TPU: [Tensor Processing Unit – tenzorová procesorová jednotka, specializovaný čip společnosti Google pro urychlení výpočtů AI],
  APT: [Advanced package tool - pokročilý balíčkový nástroj, užívaný distribucí Ubuntu],
  OS:  [Operační Systém],
  RAM: [Random Access Memory - operační paměť],
  CPU: [Central Processing Unit - procesor],
  OCI: [Open Container Initiative - otevřená kontejnerová iniciativa, soubor standardů pro kontejnerizaci systémů a aplikací]
)
#[
  #set par(justify: false, first-line-indent: 0pt)
  #grid(
    columns: (4em, 1fr),
    row-gutter: 0.8em,
    ..zkratky
      .pairs()
      .sorted(key: p => p.first())
      .map(((k, v)) => ([#k], v))
      .flatten()
  )
]

#heading(numbering: none)[Seznam obrázků, tabulek, grafů]

#outline(title: none, target: figure)

#heading(numbering: none)[Přílohy]

Use case diagram