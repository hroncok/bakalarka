% Rešerše

V této kapitole nastíním možná řešení požadavků vyjmenovaných [v části](#par:pozadavky).

Balík (dap)
===========

S ohledem na požadavky uvedené [v části](#par:pozadavky-balik) se pokusím představit možnosti, které vyvstávají při volbě vhodného formátu pro dap.
Vzhledem k tomu, že dap obsahuje řadu souborů v adresářové struktuře a metadata, nabízející se dvě možnosti:

 * vlastní binární formát vyvinutý pouze pro potřeby dapu,
 * využití existujícího formátu pro archivaci souborů a přidání metadat
     * ve formě souboru v daném archivu,
     * nebo ve formě pozměněné hlavičky tohoto archivu.

Vlastní binární formát
----------------------

Vlastní binární formát by dával smysl ve dvou případech:

Pokud by bylo žádoucí formát uzavřít a neprozradit nikomu, jak funguje -- tato situace ale nenastává, jelikož vývoj aplikace DevAssistant a celý ekosystém kolem ní probíhá zcela otevřeně.

Dalším důvodem je možnost navrhnout formát tak, aby byl optimalizovaný právě pro asistenty. Vzhledem k tomu, že asistenty sestávají převážně s textových souborů[^textove] a celková velikost jednoho dapu se v extrahované formě pohybuje řádově v desítkách kilobajtů, postrádá taková optimalizace smysl.

Implementace ryze vlastního formátu by pak přinášela mnoho problémů, například zvýšení rizika chyby či nutnost udržovat zpětnou kompatibilitu. Především by se jednalo o další kus kódu, který je potřeba napsat a udržovat -- vzhledem k nulovým výhodám by se tedy jednalo o zbytečně složité řešení.

**Závěr:** Implementace ryze vlastního formátu je tedy pro účely dapu nevhodná.

[^textove]: YAML definice asistentů a různé šablony zdrojových kódů

Existující formát pro archivaci souborů
---------------------------------------

Zbývající možností je využití nějakého existujícího formátu určeného pro archivaci souborů. Takových formátů je mnoho a je třeba zvolit takový formát, který bude možné použít na všech platformách, podporovaných aplikací. Po konzultaci s vedoucím práce jsme zvolili formát *tar.gz* [@FreeSoftwareFoundation2013a][@FreeSoftwareFoundation2010], který je velmi rozšířený a otevřený.

### Metadata

Použitý archiv musí kromě souborů nést i metadata. Pro účely nezvyšování komplexnosti je vhodnější přidat do archivu soubor tyto metadata obsahující, než modifikovat hlavičku souboru -- dap tak bude možné rozbalit obvyklým způsobem jako obyčejný *tar.gz* archiv bez ztráty těchto informací. Vzhledem k použití formátu YAML pro asistenty[^format-asistentu] je pak žádoucí použít stejný formát.

**Závěr:** Pro účely dapu bude použit archiv *tar.gz* obsahující YAML soubor s metadaty. Konkrétní implementace takového balíku je nastíněna v e-mailu, který tento formát navrhuje [@Kabrda2013b], a podrobně popsána v kapitole (TODO).

[^format-asistentu]: Jak je popsáno [v kapitole](#par:asistenty).

Repozitář
=========

S ohledem na požadavky uvedené [v části](#par:pozadavky-repozitar) se pokusím představit služby a aplikace, které by teoreticky mohly být využity na sdílení dapů.


GitHub
------

GitHub [@GiHub2014] ([na obrázku](#par:github)) je poměrně známá a oblíbená služba určená k hostování zdrojových kódů aplikací pomocí verzovacího systému git [@Chacon2009]. Ačkoli jsou jednotlivé asistenty v dapu vlastně zdrojovým kódem a verzování tohoto kódu na GitHubu je pochopitelně možné, nesplňuje GitHub požadavky týkající se formátu dapu -- je sice možné nahrát k repozitáři archivy, není ale možné zajistit jejich kontrolu na správnost.

![Screenshot ze služby GitHub {#par:github}](images/github)

Z uživatelského hlediska pak není příliš přívětivé rozlišení co na GitHubu je dap a co ne - procházení jednotlivých projektů na GitHubu z aplikace DevAssistant a vyhledávání dapů je tak nemožné, nebo by bylo příliš komplikované. Obsah by také nebyl pod kontrolou vývojářů DevAssistantu a případné odstranění škodlivých dapů by vyžadovalo vyjednávání s provozovateli GitHubu.

**Závěr:** Využití GitHubu nebo jakékoli podobné služby je tedy pro účely repozitáře dapů nevhodné.

PyPI
----

PyPI [@PythonSoftwareFoundation2014] ([na obrázku](#par:pypi)) je repozitář modulů do programovacího jazyka Python. Zdrojový kód aplikace [@PythonSoftwareFoundation2014a] je dostupný pod permisivní licencí BSD a je tedy teoreticky možné PyPI upravit a použít jako repozitář dapů.

![Screenshot z hlavní instance PyPI {#par:pypi}](images/pypi)

PyPI nesplňuje některé požadavky definované [v části](#par:pozadavky-repozitar). V první řadě je navržen na sdílení modulů do Pythonu a vyžadoval by jisté úpravy, aby do něj bylo možné nahrávat dapy. PyPI nepodporuje uživatelské hodnocení. Klasifikace je možná pouze pomocí kategorií definovaných přímo v nahrávaném balíku, je možné použít pouze předem dané kategorie [@PythonSoftwareFoundation2014b].

Využití PyPI by vyžadovalo nemalou modifikaci jeho zdrojového kódu. To přináší řadu nevýhod, především nutnost prozkoumat cizí zdrojový kód a porozumět mu a následná nutnost synchronizování vlastních změn s aktuální verzí PyPI.

**Závěr:** Využití PyPI je tedy pro účely repozitáře dapů možné, ale nepříliš optimální.

RubyGems.org
------------

RubyGems.org [@Quaranto2014] ([na obrázku](#par:rubygems)) je repozitář gemů -- modulů do jazyka Ruby. Zdrojový kód [@Quaranto2014a] aplikace je dostupný pod permisivní licencí MIT a je tedy teoreticky možné RubyGems.org upravit a použít jako repozitář dapů.

![Screenshot z RubyGems.org {#par:rubygems}](images/rubygems)

RubyGems.org nesplňuje některé požadavky definované [v části](#par:pozadavky-repozitar). V první řadě je navržen na sdílení modulů do Ruby a vyžadoval by jisté úpravy, aby do něj bylo možné nahrávat dapy. RubyGems.org nepodporuje uživatelské hodnocení ani klasifikaci.

Využití RubyGems.org by vyžadovalo nemalou modifikaci jeho zdrojového kódu. To přináší řadu nevýhod, především nutnost prozkoumat cizí zdrojový kód a porozumět mu a následná nutnost synchronizování vlastních změn s aktuální verzí RubyGems.org.

**Závěr:** Využití RubyGems.org je tedy pro účely repozitáře dapů možné, ale nepříliš optimální, dokonce méně optimální, než PyPI.

Vlastní řešení
--------------

TODO
