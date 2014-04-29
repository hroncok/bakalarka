% Požadavky

Jak již bylo v úvodní kapitole popsáno, cílem této práce je přepracování a rozšíření stávající verze KOSapi. Kladené požadavky tedy částečně vychází ze specifikace pro první verzi [@jirutka2010].


Funkční požadavky
=================

Funkční požadavky specifikují požadovanou službu systému, tedy „_co_ bude systém nabízet“.

1. Bude poskytovat data z KOSu prostřednictvím RESTful API.
1. Bude poskytovat RESTové zdroje pro:
	a. studijní programy,
	a. studijní obory,
	a. studijní plány,
	a. studijní průchody,
	a. skupiny předmětů,
	a. jednorázové akce předmětů,
	a. předměty,
	a. zkouškové termíny,
	a. rozvrhové paralelky,
	a. rozvrhové lístky,
	a. semestry,
	a. studenty,
	a. vyučující,
	a. místnosti,
	a. organizační jednotky.
1. Bude umožňovat filtrování časově závislých záznamů s vazbou na semestr;
	a. podle kódu semestru,
	a. podle relativní jednotky: aktuální/příští/předchozí semestr.
1. Bude umožňovat parametrické vyhledávání nad všemi zdroji kolekcí;
	a. podle položek (elementů) reprezentace,
	a. podle položek odkazovaných zdrojů (implicitní „join“),
	a. s možností spojování kritérií logickými operátory AND a OR,
	a. pomocí jednoduché syntaxe umožňující zápis do URL parametru.
1. Bude podporovat „částečné odpovědi“ (partial response);
	a. s filtrováním elementů podle jejich cesty nebo hodnoty atributu,
	a. pomocí jednoduché syntaxe umožňující zápis do URL parametru.
1. Bude podporovat stránkování kolekcí;
	a. s možností zadání rozsahu přes parametry v URL.
1. Bude podporovat řazení záznamů v kolekcích;
	a. dle jednoduchých položek (nezanořených elementů) reprezentace,
	a. včetně řazení dle více položek zároveň,
	a. v sestupném i vzestupném směru řazení,
	a. s možností zadání přes parametr v URL.
1. Bude poskytovat texty ve více jazycích (dle možností KOS);
	a. s výpisem všech jazykových mutací ve výstupní reprezentaci (vyjma výčtových typů),
	a. s možností výpisu pouze zvolené jazykové mutace,
	a. včetně možnosti lokalizace výčtových typů.

\pagebreak

Nefunkční požadavky
===================

Nefunkční požadavky definují vlastnosti a omezení kladená na systém.

1. Bude vycházet z předchozí verze KOSapi.
1. Bude mít API navržené v souladu s uznávanými konvencemi a standardy pro návrh RESTful API.
1. Bude využívat výhradně volně dostupné knihovny a komponenty s veřejně dostupným zdrojovým kódem (výjimkou je JDBC ovladač pro databázi Oracle).
1. Bude implementován na platformě Java EE verze 6 nebo vyšší.
1. Bude fungovat v běhovém prostředí:
	a. Apache Tomcat 7 (servlet kontejner),
	b. OpenJDK 7 (JVM),
	c. GNU/Linux (operační systém).
