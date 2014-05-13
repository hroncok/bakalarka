% Rešerše {#reserse}

V této kapitole jsou nastíněna možná řešení požadavků vyjmenovaných [v části](#pozadavky@).

Balík (dap) {#reserse-balik}
===========

S ohledem na požadavky uvedené [v části](#pozadavky-balik@) jsou zde představeny možnosti, které vyvstávají při volbě vhodného formátu pro dap.

Vzhledem k tomu, že dap obsahuje řadu souborů v adresářové struktuře a metadata, nabízejí se dvě možnosti:

 * vlastní binární formát vyvinutý pouze pro potřeby dapu,
 * využití existujícího formátu pro archivaci souborů a přidání metadat
     * ve formě souboru v daném archivu,
     * nebo ve formě pozměněné hlavičky tohoto archivu.

Vlastní binární formát
----------------------

Vlastní binární formát by dával smysl ve dvou případech:

Pokud by bylo žádoucí formát uzavřít a neprozradit nikomu, jak funguje -- tato situace ale nenastává, jelikož vývoj aplikace DevAssistant a celý ekosystém kolem ní má být zcela otevřený.

Dalším důvodem je možnost navrhnout formát tak, aby byl optimalizovaný právě pro asistenty. Vzhledem k tomu, že asistenty sestávají převážně z textových souborů[^textove] a celková velikost jednoho dapu se v extrahované formě pohybuje řádově v desítkách kilobajtů, postrádá taková optimalizace smysl.

Implementace ryze vlastního formátu by pak přinášela mnoho problémů, například zvýšení rizika chyby či nutnost udržovat zpětnou kompatibilitu. Především by se jednalo o další kus kódu, který je potřeba napsat a udržovat -- vzhledem k nulovým výhodám by se tedy jednalo o zbytečně složité řešení.

**Závěr:** Implementace ryze vlastního formátu je tedy pro účely dapu nevhodná.

[^textove]: YAML definice asistentů a různé šablony zdrojových kódů.

Existující formát pro archivaci souborů {#reserse-archiv}
---------------------------------------

Zbývající možností je využití nějakého existujícího formátu určeného pro archivaci souborů. Takových formátů je mnoho a je třeba zvolit takový formát, který bude možné použít na všech platformách podporovaných aplikací. Po konzultaci s vedoucím práce jsme zvolili formát *tar.gz* [@Tar2013][@Gzip2010], který je velmi rozšířený a otevřený.

Použitý archiv musí kromě souborů nést i metadata. Pro účely nezvyšování komplexnosti je vhodnější přidat do archivu soubor tyto metadata obsahující, než modifikovat hlavičku souboru -- dap tak bude možné rozbalit obvyklým způsobem jako obyčejný *tar.gz* archiv bez ztráty těchto informací. Vzhledem k použití formátu YAML pro asistenty[^format-asistentu] je pak žádoucí použít stejný formát.

**Závěr:** Pro účely dapu bude použit archiv *tar.gz* obsahující YAML soubor s metadaty. Konkrétní implementace takového balíku je nastíněna v e-mailu, který tento formát navrhuje [@Kabrda2013], a podrobně popsána [v části](#implementace-dap@).

[^format-asistentu]: Jak je popsáno [v části](#asistenty@).

Repozitář
=========

S ohledem na požadavky uvedené [v části](#pozadavky-repozitar@) jsou zde představeny služby a aplikace, které by teoreticky mohly být využity na sdílení dapů.


GitHub
------

GitHub [@GitHub2014] ([na obrázku](#pic:github)) je poměrně známá a oblíbená služba určená k hostování zdrojových kódů aplikací pomocí verzovacího systému git [@Chacon2009]. Ačkoli jsou jednotlivé asistenty v dapu vlastně zdrojovým kódem a verzování tohoto kódu na GitHubu je pochopitelně možné, nesplňuje GitHub požadavky týkající se formátu dapu -- je sice možné nahrát k repozitáři archivy, není ale možné zajistit jejich kontrolu správnosti. GitHub nadále nepodporuje uživatelské hodnocení ani hlášení škodlivého obsahu.

![Snímek obrazovky ze služby GitHub {#pic:github}](images/github)

Z uživatelského hlediska pak není příliš přívětivé rozlišení, co na GitHubu je dap a co ne -- procházení jednotlivých projektů na GitHubu z aplikace DevAssistant a vyhledávání dapů je tak nemožné, nebo by bylo příliš komplikované. Obsah by také nebyl pod kontrolou vývojářů DevAssistantu a případné odstranění škodlivých dapů by vyžadovalo vyjednávání s provozovateli GitHubu.

**Závěr:** Využití GitHubu nebo jakékoli podobné služby je tedy pro účely repozitáře dapů nevhodné.

PyPI
----

PyPI [@PythonSoftwareFoundation2014] ([na obrázku](#pic:pypi)) je repozitář modulů do programovacího jazyka Python [@Pilgrim2010]. Zdrojový kód aplikace [@PythonSoftwareFoundation2014a] je dostupný pod permisivní licencí BSD a je tedy teoreticky možné PyPI upravit a použít jako repozitář dapů.

![Snímek obrazovky z hlavní instance PyPI {#pic:pypi}](images/pypi)

PyPI nesplňuje některé požadavky definované [v části](#pozadavky-repozitar@). V první řadě je navržen na sdílení modulů do Pythonu a vyžadoval by jisté úpravy, aby do něj bylo možné nahrávat dapy. PyPI nepodporuje uživatelské hodnocení ani hlášení škodlivého obsahu. Klasifikace je možná pouze pomocí kategorií definovaných přímo v nahrávaném balíku, je možné použít pouze předem dané kategorie [@PythonSoftwareFoundation2014b].

Využití PyPI by vyžadovalo nemalou modifikaci jeho zdrojového kódu. To přináší řadu nevýhod, především nutnost prozkoumat cizí zdrojový kód a porozumět mu a následná nutnost synchronizování vlastních změn s aktuální verzí PyPI.

**Závěr:** Využití PyPI je tedy pro účely repozitáře dapů možné, ale nepříliš optimální.

RubyGems.org
------------

RubyGems.org [@Quaranto2014] ([na obrázku](#pic:rubygems)) je repozitář gemů -- modulů do jazyka Ruby. Pro Ruby plní stejnou funkci jako PyPI pro Python. Zdrojový kód aplikace [@Quaranto2014a] je dostupný pod permisivní licencí MIT a je tedy teoreticky možné RubyGems.org upravit a použít jako repozitář dapů, stejně jako tomu je u PyPI.

![Snímek obrazovky z RubyGems.org {#pic:rubygems}](images/rubygems)

RubyGems.org ale také nesplňuje některé požadavky definované [v části](#pozadavky-repozitar@). Trpí stejným neduhem jako PyPI -- je navržen na sdílení modulů do Ruby a vyžadoval by jisté úpravy, aby do něj bylo možné nahrávat dapy. RubyGems.org také nepodporuje uživatelské hodnocení ani hlášení škodlivého obsahu. Další nevýhodou je, že na rozdíl od PyPI nepodporuje žádnou možnost klasifikace.

Využití RubyGems.org by taktéž vyžadovalo nemalou modifikaci jeho zdrojového kódu. To přináší stejné nevýhody jako v případě PyPI.

**Závěr:** Využití RubyGems.org je tedy pro účely repozitáře dapů možné, ale nepříliš optimální, dokonce méně optimální než PyPI.

Další podobné služby
--------------------

V rámci rešerše jsem prozkoumal další podobné služby (například npm [@Npm] nebo CPAN [@CPAN2013]), všechny jsou ale příliš spjaty s konkrétním obsahem, který je na ně nahráván. Proto není jejich použití pro účely repozitáře dapů optimální.

Vlastní řešení
--------------

Z předchozích příkladů přímo vyplývá, že nejlepším řešením je řešení vlastní. To poskytuje tyto výhody:

 * plná kontrola nad obsahem (oproti službám třetích stran)
 * plná kontrola nad funkcionalitou
 * plná kontrola nad architekturou aplikace
 * plná kontrola nad použitými technologiemi

**Závěr:** Pro účely repozitáře dapů je nejlepší implementovat vlastní řešení.
