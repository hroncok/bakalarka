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

Asistenty a snipety mají hierarchickou strukturu. Platí, že asistent nejvyšší úrovně musí mít vždy stejný název jako dap, ve kterém je obsažen. Asistenty či spinety dalších úrovní se mohou jmenovat libovolně[^libovolne]. Pokud je v dapu asistent nižší úrovně, vždy v něm musí být i asistent úrovně vyšší. Například pro asistent `crt/python/flask.yaml` musí existovat asistent `crt/python.yaml` -- ten ale může obsahovat jen metadata a nemusí sám o sobě nic vykovávat.

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

Soubor `meta.yaml` obsahuje metadata dapu specifikovaná [v části](#pozadavky-balik@). Z důvodů popsaných [v části](#reserse-metadata@) se jedná o YAML soubor. Soubor obsahuje tyto direktivy:

**package_name**

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

**version**

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

**summary**

> Krátký popis dapu, povinný údaj. Slouží k rychlému obeznámení uživatele s obsahem dapu, měl by být napsaný v anglickém jazyce.
> 
> Příklady vhodných popisů:
> 
>  * Python assistants for creating Flask, Djnago and GTK3 apps or pure Python libraries
>  * Set of assistants for students of FIT CTU in Prague

**license**

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

**authors**

> Seznam autorů obsahu dapu, povinný údaj. U každého autora je nejprve uvedeno celé jméno a poté volitelně e-mailová adresa v lomených závorkách, podobně jako při e-mailové komunikaci. Zavináč v adrese lze nahradit sekvencí `_at_`.
> 
> Příklady validních autorů:
> 
>  * Miroslav Hrončok \<miroslav.hroncok@fit.cvut.cz\>
>  * Miroslav Hrončok \<miroslav.hroncok_at_fit.cvut.cz\>
>  * Miroslav Hrončok
>  * Никола I Петровић-Његош

**description**

> Delší, volitelný popis obsahu dapu. Slouží k podrobnějšímu obeznámení uživatelů s obsahem dapu a způsobu využití asistentů v něm obsažených. Obsah by se dal přirovnat k běžnému obsahu souboru README a měl by být v anglickém jazyce. V popisu lze použít formátování pomocí Markdownu [@Markdown2014].
> 
> Příklad je uveden [v ukázce](#meta-yaml-extended@).

**homepage**

> Webová stránka dapu, nepovinný údaj. Zadána ve formě platného URL. Je možné použít adresy využívající protokoly HTTP, HTTPS a FTP. Není možné použít adresy s IP adresou místo jména domény. Jako webová stránka dapu může sloužit například odkaz na repozitář s kódem.
> 
> Příklady validních URL webových stránek:
> 
>  * https://github.com/hroncok/dap-travis
>  * http://users.fit.cvut.cz/~hroncmir/dap-travis
>  * ftp://users.fit.cvut.cz/hroncmir/dap-travis

**bugreports**

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

Knihovna pro načítání metadat dapů
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

Protože DevAssistent je napsán tak, aby jej bylo možné interpretovat jak Pythonem ve verzi 2, tak Pythonem ve verzi 3, a protože je to považováno za vhodné [@Pilgrim2010], podporuje *daploader* taktéž obě používané verze Pythonu.

Pro parsování souboru `meta.yaml` jsem použil modul PyYAML [@Simonov2014], jinak jsem si vystačil se standardními moduly obsaženými v distribuci Pythonu.

Zvolil jsem metodu TDD a pro testování jsem použil nástroj pytest [@Krekel2013].

> Programování řízené testy (z anglického *Test-driven development* -- TDD) je přístup k vývoji softwaru, který je založen na malých, stále se opakujících krocích, vedoucích ke zefektivnění celého vývoje.
Prvním krokem je definice funkcionality a následné napsání testu, který tuto funkcionalitu ověřuje. Poté přichází na řadu psaní kódu a nakonec úprava tohoto kódu. [@wiki-tdd]

Načtení dapu
------------

*Daploader* poskytuje třídu *Dap*. Její konstruktor načte dap a pokusí se z něj získat obsah souboru `meta.yaml` -- pokud se načtení nepodaří (nejedná se o *tar.gz* archiv nebo v archivu není právě jeden soubor `meta.yaml`), knihovna vyvolá výjimku. V případě správného načtení jsou jednotlivé položky ze souboru `meta.yaml` k dispozici ve formě asociativního pole.

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

Knihovna *daploader* je dostupná v repozitáři PyPI [@PythonSoftwareFoundation2014] a je možné ji nainstalovat například pomocí porgramu `pip` [@PyPA2014] ([v ukázce](#daploader-install)).

```{caption="Instalace knihovny daploader {#daploader-install}"}
pip install daploader
```
