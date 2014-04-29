% Doporučení pro návrh REST API

REST je _architektonický styl_, který přímo vychází z původní představy webu Tima Berners-Lee. Poprvé ho popsal Roy Thomas Fielding, spoluautor protokolu HTTP, ve své disertační práci v roce 2000 [@fielding2000]. _RESTové_ webové služby však přišly až o několik let později, jako reakce na těžkopádný SOAP [^1]. Základní myšlenka spočívala ve využití stávajících technologií a principů webu pro vybudování robustní, škálovatelné, distribuované a přitom snadno použitelné aplikační platformy.

REST _není_ striktní standard, jako takový specifikuje pouze základní principy, na kterých se pak zrodila myšlenka RESTových webových služeb (RESTful API). Neexistuje však žádný standard, který by definoval, jak přesně mají RESTful API vypadat a co musí splňovat. Staví na existujících standardech jako HTTP, URI, Internet Media Type (nástupce MIME) a další, ale stále tu existuje velká volnost v tom, jak takové API navrhnout.

Můžete také narazit na celou řadu API, která o sobě tvrdí, že jsou RESTful, ale přitom porušují i ty základní principy. REST je trochu zrádný v tom, že na první pohled vypadá velmi jednoduše a povědomě, neboť vychází z _World Wide Webu_. Mnoho vývojářů tak nabude dojmu, že už ho znají a není potřeba se jím blíže zabývat a studovat. V praxi se ale ukazuje, že vlastní návrh RESTového API nemusí být vůbec jednoduchý; ne snad z technologického hlediska, nýbrž čistě návrhového – jak strukturovat zdroje, reprezentovat data atd.

V následujících odstavcích se pokusím shrnout sadu konkrétních doporučení pro návrh RESTových služeb – od obecně platných _best-practices_ až po specifika zohledňující prostředí ČVUT. Budu přitom vycházet zejména z publikací _Web API Design_ [@apigee-api-design], _REST API Design Rulebook_ [@masse2011], nespočtu článků a z vlastních zkušeností s KOSapi.


Základní pojmy
==============

V dalším textu budu pracovat s několika abstraktními pojmy, jejichž význam nemusí být zcela jednoznačný. Zvláště pod pojmem „resource“ každý chápe něco trochu jiného a dokonce i Tim Berners-Lee a Roy Fielding ho definují rozdílně [@lee-resource]. Pokusím se zde tedy krátce definovat jejich význam, přičemž budu vycházet ze zmíněné práce R. Fieldinga.


## Zdroj (Resource)

Za „zdroj“ můžeme označit jakoukoli informaci či koncept, který dokážeme pojmenovat a přiřadit mu jednoznačný _identifikátor_. Typickým příkladem je webová stránka, dokument, obrázek, video, ale i „_dnešní_ program kina“, „kurz japonského jenu _za poslední rok_“ atd. Formálně řečeno, zdroj je **časově závislé** mapování na množinu hodnot, kde hodnotou může být _reprezentace zdroje_ a/nebo _identifikátor zdroje_.

Některé zdroje jsou statické, tedy v každý časový okamžik vrací stejnou množinu hodnot, např. „studenti MI-W20 v zimním semestru 2012“. Zdroje ale mohou být i dynamické v tom smyslu, že konkrétní množina mapovaných hodnot se v čase významně mění, např. „studenti MI-W20 v _aktuálním_ semestru“. Co však musí být neměnné, pro zdroj určující, je _sémantika_ tohoto mapování.

## Identifikátor zdroje (Resource identifier)

Každý zdroj musí mít přiřazený jedinečný identifikátor, díky kterému lze mezi zdroji odkazovat a manipulovat s jejich množinami hodnot pomocí generického rozhraní. Pro identifikaci zdrojů používáme URI (Uniform Resource Identifier) definované v RFC 3986 [@rfc3986].

## Reprezentace (Representation)

Reprezentace zachycuje aktuální nebo žádoucí stav zdroje. Jedná se o vlastní data (např. obrázek) společně s metadaty, která tato data popisují (např. Internet Media Type). Může obsahovat i metadata zdroje – informace o zdroji, která nejsou specifická k dané reprezentaci.


URI a jmenné konvence
=====================

Identifikátory zdrojů (URI) tvoří vstupní rozhraní systému, přes které klienti přistupují k jeho službám. Správný návrh hierarchie URI je proto při tvorbě API zdaleka nejdůležitější. Návrh by měl být pro uživatele API intuitivní a ideálně pochopitelný i bez dokumentace. K tomu je nutné, aby následoval určité konvence RESTových služeb.

Nejprve je potřeba si uvědomit rozdíl mezi tzv. _procedurálně_ orientovaným a _datově_ orientovaným přístupem [@snell2004]. První se zaměřuje na akce či operace, které lze nad systémem provést (např. _vytvořit_ nový předmět, _zapsat se_ na zkoušku…) Tento přístup se zpravidla používá u SOAP služeb, vzdáleného volání procedur (RPC), vlastně i klasickém procedurálním programování. Oproti tomu při datově orientovaném přístupu se vše odvíjí od datového modelu – vlastních entit (např. předmět, zápis na zkoušku…) nebo reprezentantů stavu aplikace – se kterými manipulujeme jen pomocí základních CRUD [^2] operací; ve světě REST známé jako **POST, GET, PUT, DELETE**, čtveřice základních HTTP metod.


## Podstatná jména vs. slovesa

Z výše uvedeného vyplývá, že názvy v URI se odvozují od doménových objektů, nikoli operací (metod, funkcí, procedur…) nad daty. Jednoduše řečeno, URI vládnou _podstatná jména_, slovesa přísluší pouze HTTP metodám (až na výjimečné případy).


## Pravidlo dvou URI

Každý zdroj by měl mít právě dvě výchozí URI (base URI) – první pro kolekci, druhý pro konkrétní prvek kolekce. V našem příkladu se zdrojem předmětů se nabízí `/courses` a `/courses/{code}`, kde `{code}` zastupuje identifikátor předmětu, např. `/courses/MI-W20`.

+-----------+-------------------------------+-------------------------------+
| metoda	| `/courses`					| `/courses/MI-W20`				|
+===========+===============================+===============================+
| POST		| vytvoří nový předmět			| vrátí chybu (405)				|
+-----------+-------------------------------+-------------------------------+
| GET		| vrátí všechny předměty		| vrátí předmět MI-W20			|
+-----------+-------------------------------+-------------------------------+
| PUT		| hromadně aktualizuje předměty	| aktualizuje MI-W20, pokud 	|
|			|								| existuje; jinak vrátí chybu	|
+-----------+-------------------------------+-------------------------------+
| DELETE	| odstraní všechny předměty		| odstraní předmět MI-W20		|
+-----------+-------------------------------+-------------------------------+

Table: Mapování CRUD operací na RESTový zdroj


## Singulár vs. plurál

Používat názvy v jednotném, nebo množném čísle? Jedna z často se opakujících otázek ohledně návrhu URI. V praxi lze narazit na oba přístupy, ale všeobecně doporučovaný je následující.

Vrací-li URI _kolekci_ reprezentací nebo identifikátorů, použijte název v _množném čísle_. To se typicky týká všech kořenových zdrojů.

**Příklad:** \texttt{/api/v3/\textbf{courses}/MI-W20/\textbf{parallels}}

Pokud URI identifikuje konkrétní _prvek kolekce_, použijte _jednotné číslo_. Většinou se však bude jednat o nějaký kód entity nebo číselný identifikátor.

**Příklad:** \texttt{/api/v3/semesters/\textbf{current}}

Jednotné číslo použijte taktéž v případě, kdy z povahy datového modelu může existovat pouze jedna instance dané entity (singleton), takže koncept kolekce pro takový zdroj nedává smysl.

**Příklad:** \texttt{/api/v1/\textbf{configuration}}


## Výjimky z pravidla

Co s akcemi, které ze své podstaty nesouvisí se zdroji, tedy nelze je interpretovat jako CRUD operaci nad nějakou entitou či stavem? I takové se pochopitelně vyskytují, zpravidla v závislosti na konkrétní problémové doméně. Může se jednat například o nějakou výpočetní funkci, překlad textu z jednoho jazyka do druhého, různé konverze atd.

V takovém případě použijte pro pojmenování sloveso, nikoli podstatné jméno. Takové „zdroje“ však musíte v dokumentaci jasně odlišit, aby bylo zřejmé, že mají jiný význam.

Pokud daná akce nijak nemění stav systému (vyjma protokolování apod.) a její opakované zavolání se stejnými parametry vrátí stejný výsledek, potom použijte metodu GET. V ostatních případech použijte POST. Důvodem jest to, že metoda GET je definovaná jako idempotentní a bezpečná.

**Příklad:** \texttt{/api/v1/\textbf{convert}?from=CZK\&to=JPY\&amount=500}


Stavové kódy
============

Ne vždy jde vše hladce; uživatel zadá adresu neexistujícího zdroje či neplatný parametr, neautentizuje se nebo dojde k vnitřní chybě serveru. Všechny stavy systému, zejména ty chybové, je nutné uživateli API prezentovat standardním způsobem tak, aby na ně dokázal adekvátně reagovat. K tomu slouží primárně _stavové kódy_ HTTP protokolu.


## Přehled HTTP kódů

RFC 2616 [@rfc2616] definuje celkem 41 základních stavových kódů [^3] rozdělených do pěti tříd podle jejich typu. RESTové služby si však obvykle vystačí pouze s úzkou podmnožinou kódů, kolem deseti až patnácti.

\needspace{5\baselineskip}


* **1××** Informační, prozatímní odpověď
* **2××** Požadavek byl úspěšně přijat a zpracován
* **3××** Přesměrování
* **4××** Chyba na straně klienta
* **5××** Chyba na straně serveru

V následujících odstavcích představím vybrané stavové kódy, které by RESTová služba měla podporovat, a při jakých situacích se používají.


### 200 OK

Nejčastější kód, který server vrátí v případě úspěšného zpracování požadavku (typicky GET). Odpověď by měla vždy obsahovat data (reprezentaci zdroje). Pokud chcete pouze oznámit, že požadavek byl úspěšně zpracován, ale neposíláte žádná data, použijte kód 204. Nikdy a v žádném případě nevracejte kód 200 (ani jiný 2xx kód), pokud došlo k chybě!


### 201 Created

Používá se při vytvoření nového zdroje, tedy jako reakce na úspěšně provedený POST požadavek. Zároveň by odpověď měla obsahovat hlavičku „Location“ s odkazem na nově vytvořený zdroj.


### 204 No Content

Obdobně jako kód 200 znační úspěšné provedení požadavku, ale v odpovědi nevrací žádná data. Typicky se vrací jako odpověď na úspěšné smazání záznamu (DELETE), případně jeho aktualizaci (PUT).


### 304 Not Modified

Tento kód souvisí s cachováním obsahu a znamená, že reprezentace zdroje nebyla změněna. Nebyla změněna od kdy či vůči čemu? To klient specifikuje pomocí hlavičky „If-Modified-Since“ (datum) nebo „If-None-Match“ (etag). Pokud server vyhodnotí, že zdroj není v novějším stavu než jaký klient požaduje, vrátí pouze kód 304, bez těla odpovědi. V opačném případě vrátí aktuální verzi reprezentace.


### 400 Bad Request

Třída kódů 4xx se používá pro oznámení chyby při obdržení neplatného požadavku. Kód 400 je obecný; použijte ho v případech, kdy není možné použít jiný kód třídy 4xx.


### 401 Unauthorized

Požadovaný zdroj vyžaduje autorizaci, ale klient neposkytl potřebné přihlašovací údaje.


### 403 Forbidden

Klient nemá oprávnění pro přístup k požadovanému zdroji.


### 404 Not Found

Požadovaný zdroj neexistuje.


### 405 Method Not Allowed

Požadovaná metoda není povolená. Vrací se v případě, kdy klient posílá třeba POST požadavek na zdroj, který nepodporuje vytváření nových záznamů.


### 406 Not Acceptable

Nepodporovaná reprezentace zdroje. Pomocí hlaviček „Accept“ může klient deklarovat, v jakém formátu (Internet Media Type), kódování, jazyce, … si přeje dostat odpověď. Pokud zdroj nepodporuje reprezentaci s požadovanými charakteristikami, odpovězte kódem 406 a s nabídkou podporovaných typů.


### 409 Conflict

Použijte v případě, pokud by splnění požadavku mělo uvést systém do nekonzistentního stavu. Například klient aktualizuje dokument, který byl mezitím změněn (a jste schopni tento rozpor detekovat) nebo chce smazat objekt, na který ještě existují reference.


### 415 Unsupported Method Type

Klient zaslal data ve formátu, který daný zdroj nepodporuje. Formát zasílaných dat klient deklaruje pomocí hlavičky „Content-Type“.


### 500 Internal Server Error

Interní chyba serveru; značí obecnou chybu na straně serveru.


## Chybové zprávy

Dojde-li k chybě (stav 4xx nebo 5xx), měla by služba vždy poskytnout co nejvíce informací o tom, co chybu způsobilo a jak danou situaci řešit. Tělo odpovědi musí obsahovat minimálně stručný popis chyby a ideálně také odkaz na dokumentaci s dalšími relevantními informacemi. Doporučuje se zde také zduplikovat stavový kód HTTP, neboť v některých specifických prostředích k němu vývojář nemusí mít přístup přímo. 

Vždy používejte stejný formát reprezentace jako u běžné odpovědi, tedy respektujte hlavičky „Accept“. V případě, kdy klient požaduje nepodporovanou reprezentaci nebo nedeklaruje svou preferenci, vraťte chybovou odpověď ve výchozí reprezentaci.

```{caption="Doporučená struktura chybové zprávy v XML" .XML}
<exception>
	<status>404</status>
	<message>Stručný, leč výstižný popis chyby.</message>
	<moreInfo>http://dev.example.org/doc/errors/12345</moreInfo>
</exception>
```

```{caption="Doporučená struktura chybové zprávy v JSON" .JSON}
{
	"status" : 404,
	"message" : "Stručný, leč výstižný popis chyby.",
	"more_info" : "http://dev.example.org/doc/errors/12345"
}
```


Volba formátu
=============

Obecně se doporučuje, aby služba podporovala více formátů reprezentací. Klient si tak může vybrat, který je pro něj vhodnější, což deklaruje pomocí HTTP hlavičky „Accept“. V některých situacích je však jednodušší určit požadovaný formát přímo v URI, typicky při laborování ve webovém prohlížeči.

Služba musí respektovat HTTP hlavičku „Accept“ pro volbu požadovaného formátu reprezentace. Měla by také umožnit alternativní způsob volby formátu pomocí přípony v URI; dle zažité konvence používané u souborů (například `/api/v1/courses.xml`). Použije-li klient jak hlavičku „Accept“, tak i příponu v URI a tato volba je konfliktní, upřednostní se přípona.


Stránkování
===========

Stránkování obsahu znamená rozdělení velké množiny elementů (záznamy, odstavce, obrázky a podobně) na menší, na sebe navazující (a zpravidla disjunktní) podmnožiny, tzv. stránky. Používá se v případech, kdy je záznamů příliš mnoho, klient typicky nepotřebuje všechny a vrácení všech by klienta nebo i server moc zatěžovalo.

Implementujte podporu stránkování genericky pro všechny zdroje, které vrací kolekce záznamů. Umožněte klientovi nastavit stránkování pomocí URL parametrů „limit“ (kolik záznamů se má vrátit) a „offset“ (od kterého záznamu). Vždy je nutné validovat požadovaný rozsah, nastavit maximální limit a výchozí hodnoty. Konkrétní čísla záleží na velikosti dat, která služba poskytuje; rozumná výchozí hodnota pro „limit“ je 10.

**Příklad:** \texttt{/api/v3/courses?\textbf{limit}=10\&\textbf{offset}=0}


Řazení
======

Se stránkováním úzce souvisí podpora řazení záznamů v kolekcích. Služba by měla umožňovat řazení podle různých atributů, specifických k poskytovaným datům, a v obou pořadích. Typicky to bývá název, kód, datum modifikace…

Pro řazení použijte URL parametr „orderBy“. Jeho vstupem bude pole hodnot oddělených čárkami a hodnotou název atributu, podle kterého se mají záznamy seřadit. Pro obrácení směru řazení použijte prefix „-“ (spojovník) před název atributu. Výchozí směr řazení by měl být vzestupný.

**Příklad:** \texttt{/api/v3/courses?\textbf{orderBy}=name,-credits}


Verzování API
=============

Předně nutno upozornit, že rozhraní (přesněji kontrakt) služby by se nemělo měnit příliš často. Tedy ne tak, aby změna způsobila nefunkčnost stávajících klientů. Toto je nutné mít vždy na zřeteli a při návrhu API myslet trochu dopředu (ne však příliš).

Pochopitelně ale není možné zachovávat kompatibilitu na věky, což by naopak příliš omezovalo vývoj a API by se brzy stalo nekonzistentní a zmatečné. Proto je dobré rozhraní od začátku verzovat.

Názory na to, kde a jak v RESTful API definovat verzi, nejsou jednotné. Pragmatický a nejčastěji používaný přístup je definovat verzi přímo v URI. Jako důvod se zmiňuje jednoduchost a transparentnost; verze je na první pohled vidět a API lze snadno testovat ve webovém prohlížeči. Tento přístup ovšem ne zcela koresponduje s principy REST, podle kterých by verze měla být uvedena v HTTP hlavičce (v rámci „Content-Type“).

Osobně zastávám ten názor, že oba přístupy jsou validní a vzájemně se nevylučují; záleží na konkrétní situaci. Doporučuji verzi v URI definovat vždy a verzování v HTTP hlavičce zavést až v okamžiku, kdy se ukáže, že verzování pouze v rámci URI nepostačuje.

Jakmile API zveřejníte, vždy zaneste do URI číslo verze. Pro označení verze použijte přirozené číslo (počínaje jedničkou) s prefixem „v“ a umístěte ho v cestě URI nejvíce vlevo.

**Například:** \texttt{https://kosapi.fit.cvut.cz/api\textbf{/v1}/courses}


Částečné odpovědi
=================

Server standardně vrací úplnou reprezentaci požadovaného zdroje, tedy se všemi hodnotami, které poskytuje. Mnohdy tak klient získá více dat, než kolik ve skutečnosti potřebuje a využije, ale musí vynaložit přenosovou kapacitu a výpočetní výkon pro zpracování celé odpovědi (a zrovna tak server). V případě serverových aplikací, které mají k dispozici dostatečný výkon a využívají HTTP cache, to nebývá problém, ale u klientských aplikací, např. v JavaScriptu, běžících ve webovém prohlížeči, to může představovat nezanedbatelnou zátěž.

Tento problém řeší koncept zvaný _partial response_, se kterým poprvé přišel _Google Data Protocol_ [@gdata-reference]. Následně ho ve více či méně kompletní podobě převzaly i další velké služby. Umožňuje klientovi v rámci GET požadavku zadat filtr, kterým specifikuje, jaké datové položky výstupní reprezentace chce zahrnout do odpovědi. Jedná se v podstatě o restriktivní projekci nad datovou reprezentací zdroje.

Pokud reprezentace zdroje obsahuje větší množství datových položek (atributů, elementů…) a dá se předpokládat, že pro některá použití bude větší množství z nich nepotřebných, měl by takový zdroj podporovat „částečné odpovědi“. Stejně tak v případě, kdy reprezentace obsahuje nějaké objemově náročnější položky (dlouhé texty a podobně). Vzhledem ke konzistenci celého API by tato funkcionalita potom měla být generická, tedy dostupná nad všemi zdroji daného API.

V případě, že se ke službě přistupuje prostřednictvím API fasády, je výhodné podporu částečných odpovědí implementovat právě na tomto místě.

Pro nastavení filtru se používá URL parametr „fields“. Doporučuji využít mou syntaxi _XPartial_, která vychází z návrhu _Partial Response_ od Googlu [@gdata-reference], nebo jinou podobnou syntaxi. Podobněji se XPartial věnuji [v sekci](#par:xpartial).

**Příklad:** \texttt{/api/v3/courses?\textbf{fields=entry/content(code,completion,name)}}


Vyhledávání
===========

## Implicitní dotazy

Všechny zdroje s parametrem v URI jsou v podstatě předdefinované vyhledávací dotazy. Například mějme zdroj předmětů `/courses` a `/courses/{code}`, kde parametr `code` představuje kód předmětu. Poté požadavek `GET /courses/MI-W20` nám vrátí _předmět_ s kódem _MI-W20_. Na pozadí dojde k vygenerování SQL dotazu nad tabulkou předmětů, kde kód předmětu je rovný MI-W20. To je poměrně triviální dotaz. Trochu složitější se skrývá například za `/programmes/MI/courses`, který vyhledá všechny _předměty_ patřící pod _studijní program_ s kódem _MI_. Zde se vygeneruje polospojení (_left join_) nad programy, spojovou tabulkou a předměty, kde program má kód rovný MI.

Dále můžeme definovat libovolné množství pojmenovaných parametrů v tzv. _query string_, části URI za otazníkem. Uvedení více parametrů má implicitně význam konjunkce.

Omezení takovýchto dotazů jsou zjevná. Co když potřebujeme například vyhledat všechny předměty, které se vyučují v zimním semestru a zajišťuje je Katedra softwarového inženýrství _nebo_ Katedra počítačových systémů? Tady už potřebujeme nějaký dotazovací jazyk, který nám umožní kombinovat podmínky a definovat mezi nimi logické spojky.


## Parametrické vyhledávání

Komplexní podpora dotazování (vyhledávání) tvoří jednu ze základních funkcionalit databází. Oproti tomu většina běžných RESTových služeb v tomto ohledu nenabízí moc silné prostředky a omezuje se pouze na implicitní dotazy, příp. fulltextové vyhledávání.

Parametrické vyhledávání, obecně řečeno, umožňuje přesněji vymezit prohledávanou oblast pomocí kombinace více kritérií (parametry hledání), která popisují kýžené vlastnosti hledaných objektů. Pojem velmi často skloňovaný například při návrhu e-obchodů, kde zákazníkům velmi pomáhá při orientaci v nepřeberné záplavě různých modelů výrobků. V případě RESTful API jde o vyhledávání podle hodnoty různých položek (elementů, atributů…) v reprezentaci daného zdroje. 

Představuje velmi užitečnou funkcionalitu pro služby nad obsáhlou bází strukturovaných dat (např. informační systémy), kde typicky bývá potřeba v datech vyhledávat podle mnoha různorodých kritérií. Má-li taková služba aplikacím sloužit jako přímý [^4] zdroj dat, tak je komplexnější podpora vyhledávání prakticky nezbytná.

Na druhou stranu, její implementace bývá zpravidla složitá, takže je vždy nutné zvážit, zda má pro danou službu smysl.

V rámci této práce jsem navrhl jazyk pro parametrické vyhledávání v RESTových službách zvaný RSQL a implementoval jeho podporu pro ORM framework Hibernate. Podrobný popis naleznete v kapitole [Realizace](#par:rsql).

**Příklad:** \texttt{/api/v3/courses?query=\textbf{credits>3;(name==*ruby,name==*jav\_)}}



Jaký zvolit formát reprezentace?
================================

Na závěr této kapitoly se ještě zmíním o výběru vhodného formátu pro reprezentaci zdroje.

## XML vs. JSON

V době, kdy se RESTové služby začínaly prosazovat, vévodilo formátům pro výměnu dat XML. Není tedy divu, že se stalo i hlavním formátem pro RESTful API. Situace se začala měnit až s nástupem mobilních a klientských aplikací (zpravidla implementovaných v JavaScriptu), kde rychlost a jednoduchost výměny dat začala získávat přednost před expresivitou a rozšiřitelností používaného formátu. Tehdy se začal pomalu prosazovat formát JSON.

V současné době už lze říci, že na poli veřejných RESTových služeb získal JSON převahu a stal se jejich dominantním formátem. Nástup byl nenápadný, přesto velmi rychlý – před dvěma lety volilo JSON jako výchozí (a jediný) formát přibližně 20 % veřejných API [@duvander2011], v současnosti opouštějí XML i majoritní poskytovatelé, např. YouTube [@duvander2012].

Na první pohled nemusí být výhody formátu JSON oproti XML zřejmé. Kolem XML se během jeho dlouhé existence vytvořil bohatý ekosystém nástrojů jako je XPath, XQuery či XSLT, které podstatným způsobem rozšiřují jeho možnosti. XML dokumenty lze snadno validovat proti formálnímu schématu, kombinovat a rozšiřovat o další typy dat jednotným způsobem přes jmenné prostory, transformovat pomocí XSLT atd. Oproti tomu JSON působí jen jako chudý příbuzný.

JSON má však na své straně jednu zásadní výhodu: jednoduchost. V praxi se ukazuje, že JSON je pro běžnou výměnu dat postačující a ve výsledku výhodnější. Lze ho totiž přímo mapovat na nativní typy většiny programovacích jazyků [^5], takže se s ním pracuje přirozeně; jen seznam a asociativní pole, žádný komplikovaný DOM. 

Jak již bylo zmíněno, JSON nemá tak bohatý ekosystém, ale i to se začíná v poslední době měnit. V dubnu letošního roku byl vydán standard JSON Patch [@rfc6902], který je prvním krokem pro transformaci JSON dokumentů. Aktuálně prochází standardizací JSON Schema [@json-schema-draft], formát pro formální popis JSON dat, který usnadní jejich validaci.

XML stále bude mít své místo zejména pro zcela univerzální výměnu dat a jejich integraci od různých dodavatelů – tedy všude tam, kde expresivita, rozšiřitelnost a ekosystém XML je výhodou. Pro aplikace s jasně vymezenou problémovou doménou a specifickými klienty však představuje JSON zpravidla lepší volbu.

## Další formáty

Vedle toho lze uvažovat o dalších formátech pro serializaci. Jsou zde například binární formáty _MessagePack_ a _Protocol Buffers_, které nabízí vyšší výkon a menší objem přenesených dat. Ty však nelze zkoumat a ladit jednoduchými prostředky jako textové formáty. Mohou ale sloužit jako alternativní serializace vedle JSONu pro klienty, kteří využijí jejich výhod.



[^1]: Původně šlo o akronym, který znamenal _Simple Object Access Protocol_. Tento význam byl od verze 1.2 konsorciem W3C zrušen, dost možná i proto, že SOAP se stal čímkoli, jen ne jednoduchým.

[^2]: CRUD je zkratka pro _create, read, update, delete_ – čtyři základní metody pro práci s daty. V SQL jim odpovídají příkazy _insert, select, update, delete_.

[^3]: Kromě této základní množiny kódů existuje ještě celá řada dalších, např. pro WebDAV nebo slavný _Hyper Text Coffee Pot Control Protocol_ (RFC 2434). Oficiální registr HTTP kódů spravuje organizace IANA; http://www.iana.org/assignments/http-status-codes/http-status-codes.xml.

[^4]: To znamená, že aplikace si nebudou uchovávat lokální kopii celé ani části databáze služby (cache se tím nevylučuje), ale budou je získávat přímo _on-demand_.

[^5]: JSON koneckonců vznikl ze syntaxe pro objekty v JavaScriptu.