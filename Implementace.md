% Implementace

V této kapitole podrobně popíšu implementaci své bakalářské práce.

Dap
===

Jak bylo popsáno [v částech](#par:pozadavky-balik) [a](#par:reserse-balik), dap je *tar.gz* archiv obsahující soubory a metadata jednoho nebo více asistentů. V této části práce nejprve podrobně popíšu specifikaci formátu dap a dále implementaci knihovny, která s dapy umí pracovat.

Specifikace dapu
----------------

Jeden dap je *tar.gz* archiv [@FreeSoftwareFoundation2013a][@FreeSoftwareFoundation2010] pojmenovaný `<název>-<verze>.dap`, konkrétně pak například `python-0.8.0.dap`. Název je zde uveden i s příponou -- typická přípona *tar.gz* archivu `.tar.gz` či `.tgz` je nahrazena příponou `.dap`.

Nahrazení typické přípony je provedeno proto, aby byl dap uživateli jasně identifikovatelný a aby nedocházelo k omylům při pokusu nainstalovat místo dapu běžný *tar.gz* archiv.

### Adresářová struktura uvnitř archivu

Dap má uvnitř archivu striktně danou adresářovou strukturu, která odpovídá adresářové struktuře, kterou očekává DevAssistant, doplněnou o další soubory a adresáře potřebné pouze pro dap:

\dirtree{%
	.1 <název>-<verze>/\DTcomment{hlavní adresář}.
		.2 assistants/\DTcomment{adresář s asistenty}.
			.3 crt|mod|prep|task/\DTcomment{adresáře s asistenty daného typu}.
			.3 <název>.yaml\DTcomment{asistent první úrovně}.
			.3 <název>/\DTcomment{adresář s asistenty druhé úrovně}.
				.4 *.yaml/\DTcomment{asistenty druhé úrovně}.
				.4 */\DTcomment{adresáře s asistenty další úrovně (dále obdobně)}.
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

Asistenty a snipety mají hierarchickou strukturu. Platí, že asistent nejvyšší úrovně musí mít vždy stejný název jako dap, ve kterém je obsažen. Asistenty či spinety dalších úrovní se mohou jmenovat libovolně[^libovolne]. Pokud je v dapu asistent nižší úrovně, vždy v něm musí být i asistent úrovně vyšší. Například pro asistent `crt/python/flask.yaml` musí existovat asistent `crt/python.yaml` -- ten ale může obsahovat jen metadata a nemusí sám o sobě nic vykovávat.

Ikony (`icons`) a soubory (`files`) náleží jednotlivým asistentům a je tedy nutné je patřičně zařadit. Například asistentu `crt/python/flask.yaml` náleží ikona `crt/python/flask.svg` či `crt/python/flask.png` ze složky `icons` a žádná jiná.

Adresáře, které nejsou využité (jsou prázdné) by dap neměl obsahovat. Veškerý obsah hlavního adresáře, kromě souboru `meta.yaml` je volitelný. Teoreticky tak může existovat dap obsahující pouze metadata, prakticky však takový dap nedává příliš smysl. Jakýkoliv obsah mimo tuto danou strukturu je nepřípustný.

Adresář `doc` byl přidán pro účely dapu, aby bylo možné společně s asistenty distribuovat i dokumentaci. Například povinně uváděný text licence, za jejíchž podmínek je obsah dapu distribuován.

Adresářová struktura reálného dapu [@Kabrda2014] může vypadat například takto:

\dirtree{%
	.1 python-0.8.0/.
		.2 assistants/.
			.3 crt/.
			.3 python.yaml.
			.3 python/.
				.4 django.yaml.
				.4 flask.yaml.
				.4 gtk3.yaml.
				.4 lib.yaml.
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

[^libovolne]: V rámci pravidel souborového systému.

### Soubor meta.yaml

Soubor `meta.yaml` obsahuje metadata dapu specifikovaná [v části](#par:pozadavky-balik). Z důvodů popsaných [v části](#par:reserse-metadata) se jedná o YAML soubor. Soubor obsahuje tyto direktivy:

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

**license**

> Licence obsahu dapu, povinný údaj. Používají se specifikátory licencí z RPM balíčků distribuce Fedora [@Callaway2014a][@Callaway2014b]. Je možné použít pouze ve Fedoře povolené licence [@Callaway2014a][@Callaway2014b], které zaručují svobodné šíření obsahu. Tagy lze kombinovat pomocí slov `and` a `or` -- k tomuto účelu je možné použít i závorky a vyhodnocení probíhá podobně jako v jiných logických výrazech. Slovo `and` se používá v případě, že část obsahu je šířena pod jednou a část pod druhou licencí, slovo `or` se používá pokud je možné licenci si vybrat [@Callaway2013].
> 
> V případě zvýšené poptávky po možnosti uvedení nesvobodné licence [@Callaway2014], je možné později povolit v metadatech i tuto variantu. Pro účely repozitáře dapů ale bude nadále možné nahrávat jen svobodný obsah.
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
