% Implementace

V této kapitole podrobně popisuji implementaci své bakalářské práce.

Specifikace dapu {#implementace-dap}
================

Jak bylo popsáno [v částech](#pozadavky-balik@) [a](#reserse-balik@), dap je *tar.gz* archiv obsahující soubory a metadata jednoho nebo více asistentů. V této části práce je podrobně popsána specifikace formátu dap.

Jeden dap je *tar.gz* archiv [@Tar2013][@Gzip2010] pojmenovaný `<název>-<verze>.dap`, konkrétně pak například `python-0.8.0.dap`. Název je zde uveden i s příponou -- typická přípona *tar.gz* archivu `.tar.gz` či `.tgz` je nahrazena příponou `.dap`.

Nahrazení typické přípony je provedeno proto, aby byl dap uživateli jasně identifikovatelný a aby nedocházelo k omylům při pokusu nainstalovat místo dapu běžný *tar.gz* archiv.

Adresářová struktura uvnitř archivu
-----------------------------------

Dap má uvnitř archivu striktně danou [adresářovou strukturu](#dap-dir@), která odpovídá adresářové struktuře, kterou očekává DevAssistant, doplněnou o další soubory a adresáře potřebné pouze pro dap.

\begin{dirfigure}
\dirtree{%
	.1 <název>-<verze>/\DTcomment{hlavní adresář}.
		.2 assistants/\DTcomment{adresář s asistenty}.
			.3 crt|mod|prep|task/\DTcomment{adresáře s asistenty daného typu}.
				.4 <název>.yaml\DTcomment{asistent první úrovně}.
				.4 <název>/\DTcomment{adresář s asistenty druhé úrovně}.
					.5 *.yaml/\DTcomment{asistenty druhé úrovně}.
					.5 */\DTcomment{adresáře s asistenty další úrovně (dále obdobně)}.
		.2 doc/\DTcomment{adresář s dokumentací}.
			.3 <název>/.
				.4 *\DTcomment{libovolné soubory a adresáře s dokumentací}.
		.2 files/\DTcomment{adresář s dalšími soubory}.
			.3 crt|mod|prep|task|snippets/.
				.4 <název>/.
					.5 *\DTcomment{libovolné soubory}.
					.5 */\DTcomment{další úrovně}.
		.2 icons/\DTcomment{adresář s ikonami asistentů}.
			.3 crt|mod|prep|task|snippets/.
				.4 <název>.png|.svg\DTcomment{ikona pro asistent první úrovně}.
					.5 */\DTcomment{další úrovně}.
		.2 snippets/\DTcomment{adresář se snipety}.
			.3 <název>.yaml\DTcomment{snipet první úrovně}.
			.3 <název>/\DTcomment{adresář pro snipety druhé úrovně}.
				.4 *.yaml\DTcomment{snipety druhé úrovně}.
				.4 */\DTcomment{adresáře se snipety další úrovně (dále obdobně)}.
		.2 meta.yaml\DTcomment{soubor s metadaty}.
}
\caption{Generický dap \label{dap-dir}}
\end{dirfigure}

Asistenty a snipety mají hierarchickou strukturu. Platí, že asistent nejvyšší úrovně musí mít vždy stejný název jako dap, ve kterém je obsažen. Asistenty či snipety dalších úrovní se mohou jmenovat libovolně[^libovolne]. Pokud je v dapu asistent nižší úrovně, vždy v něm musí být i asistent úrovně vyšší. Například pro asistent `crt/python/flask.yaml` musí existovat asistent `crt/python.yaml` -- ten ale může obsahovat jen metadata a nemusí sám o sobě nic vykovávat.

Ikony (`icons`) a soubory (`files`) náleží jednotlivým asistentům a je tedy nutné je patřičně zařadit. Například asistentu `crt/python/flask.yaml` náleží ikona `crt/python/flask.svg` či `crt/python/flask.png` ze složky `icons` a žádná jiná.

Adresáře, které nejsou využité (jsou prázdné) by dap neměl obsahovat. Veškerý obsah hlavního adresáře, kromě souboru `meta.yaml` je volitelný. Teoreticky tak může existovat dap obsahující pouze metadata, prakticky však takový dap nedává příliš smysl. Jakýkoliv obsah mimo tuto danou strukturu je nepřípustný.

Adresář `doc` byl přidán pro účely dapu, aby bylo možné společně s asistenty distribuovat i dokumentaci. Například povinně uváděný text licence, za jejíchž podmínek je obsah dapu distribuován.

[Adresářová struktura](#dap-dir-example@) ukazuje příklad u reálného dapu [@da-fedora].

\begin{dirfigure}
\dirtree{%
	.1 python-0.8.0/.
		.2 assistants/.
			.3 crt/.
				.4 python.yaml.
				.4 python/.
					.5 django.yaml.
					.5 flask.yaml.
					.5 gtk3.yaml.
					.5 lib.yaml.
		.2 doc/.
			.3 python/.
				.4 LICENSE.
		.2 files/.
			.3 crt/.
				.4 python/.
					.5 lib/.
						.6 setup.py\ldots.
		.2 icons/.
			.3 crt/.
				.4 python.svg.
		.2 meta.yaml.
}
\caption{Reálný dap \label{dap-dir-example}}
\end{dirfigure}

[^libovolne]: V rámci pravidel souborového systému.

Soubor meta.yaml
----------------

Soubor `meta.yaml` obsahuje metadata dapu specifikovaná [v části](#pozadavky-balik@). Z důvodů popsaných [v části](#reserse-archiv@) se jedná o YAML soubor. Soubor obsahuje tyto direktivy:

### package_name

> Název dapu, povinný údaj. Smí obsahovat malá písmena obsažená v tabulce ASCII[^ascii], číslice a znaky podtržítko (`_`) a spojovník (`-`), avšak první a poslední znak smí být pouze písmeno nebo číslice.
> 
> Délka názvu není nijak omezena, přesto není praktické vybírat extrémně dlouhé názvy, například kvůli možným omezením souborového systému, ale také kvůli uživatelské (ne)přívětivosti.
> 
> Příklady validních názvů:
> 
>  * python
>  * foo
>  * fit-cvut
>  * 666
>  * pivo
>  * blok_6

[^ascii]: Tedy písmena anglické abecedy.

### version

> Verze dapu, povinný údaj. Verze musí obsahovat alespoň jedno nezáporné číslo a může obsahovat neomezeně dalších nezáporných čísel oddělených tečkou. Číslice se uvádí bez nadbytečných úvodních nul. Za číselnou verzí může být bez oddělení uveden text `dev`, `a`, nebo `b` značící v uvedeném pořadí blíže nespecifikovanou vývojovou verzi, alfa verzi a betaverzi.
> 
> Příklady verzí seřazené od nejstarší po nejnovější:
> 
>  * 0.99
>  * 1
>  * 1.0.5
>  * 1.1dev
>  * 1.1a
>  * 1.1b
>  * 1.1

### summary

> Krátký popis dapu, povinný údaj. Slouží k rychlému obeznámení uživatele s obsahem dapu, měl by být napsaný v anglickém jazyce.
> 
> Příklady vhodných popisů:
> 
>  * Python assistants for creating Flask, Djnago and GTK3 apps or pure Python libraries
>  * Set of assistants for students of FIT CTU in Prague

### license

> Licence obsahu dapu, povinný údaj. Používají se specifikátory licencí z RPM balíčků distribuce Fedora [@GoodLicenses][@GoodLicenses2]. Je možné použít pouze ve Fedoře povolené licence [@GoodLicenses][@GoodLicenses2], které zaručují svobodné šíření obsahu. Tagy lze kombinovat pomocí slov `and` a `or` -- k tomuto účelu je možné použít i závorky a vyhodnocení probíhá podobně jako v jiných logických výrazech. Slovo `and` se používá v případě, že část obsahu je šířena pod jednou a část pod druhou licencí, slovo `or` se používá pokud je možné licenci si vybrat [@LicensesCombined].
> 
> V případě zvýšené poptávky po možnosti uvedení nesvobodné licence [@BadLicenses], je možné později povolit v metadatech i tuto variantu. Pro účely repozitáře dapů ale bude nadále možné nahrávat jen svobodný obsah.
> 
> Příklady validních specifikátorů licence:
> 
>  * AGPLv3
>  * GPL+ or Artistic
>  * GPLv2+
>  * LGPLv2+ and LGPLv2 and LGPLv3+ and (GPLv3 or LGPLv2) and (GPLv3+ or LGPLv2) and (CC-BY-SA or LGPLv2+) and (CC-BY-SA or LGPLv2) and CC-BY and BSD and MIT and Public Domain

### authors

> Seznam autorů obsahu dapu, povinný údaj. U každého autora je nejprve uvedeno celé jméno a poté volitelně e-mailová adresa v lomených závorkách, podobně jako při e-mailové komunikaci. Zavináč v adrese lze nahradit sekvencí `_at_`.
> 
> Příklady validních autorů:
> 
>  * Miroslav Hrončok \<miroslav.hroncok@fit.cvut.cz\>
>  * Miroslav Hrončok \<miroslav.hroncok_at_fit.cvut.cz\>
>  * Miroslav Hrončok
>  * Никола I Петровић-Његош

### description

> Delší, volitelný popis obsahu dapu. Slouží k podrobnějšímu obeznámení uživatelů s obsahem dapu a způsobu využití asistentů v něm obsažených. Obsah by se dal přirovnat k běžnému obsahu souboru README a měl by být v anglickém jazyce. V popisu lze použít formátování pomocí Markdownu [@Markdown2014].
> 
> Příklad je uveden [v ukázce](#meta-yaml-extended@).

### homepage

> Webová stránka dapu, nepovinný údaj. Zadána ve formě platného URL. Je možné použít adresy využívající protokoly HTTP, HTTPS a FTP. Není možné použít adresy s IP adresou místo jména domény. Jako webová stránka dapu může sloužit například odkaz na repozitář s kódem.
> 
> Příklady validních URL webových stránek:
> 
>  * https://github.com/hroncok/dap-travis
>  * http://users.fit.cvut.cz/~hroncmir/dap-travis
>  * ftp://users.fit.cvut.cz/hroncmir/dap-travis

### bugreports

> Místo, kam reportovat chyby, nepovinný údaj. Buďto validní URL podle stejných podmínek jako v případě *homepage*, nebo e-mailová adresa. Zavináč v adrese lze nahradit sekvencí `_at_`.
> 
> Příklady validních záznamů pro položku *bugreports*:
> 
>  * https://github.com/hroncok/dap-travis/issues
>  * miroslav.hroncok@fit.cvut.cz
>  * devassistant@lists.fedoraproject.org

[V ukázce](#meta-yaml-simple) můžete vidět příklad souboru `meta.yaml`, který obsahuje pouze povinné údaje, a [v ukázce](#meta-yaml-extended@) pak příklad doplněný o údaje nepovinné.

```{caption="Minimální příklad souboru meta.yaml {#meta-yaml-simple}" .yaml}
package_name: travis
version: 0.0.1dev
license: ISC
authors: [Miro Hrončok <miro@hroncok.cz>]
summary: Adds Travis CI to your projects
```

```{caption="Soubor meta.yaml s využitím všech volitelných položek {#meta-yaml-extended}" .yaml}
package_name: travis
version: 0.0.1dev
license: ISC
authors: [Miro Hrončok <miro@hroncok.cz>]
homepage: https://github.com/hroncok/dap-travis
summary: Adds Travis CI to your projects
bugreports: https://github.com/hroncok/dap-travis/issues
description: |
    This mod assistant allows
    [Travis CI](https://travis-ci.org/) for you project.
    Your project has to be already on GitHub.
    
    Run `da mod travis [-p <path>]` and DevAssistant will
    check if the current working directory or path specified
    by `-p` is a git repository with GitHub *remote* specified.
    
    If so, it will allow Travis checks for your project and add
    `.travis.yml` (if not already present) with default content
    for language guessed from `.devassistant`, or blank when
    `.devassistant` is not available.
    
    ### More options:
    
     * `--url` - changes Travis CI URL, default https://travis-ci.org/
```

Knihovna pro načítání metadat dapů {#daploader}
==================================

Strojově číst metadata dapu lze následujícím postupem:

 1. extrahovat dap jako *tar.gz* archiv,
 2. najít `meta.yaml` v jediné složce, která byla vyextrahována,
 3. parsovat YAML a číst potřebné údaje.

Rozhodl jsem se tedy napsat knihovnu, která umožní tento postup automatizovat a kontrolovat, že načítaný dap splňuje specifikaci. Tato knihovna umožní:

 * načítat dapy a programově přistupovat k jejich metadatům,
 * rozbalovat dapy na určité místo,
 * kontrolovat správnost dapu a vypisování chyb a varovní v případě nesprávných dat.

Knihovnu jsem nazval *daploader*.

Použité technologie
-------------------

Vzhledem k tomu, že aplikace DevAssistant je napsána v programovacím jazyce Python [@Pilgrim2010] a je žádoucí, aby knihovna šla použít přímo z této aplikace, zvolil jsem také programovací jazyk Python. Implementace v jiném jazyce by sice byla možná, ale bylo by pak nutné řešit komunikaci této knihovny s aplikací DevAssistant pomocí nějaké mezivrstvy [@Altis2014], což by bylo zbytečně komplikované.

Protože DevAssistant je napsán tak, aby jej bylo možné interpretovat jak Pythonem ve verzi 2, tak Pythonem ve verzi 3, a protože je to považováno za vhodné [@Pilgrim2010], podporuje *daploader* taktéž obě používané verze Pythonu.

Pro parsování souboru `meta.yaml` jsem použil modul PyYAML [@Simonov2014], jinak jsem si vystačil se standardními moduly obsaženými v distribuci Pythonu.

Zvolil jsem metodu TDD a pro testování jsem použil nástroj pytest [@Krekel2013].

> Programování řízené testy (z anglického *Test-driven development* -- TDD) je přístup k vývoji softwaru, který je založen na malých, stále se opakujících krocích, vedoucích ke zefektivnění celého vývoje.
Prvním krokem je definice funkcionality a následné napsání testu, který tuto funkcionalitu ověřuje. Poté přichází na řadu psaní kódu a nakonec úprava tohoto kódu. [@wiki-tdd]

Načtení dapu
------------

*Daploader* poskytuje třídu *Dap*. Její konstruktor načte dap a pokusí se z něj získat obsah souboru `meta.yaml` -- pokud se načtení nepodaří (nejedná se o *tar.gz* archiv nebo v archivu není právě jeden soubor `meta.yaml`), knihovna vyvolá výjimku. V případě správného načtení jsou jednotlivé položky ze souboru `meta.yaml` k dispozici ve formě asociativního pole[^pole].

[^pole]: V Pythonu nazvaného slovník -- *dict*

Kontroly
--------

Třída *Dap* obsahuje metodu `check()`, která spouští rutinu kontrol. Pokud některé kontroly selžou, chyby nebo varování jsou nahlášeny uživateli do zvoleného místa výstupu (výchozí je standardní chybový výstup), případně je vyvolána výjimka.

Chybu vyvolá:

 * chybějící povinná položka v souboru `meta.yaml`,
 * nevalidní hodnota položky v souboru `meta.yaml`,
 * přebytečná položka v souboru `meta.yaml` neobsažená ve specifikaci,
 * špatně pojmenovaný hlavní adresář,
 * soubor nebo adresář mimo hlavní adresář,
 * špatně pojmenovaný soubor s dapem,
 * soubor nebo adresář mimo povolenou strukturu,
 * adresář s asistenty nebo snipety nižší úrovně bez patřičného asistentu nebo snipetu vyšší úrovně.

Varování vyvolá:

 * dap obsahující pouze soubor `meta.yaml`,
 * prázný adresář v dapu,
 * chybějící ikona pro asistent nebo snipet,
 * vícenásobná ikona pro jeden asistent nebo snipet,
 * přebytečná ikona pro neexistující asistent nebo snipet,
 * přebytečné soubory pro neexistující asistent nebo snipet.

Kromě metody `check()` lze použít i program `daplint` (součást knihovny), který umožní provádět kontroly z příkazové řádky jako [v ukázce](#daplint-output).

```{caption="Příklad výstupu programu daplint {#daplint-output}"}
$ daplint foo-1.0.0.dap 
foo-1.0.0.dap: ERROR: out is outside of foo-1.0.0 top-level directory
foo-1.0.0.dap: WARNING: Only meta.yaml in dap
```

Další funkce
------------

Třída *Dap* také obsahuje metodu na extrahování dapu na určité místo. Knihovna nabízí porovnávací funkci verzí, která je možná použít například jako [v ukázce](#dapver).

```{caption="Použití porovnávače verzí z Pythonu 2 {#dapver}" .python}
from daploader import dapver
versions = ['1.0', '1.0.5', '1.1dev', '1.1a', '1.1', '1.1.1', '1.2']
assert versions == sorted(versions, cmp=dapver.compare)
```

Testy
-----

Díky zvolené metodě TDD [@wiki-tdd] mají jednotlivé kontroly stoprocentní pokrytí testy. Testy jsou součástí zdrojových kódů knihovny, které naleznete na přiloženém médiu.

Licence
-------

Knihovna *daploader* je dostupná pod licencí GNU GPL verze 2 [@GPLv2] nebo vyšší. Plné znění licence je  součástí zdrojových kódů knihovny, které naleznete na přiloženém médiu.

Tato licence byla zvolena podle licence aplikace DevAssistant, aby bylo v budoucnu možné libovolně přesouvat kód mezi knihovnou *daploader* a DevAssistantem, případně do aplikace knihovnu začlenit.

Instalace
---------

Knihovna *daploader* je dostupná v repozitáři PyPI [@PythonSoftwareFoundation2014] a je možné ji nainstalovat například pomocí programu `pip` [@PyPA2014] ([v ukázce](#daploader-install)).

```{caption="Instalace knihovny daploader {#daploader-install}"}
pip install daploader
```

Repozitář
=========

V této části je popsána implementace repozitáře dapů nazvaná *Dapi* -- *DevAssistant Package Index*.

Použité technologie
-------------------

### Backend

Aby bylo jednoduché použít vytvořenou knihovnu *daploader* popsanou [v části](#daploader@), zvolil jsem programovací jazyk Python [@Pilgrim2010]. Opět platí, že použít jiný programovací jazyk by bylo možné, ale zbytečně komplikované kvůli nutnosti přidat mezivrstvu [@Altis2014].

Pro vytváření webových aplikací v programovacím jazyce Python existuje celá řada frameworků [@Athanasias2014]. Výběr mezi nimi je záležitostí poskytovaných funkcí, množství dokumentace, dostupných modulů, ale i osobních preferencí.

Zvolil jsem framework Django [@DjangoSoftwareFoundation2014][@Holovaty2008], který poskytuje softwarovou architekturu MVC.

> Model-view-controller (MVC) je softwarová architektura, která rozděluje datový model aplikace, uživatelské rozhraní a řídicí logiku do tří nezávislých komponent tak, že modifikace některé z nich má jen minimální vliv na ostatní. [@wiki-mvc]

Pro Django navíc existuje celá řada doplňků, modulů do Pythonu, které umožňují řešit některé požadavky na repozitář specifikované [v části](#pozadavky-repozitar@):

 * django-taggit [@Gaynor2014] pro klasifikaci pomocí tagů,
 * Haystack [@Lindsley2011] a Whoosh [@Chaput2013] pro fulltextové vyhledávání,
 * Django REST framework [@Christie2014] pro API,
 * Python Social Auth [@Aguirre2012] pro autentizaci pomocí služeb třetích stran.

Použil jsem další moduly do Pythonu k řešení vyvstaných problémů nespecifikovaných v požadavcích:

 * South [@Godwin2010] pro migraci dat při změně modelů,
 * Django Simple Captcha [@Bonetti2013] pro zobrazení CAPTCHA u formulářů dostupných pro nepřihlášené uživatele,
 * django-gravatar2 [@Waddington2013] pro zobrazení Gravatarů [@Gravatar2014] uživatelů,
 * markdown2 [@Mick2014] pro zobrazení dlouhých popisů dapů.

A samozřejmě knihovnu daploader.

Aplikace je psaná pro Python 2.7, na podporu Pythonu 3 nebyl kladen důraz, přesto je kód psán tak, aby případné portování na Python 3 probíhalo bez závažných problémů.

### Databáze

Framework Django umožňuje použít databázové systémy SQLite [@SQLite], MySQL[^mysql] [@Oracle2014] nebo PostgreSQL [@PostgreSQL2014]. Díky dostatečné úrovni abstrakce z hlediska programování na použitém databázovém systému nezáleží.

Pro vývoj a běh aplikace na vlastním systému jsem použil SQLite -- odlehčenou databázi uloženou v jednom souboru vhodnou právě na tento účel [@Tezer2014].

Pro nasazení aplikace jsem pak použil PostgreSQL, které poskytuje oproti MySQL řadu výhod, především absolutně otevřený vývoj a lépe zajištěnou integritu dat [@Tezer2014] nebo speciální možnosti pro ukládání NoSQL dat [@Haas2014].

[^mysql]: Případě kompatibilní náhrady jako MariaDB [@MariaDBFoundation2014]

### Frontend

V části, která interaguje s uživatelem, jsem použil knihovny jQuery [@jQuery2014] a Bootstrap [@Otto2014], abych se vzhledem přiblížil k webové stránce aplikace DevAssistant [@RedHat2013] a abych mohl řešit layout webového rozhraní dostatečně progresivně. Dále jsem použil javascriptové knihovny chosen [@Harvest2013] pro uživatelsky přívětivější formuláře ([na obrázku](#pic:chosen@)) a toc [@Allen2014] pro vygenerování obsahu stránky.

![Knihovna chosen v praxi {#pic:chosen}](images/chosen)

### Nasazení

Aplikaci jsem nasadil na cloudovou platformu OpenShift [@RedHat2014a]. Která mi umožní:

 * nasazení pomocí gitu [@Chacon2009],
 * automatickou instalaci závislostí z PyPI [@PythonSoftwareFoundation2014],
 * použití Pythonu [@Pilgrim2010] a PostgreSQL [@PostgreSQL2014],
 * pravidelné spouštění skriptů pomocí cronu.

> Cron je softwarový démon, který v operačních systémech automatizovaně spouští v určitý čas nějaký příkaz resp. proces (skript, program apod.). Jedná se vlastně o specializovaný systémový proces, který v operačním systému slouží jakožto plánovač úloh, jenž umožňuje opakované spouštění periodicky se opakujících procesů (např. noční běhy dávkových úloh při hromadném zpracování dat) apod. [@wiki-cron]

Základní využití je navíc zcela zdarma.

Architektura
------------

Dapi obsahuje několik modelů reprezentující dapy, uživatele apod. Jejich vztahy jsou znázorněny [na obrázku](#pic:models@). Bílé obdélníčky znázorňují modely převzaté z Djanga nebo z některých použitých modulů.

![ERM diagram aplikace {#pic:models}](pdfs/models)

### MetaDap

*MetaDap* uchovává informace o dapu, bez ohledu na jeho konkrétní verzi. Tedy název dapu, vlastníka, spoluvlastníky, hodnocení, tagy, hlášení a informace o tom, je-li *MetaDap* aktivní[^aktivni]. Dále obsahuje odkaz na poslední a poslední stabilní verzi dapu, pokud je k dispozici.

Informace o celkovém počtu hodnocení a průměrném hodnocení je uchována v databázi a přepočítává se, až když dojde k nějaké změně. Je to proto, aby se při každém načtení stránky s dapem nemusely z databáze načítat všechna jeho hodnocení. Stejným způsobem fungují odkazy na poslední a poslední stabilní verzi dapu.

[^aktivni]: Neaktivní MetaDap plní roli smazaného dapu bez nutnosti ho úplně smazat.

### Dap

*Dap* představuje dap v jedné konkrétní verzi. Uchovává metadata dapu (kromě názvu), odkaz na *MetaDap* a cestu k souboru s dapem.

### Author

Author představuje jednoho autora dapu. Je vázán na konkrétní verzi dapu, tedy na model *Dap*.

### Report

*Report* představuje hlášení o škodlivém dapu. Uchovává se odkaz na *MetaDap*, druh škodlivosti, obsah hlášení, informace, jestli je hlášení vyřízeno, a odkaz na uživatele, který dap nahlásil, případě volitelně e-mailová adresa, pokud šlo o nepřihlášeného uživatele a ten ji vyplnil. Dále je uchováván odkaz na příslušné verze (modely *Dap*), pokud byly při hlášení uvedeny.

V aplikaci existují tyto druhy škodlivosti:

 * legální problém (problémy s autorským právem, nesvobodný nebo patentovaný obsah),
 * malware (škodlivý kód),
 * nenávistný nebo jinak nevhodný obsah (rasismus, sexismus, podněcování k nenávisti, pornografie apod.),
 * spam.

### Rank

*Rank* představuje hodnocení jednoho uživatele jednoho *MetaDapu*. Uchovává odkaz na *MetaDap* a uživatele (model *User* z Djanga) a výši hodnocení (1 až 5 „hvězdiček“).

### Profile

Django poskytuje model *User* reprezentující uživatele aplikace. Do tohoto modelu není možné přidávat atributy, proto existuje model *Profile*, který se váže právě na jednoho uživatele a který uchovává dodatečné informace [@DjangoSoftwareFoundation2014a].

V případě Dapi je to odkaz na služby, pomocí kterých když se uživatel přihlásí, tak přepíší data uživatele (jméno a e-mailovou adresu). To je nutné proto, že uživatel se může přihlašovat přes více služeb, které mohou poskytovat různé údaje. Takto si může vybrat, které údaje mají platit. Ve výchozím stavu takto přepisuje data první použitá služba.

*Profil* nadále může obsahovat další data chybějící v modelu *User*, pokud by bylo rozhodnuto, že to je potřeba -- například telefonní číslo apod. Podobně metody, který by se normálně implementovaly v modelu *User* jsou implementovány v modelu *Profile*.

Stránky
-------

Uživatel interaguje s aplikací prostřednictvím jednotlivých stránek. Zde je popsán jejich obsah, případně zvolený způsob implementace, pokud není triviální.

Součástí všech stránek je navigační prvek -- horní lišta obsahující odkazy na jednotlivé části aplikace, dokumentaci a přihlášení či odhlášení a vyhledávací políčko. V případě, že je uživatel přihlášen, obsahuje navigace odkaz na stránku s jeho profilem a na stránku, kde může svůj profil upravit.

### Hlavní stránka aplikace

Hlavní stránka aplikace je místem, kudy uživatel na stránku vstupuje, pokud nepoužil odkaz vedoucí na konkrétní obsah. Obsahuje velmi stručnou informaci o aplikaci a seznam nejlépe hodnocených, nejčastěji hodnocených a nejnověji nahraných dapů.

### Přihlašovací stránka

Přihlašovací stránka nabízí uživateli přihlášení pomocí služeb třetích stran, konkrétně dle zadání GitHub [@GitHub2014] a Fedora [@RedHat2013a]. Uživateli je zobrazena v případě, že se nepřihlášený pokusí přistoupit na stránku, kde je přihlášení vyžadováno.

Analogicky existuje stránka odhlašovací, ta však nemá žádný obsah a odhlášeného uživatele přesměruje na hlavní stránku.

### Nahrání dapu

Stránka s formulářem sloužícím k nahrání dapu. Je zobrazena pouze přihlášeným uživatelům. Po nahrání je dap zkontrolován knihovnou daploader a v případě, že na to má uživatel oprávnění, je zařazen do repozitáře -- tento proces je zobrazen [na obrázku](#pic:logic).

![Vývojový diagram nahrávání dapu {#pic:logic}](pdfs/logic)

### Zobrazení dapu

Stránka s detaily dapu -- je zobrazena [na obrázku](#pic:dap). Zobrazuje informace z modelu *Dap* a *MetaDap*. Pokud není určeno specificky, jakou verzi zobrazit, je zobrazena poslední stabilní verze. Pokud žádná stabilní verze není dostupná, je zobrazena poslední vývojová. Pokud dap neobsahuje žádnou verzi, jsou zobrazeny pouze informace z modelu *MetaDap*.

![Stránka s dapem {#pic:dap}](images/dap)

Vlastníkovi a spoluvlastníkovi dapu a administrátorovi repozitáře je umožněno mazat jednotlivé verze dapu. Všem návštěvníkům jsou v některých případech zobrazena varování:

 * Toto není nejnovější stabilní verze dapu.
 * Toto není nejnovější verze dapu.
 * Toto není stabilní verze dapu.
 * Tento dap má nevyřízená hlášení.
 * Tento dap není aktivní.

### Administrace dapu

Stránka je dostupná pouze vlastníkovi dapu, případně administrátorovi repozitáře. Umožňuje spravovat spoluvlastníky, označit dap jako neaktivní, úplně jej smazat, případně darovat jinému uživateli.

### Správa tagů dapu

Vlastníkovi a spoluvlastníkovi dapu a administrátorovi repozitáře je zde umožněno nastavit tagy pro dap.

### Opuštění dapu

Spoluvlastníkovi dapu je zde umožněno na pozici spoluvlastníka rezignovat.

### Nahlášení dapu

Návštěvník stránky zde může nahlásit dap jako škodlivý. Pro nepřihlášené uživatele je zde možnost zadat i e-mailovou adresu a nutnost opsat CAPTCHA kód z obrázku. Po nahlášení je odeslán informační e-mail vlastníkovi dapu a administrátorovi či administrátorům repozitáře.

### Seznam hlášení dapu

Seznam nezpracovaných hlášení daného dapu. Administrátor může jednotlivá hlášení označit jako zpracovaná/vyřízená -- tato hlášení pak nikdo jiný nevidí.

### Zobrazení tagu

Stránkovaný seznam všech dapů se zvoleným tagem -- je zobrazen při kliknutí na tag. Obsahuje název, krátký popis, vlastníka a hodnocení dapu. Název dapu slouží jako odkaz na jeho detailní zobrazení.

### Zobrazení uživatele

Stránka s profilem uživatele -- je zobrazena [na obrázku](#pic:user). Obrázek uživatele je načten ze služby Gravtar [@Gravatar2014].

![Stránka s uživatelským profilem {#pic:user}](images/user)

### Úprava uživatele

Úprava uživatelského profilu -- je dostupná pouze danému uživateli nebo administrátorovi repozitáře. Umožňuje změnu uživatelských údajů (přihlašovacího jména, křestního jména, příjmení, e-mailové adresy), asociování a deasociování jednotlivých služeb pro přihlášení, správu služeb, které přepisují uživatelské údaje při přihlášení, a smazání uživatele, pokud nevlastní žádné dapy.

### Výsledky vyhledávání

Stránkovaný seznam s výpisem všech dapů odpovídajících hledané frázi, zobrazený stejně jako seznam dapů se zvoleným tagem. Vyhledávání je realizováno přes souborovou databázi Whoosh [@Chaput2013] -- při každém uložení nebo smazání dapu je tato databáze aktualizována. V případě většího provozu na webové aplikaci je možné databázi místo toho aktualizovat asynchronně pomocí služby cron [@wiki-cron].

### Podmínky služby

Statická stránka zobrazující podmínky použití služby. Pro větší přehlednost je zobrazen obsah pomocí javascriptové knihovny toc [@Allen2014]. Text podmínek dodal Richard Fontana, zaměstnanec firmy Red Hat [@RedHat2014].

Podmínky zajišťují, že provozovatel služby nezískává žádná speciální práva na uživateli nahraný obsah (kromě práva tento obsah zobrazit a šířit uživatelům), ale také za daný obsah nepřejímá zodpovědnost.

API
---

Dapi nabízí API pro práci s repozitářem například z aplikace DevAssistant. Na základě pokynů od vedoucího práce jde zatím pomocí API provádět jen neautorizované čtecí operace. Tedy:

 * získat seznam uživatelů,
 * získat podrobnosti uživatele,
 * získat seznam *MetaDapů*,
 * získat podrobnosti *MetaDapu*,
 * získat seznam *Dapů*,
 * získat podrobnosti *Dapu*,
 * získat výsledky vyhledávání.

API je realizováno pomocí modulu Django REST framework [@Christie2014]. Díky tomu je možné API procházet přímo v prohlížeči v rámci aplikace Dapi. Použití Django REST frameworku také zjednodušuje budoucí možnou implementaci zapisovací části API.

Jednotlivé objekty a jejich seznamy jsou serializovány pomocí YAMLu -- to je sice pro API poměrně netradiční řešení, ale vzhledem k tomu, že DevAssistant již závisí na knihovnách, které YAML parsují, je YAML nejvhodnější volbou. Příklad serializovaného dapu můžete vidět [v ukázce](#api-dap@) -- tam, kde je to vhodné, jsou serializována i data metadapu (například název dapu).

> Při práci na Dapi jsem přispěl i do projektu Django REST framework, aby bylo možné vhodně a čitelně serializovat v YAMLu i řetězce se znaky mimo ASCII tabulku, například moje příjmení.

```{caption="Příklad použití API {#api-dap}"}
$ curl http://dapi.devassistant.org/api/daps/python-0.8.0/
active: true
api_link: http://dapi.devassistant.org/api/daps/python-0.8.0/
authors: [Bohuslav Kabrda <bkabrda@redhat.com>]
bugreports: https://github.com/bkabrda/devassistant/issues
description: 'Set of crt assistants for Python.

  Contains assistants that let you kickstart new Django or
  Flask web application. Pure Python library or GTK3 app.

  Supports both Python 2 and 3.'
download: http://dapi.devassistant.org/download/python-0.8.0.dap
homepage: https://github.com/bkabrda/devassistant-assistants-fedora
human_link: http://dapi.devassistant.org/dap/python/0.8.0/
id: 4
is_latest: true
is_latest_stable: true
is_pre: false
license: GPLv2+
metadap: http://dapi.devassistant.org/api/metadaps/python/
package_name: python
reports: 0
summary: Python assistants originally shipped with devassistant itself
version: 0.8.0
```

### Testy

Základní funkcionalita API je při každém nasazení aplikace na OpenShift automaticky ověřena službou Runscope [@Runscope2014].

### Daploader

Do knihovny daploader jsem doplnil funkce na práci s API Dapi. Při kontrole je možné volitelně rozhodnout, zda kontrolovat i přítomnost dapu stejného jména na Dapi. Kontrola v případě pozitivního nálezu vyvolá varování.

Zároveň jsem knihovnu rozšířil o program `dapi`, který umožňuje zobrazovat data z Dapi a instalovat jednotlivé dapy do adresářů, kde je DevAssistant očekává. Jedná se ale pouze o technologické demo - metadata z instalovaných dapů nejsou nikam ukládána a není tedy možné sledovat, zda jsou nainstalované dapy aktuální, případně jestli byly nainstalovány z Dapi, či nikoli. Program `dapi` umožňuje:

 * Vyhledávat dapy
 * Zobrazit informace o dapu v poslední nebo konkrétní verzi
 * Nainstalovat dap poslední nebo konkrétní verze
 * Aktualizovat[^aktualizovat] dap poslední nebo konkrétní verze
 * Nainstalovat nebo aktualizovat dap ze souboru
 * Aktualizovat všechny nainstalované dapy
 * Odinstalovat dap
 * Zobrazit všechny nainstalované dapy

[^aktualizovat]: Tedy nahradit nainstalovanou verzi jinou

Příklad práce s `dapi` můžete vidět [v ukázce](#dapi-cli@). Nápověda je pak součástí programu (přepínač `--help`).

```{caption="Příklad práce s dapi {#dapi-cli}"}
$ dapi search flask
python - Python assistants originally shipped with devassistant itself
$ file .devassistant
.devassistant: ERROR: cannot open `.devassistant' (No such file or dir
ectory)
$ dapi install python
$ tree .devassistant
.devassistant
├── assistants
│   └── crt
│       ├── python
│       │   ├── django.yaml
│       │   ├── flask.yaml
│       │   ├── gtk3.yaml
│       │   └── lib.yaml
│       └── python.yaml
├── doc
│   └── python
│       ├── LICENSE
│       └── NOTICE
├── files
(...zkráceno...)
└── icons
    └── crt
        └── python.svg

14 directories, 22 files
$ dapi uninstall python
$ tree .devassistant
.devassistant
├── assistants
│   └── crt
├── doc
├── files
│   └── crt
└── icons
    └── crt

7 directories, 0 files
```

Licence
-------

Z důvodu licenční kompatibility s knihovnou daploader musí být kód Dapi vydán pod licencí kompatibilní s GNU GPL verze 2 [@GPLv2] nebo vyšší. Nabízí se použití stejné licence, zvolil jsem ale raději licenci GNU AGPL verze 3 [@AGPLv3], která je kompatibilní s GNU GPL verze 3[^verze] [@GPLv3]. Licence AGPL na rozdíl od GPL upravuje podmínky při vzdálenému přistupování k aplikaci -- tedy například přes webové rozhraní nebo API. Poskytování vzdáleného přístupu je u AGPL vyhodnoceno jako šíření aplikace.

Jakýkoliv obsah, který není kódem, například texty apod., je pak vydán pod licencí Creative Commons Attribution-ShareAlike 4.0 International [@CC-BY-SA].

[^verze]: AGPL verze 2 není kompatibilní s GPL verze 2
