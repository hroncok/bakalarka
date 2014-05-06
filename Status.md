% Status quo a požadavky

V této kapitole osvětlím problematiku své bakalářské práce s důrazem na důvody vedoucí k její potřebě.

DevAssistant
============

DevAssistant je aplikací, která programátorům pomáhá vytvářet nové vývojářské projekty, vydávat kód a dělat další věci, které programátory zdržují od toho nejdůležitějšího, od psaní softwaru. Nezáleží na tom, jestli jste právě objevili svět vývoje softwaru, nebo jestli už programujete dvě dekády, vždy se najde něco, s čím vám DevAssistant ulehčí život [@RedHat2013]. DevAssistant je možné používat z příkazové řádky nebo pomocí GUI, jak je vidět na [obrázku](#par:da-gui).

![Grafické rozhraní aplikace DevAssistant {#par:da-gui}](images/da-gui)

Jedná se o svobodný software, je vydaný pod licencí GNU GPL verze 2 nebo vyšší [@RedHat2013].

Asistenty  {#par:asistenty}
---------

DevAssistant je vlastně nástroj umožňující spouštění takzvaných asistentů, které lze zařadit do čtyř kategorií:

 * *vytvářecí asistenty* pomáhají uživateli začít nový projekt,
 * *modifikační asistenty* pomáhají uživateli projekt upravit nebo do něj něco přidat,
 * *připravovací asistenty* pomáhají uživateli zapojit se do nějakého projektu,
 * *úkolové asistenty* pomáhají uživateli s věcmi, které se netýkají konkrétního projektu [@Kabrda2013a].

Jednotlivé asistenty jsou napsány ve speciálním DSL [@Kabrda2013c], který je založen na jazyce YAML.

> DSL (doménově specifický jazyk) je programovací jazyk, který je prostřednictvím vhodné abstrakce a výrazového slovníku zaměřen na omezenou, konkrétní problémovou doménu. [@PrispevateleWikipedie2014]

> YAML je formát pro serializaci strukturovaných dat. Výhodou tohoto formátu je, že je dobře čitelný nejen strojem, ale i člověkem. [@PrispevateleWikipedie2014a]

YAML soubory definují jak metadata, tak kód, který asistent spouští. Kromě nich můžou k asistentu patřit ještě další soubory (šablony zdrojových kódů apod.) a ikona (zobrazená například v grafickém rozhraní [na obrázku](#par:da-gui)).

[V ukázce](#par:assistant-example) můžete vidět příklad jednoduchého vytvářecího asistentu.

```{caption="Ukázka vlastního asistentu z dokumentace \autocite{Kabrda2013} {#par:assistant-example}" .yaml}
fullname: Argh Script Template
description: Create a template of simple script that uses argh library
project_type: [python]

dependencies:
- rpm: [python-argh]

files:
  arghs: &arghs
    source: arghscript.py

args:
  name:
    use: common_args

run:
- log_i: Hello, I'm Argh assistant...
- if $(test -e "$name"):
  - log_e: '"$name" already exists, cannot proceed.'
- cl: mkdir -p "$name"
- $proj_name~: $(basename "$name")
- cl: cp *arghs ${name}/${proj_name}.py
- cl: chmod +x *arghs ${name}/${proj_name}.py
- dda_c: "$name"
- cl: cd "$name"
- use: git_init_add_commit.run
- log_i: Project "$proj_name" has been created in "$name".
````

Asistenty jsou hierarchicky řazeny do jednotlivých kategorií popsaných výše [@Kabrda2013] a uloženy na speciální místo na disku. Zatímco existuje základní sada asistentů, která je v některých případech distribuována společně s aplikací [@Kabrda2014], existuje také možnost vytvářet a používat své vlastní asistenty [@Kabrda2013].

Distribuování asistentů společně s aplikací však přináší řadu potíží - například nutnost kompatibility se všemi platformami, na kterých aplikace běží, či snaha vyhovět požadavkům všech uživatelů (jejichž představy se pochopitelně různí).

Příkladem vlastního asistentu může být například vytvářecí asistent, který studentům prvního ročníku Fakulty informačních technologií ČVUT v Praze pomůže s vytvořením úloh z předmětu *Programování a algoritmizace 1*. Takový asistent by zajistil, že studenti mají k dispozici potřebné programy (kompilátor apod.), a pomohl jim zkompilovat úlohy pomocí programu make [@FreeSoftwareFoundation2013]. Přestože by tento asistent byl jistě přínosný pro zmíněné studenty, pro další uživatele by nedávalo smysl, aby takový asistent byl distribuovaný společně s aplikací DevAssistant.

Požadavky {#par:pozadavky}
=========

Přestože je technicky možné distribuovat uživatelům asistent ve formě archivu, který je potřeba extrahovat na určité místo, jedná se o poměrně nepraktické řešení. Proto vyvstává potřeba vytvořit jednotný formát distribuovatelných asistentů a místo, kde takové asistenty sdílet [@Kabrda2013b].

Balík (dap) {#par:pozadavky-balik}
-----------

*Balík* je jedna distribuovatelná jednotka obsahující několik asistentů. Pro naše potřeby musí splňovat následující požadavky:

 * dodržení daného formátu a formy,
 * obsažení distribuovaných asistentů a dalších souborů k nim náležícím,
     * společně s adresářovou strukturou
 * obsažení metadat,
 * možnost verzování.

V balíku by měly být nutně uložena tato metadata:

 * název balíku,
 * krátké slovní shrnutí obsahu,
 * verze,
 * licence,
 * autor nebo autoři.

A volitelně pak také:

 * domovská webová stránka,
 * místo, kam hlásit chyby,
 * delší text popisující obsah balíku a práci s asistenty v něm obsaženými.
 

Pro potřeby rozlišení balíku pro DevAssistant od jiných balíků (např. RPM) je tento balík pojmenován *DevAssistant Package*, zkráceně dap[^dap].

Repozitář {#par:pozadavky-repozitar}
---------

*Repozitář* je místo, kde mohou uživatelé sdílet a vyhledávat nasdílené dapy. Z důvodu uživatelské přívětivosti a dostupnosti je takovým místem webové úložiště (webová aplikace). Takové úložiště musí pro naše potřeby splňovat následující požadavky:

 * Pro uživatele, který sdílí dap:
     * nahrání nového dapu,
     * nahrání nových verzí dapu,
     * kontrola správnosti[^kontrola],
     * klasifikace dapu[^klasifikace],
     * přizvání dalších uživatelů ke správě dapu,
     * mazání jednotlivých verzí dapu nebo dapu jako celku.
 * Pro uživatele, který chce dap získat:
     * vyhledávání dapů,
     * stažení dapů,
     * hodnocení dapů,
     * hlášení školdivých dapů,
     * možnost prohledávání repozitáře a stahování dapů přímo z aplikace DevAssistant[^api].
 * Pro správce repozitáře:
     * mazání jednotlivých verzí dapu nebo dapu jako celku,
     * úprava nebo mazání uživatelských účtů a profilů,
     * vyhodnocování nahlášených dapů.
 * Pro všechny uživatele:
     * autentifikace,
     * úprava uživatelského a profilu,
     * opuštění aplikace (smazání profilu a vytvořeného obsahu).

[^dap]: Pro účely zjednodušení textu jsem se rozhodl toto slovo skloňovat podle vzoru *hrad*.
[^kontrola]: Například jedná-li se skutečně o dap splňující specifikaci.
[^klasifikace]: Například pomocí tagů.
[^api]: V rámci této práce je implementováno pouze API toto umožňující.
