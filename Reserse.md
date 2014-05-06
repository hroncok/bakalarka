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

TODO

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

RubyGems.org
------------

