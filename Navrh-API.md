% Návrh nového API

Oproti první verzi se značně rozšířila problémová doména a přibyly nové požadavky, tudíž bylo potřeba kompletně přepracovat návrh API. Nový návrh vychází z doporučení stanovenými v první kapitole této práce a reflektuje potřeby dosavadních uživatelů (fakultních projektů).


Přehled zdrojů
==============

Tato sekce obsahuje přehled všech RESTových zdrojů; nově navržených i zachovaných z první verze. U každého je uveden popis jeho domény a případná specifika či učiněná návrhová rozhodnutí. Dále identifikátor zdroje a všech jeho podzdrojů, ve formátu URI šablony [@rfc6570].


## Studijní programy  {#par:programy}

Studijní program je ucelená forma vysokoškolského studia, zpravidla se členící na studijní obory. [@wiki-stud-program] V rámci hierarchie entit definujících studijní náplň tvoří nejvyšší jednotku.

#### Seznam zdrojů

* `/programmes`
* `/programmes/{code}`
* `/programmes/{code}/branches`
* `/programmes/{code}/courses`
* `/programmes/{code}/coursesGroups`
* `/programmes/{code}/studyPlans`


## Studijní obory  {#par:obory}

Studijní program může mít jeden či více studijních oborů a jeden obor může náležet více programům (tj. vazba _n:m_). Některé obory mají význam spíše studijní etapy, např. společný první ročník před rozdělením do oborů. Některé fakulty obory nepoužívají vůbec.

#### Seznam zdrojů

* `/branches`
* `/branches/{id}`
* `/branches/{id}/studyPlans`


## Studijní plány  {#par:plany}

Studijní plán je předpis studijních povinností, které student musí splnit, aby úspěšně absolvoval daný druh studia (např. prezenční, magisterský program, základní blok). 

Obsahuje seznam předmětů, z nichž student musí získat minimálně stanovený počet kreditů (absolutně) v předepsané skladbě. Ta je vyjádřena následovně. Předměty plánu jsou rozděleny do několika skupin; z každé skupiny student musí získat minimálně zadaný počet kreditů a musí absolvovat minimálně zadaný počet předmětů. U některých skupin se také uvádí parametr, který říká, kolik kreditů maximálně se z dané skupiny započítá do celkového skóre. [@bk-fit] Plán neříká nic o tom, kdy a v jakém pořadí je třeba předměty vystudovat.

Studijní plány jsou určeny pro konkrétní program, formu studia a příp. obor studia (některé fakulty obory nemají); mezi programy a obory tedy existuje vazba _n:m_! Dále existují tzv. individuální studijní plány, což je plán vytvořený na míru konkr. studentovi, který se pak řídí jinými podmínkami.

#### Seznam zdrojů
\needspace{4\baselineskip}

* `/studyPlans`
* `/studyPlans/{code}`
* `/studyPlans/{code}/coursesGroups`
* `/studyPlans/{code}/pathways`


## Skupiny předmětů  {#par:skuppredmetu}

Skupina předmětů úzce souvisí se studijními plány (viz výše).

#### Seznam zdrojů

* `/coursesGroups`
* `/coursesGroups/{code}`


## Studijní průchody  {#par:pruchody}

Každý studijní plán může mít několik doporučených průchodů, které studentovi radí, kdy si zapsat který předmět. Pokud se student tohoto průchodu bude držet, má jistotu, že splní podmínky studijního plánu.

#### Seznam zdrojů

* `/pathways`
* `/pathways/{id}`


## Jednorázové akce předmětů  {#par:jednrakce}

Jednorázové akce slouží například pro vypisování zápočtových testů, hromadných zápisů apod.

#### Seznam zdrojů

* `/courseEvents`
* `/courseEvents/{id}`


## Předměty  {#par:predmety}

Předmět je studijní povinnost, která je určena kódem, svým obsahem, počtem kreditů, rozsahem a způsobem zakončení. [@kos1998] Rozlišují se zde dvě entity – **předmět** a tzv. **instance předmětu**. První obsahuje všechny „statické“ údaje předmětu jako je název, počet kreditů, anotace, osnovy apod. Tyto údaje by měly být po dobu existence předmětu neměnné. Instance předmětu je pak konkrétní instance vypsaná v semestru (tzv. „semestropředmět“) a obsahuje proměnné údaje jako je kapacita, počet obsazených míst, vyučující apod.

Zkušenosti z předchozí verze ukázaly, že samostatný zdroj instancí je pro většinu případů užití nepraktický – vždy je k instanci potřeba i samotný předmět. Na instanci je tedy lepší pohlížet jako na podtyp předmětu. Z toho důvodu jsem tyto zdroje zkombinoval dohromady, přičemž pro rozlišení jsem využil „semestrový filtr“; URL parametr _sem_.

Pomocí parametru _sem_ je možné vyfiltrovat pouze ty předměty, které jsou/byly vypsané (tzn. existuje jejich instance) v alespoň jednom z daných semestrů (např. `sem=current` pro aktuální semestr). Zároveň budou vypsány i položky instance předmětu pro daný/é semestr(y), pod zanořeným elementem. Výchozí hodnota je `none`, což zde znamená, že budou vypsány pouze „statické“ položky předmětu, nikoli jeho instance v semestru.

V případě podzdrojů je výchozí hodnotou filtru aktuální semestr. Pomocí parametru _sem_ lze opět určit jeden či více semestrů, tzn. instancí předmětů, ke kterým vrátit záznamy. Speciální hodnota `none` zde znamená, že se vrátí záznamy pro všechny semestry.

#### Seznam zdrojů

* `/courses`
* `/courses/{code}`
* `/courses/{code}/events` _…jednorázové akce_
* `/courses/{code}/exams`
* `/courses/{code}/parallels`
* `/courses/{code}/students` _…studenti, kteří mají předmět zapsaný_
* `/courses/{code}/instances` _…samotné instance předmětu, tj. pouze položky specifické pro instance_


## Zkouškové termíny  {#par:zkousky}

Zkouškové termíny zahrnují jak závěrečné zkoušky předmětů, tak (nově) i zápočtové termíny předmětů. Rozlišujícím atributem je zde _termType_.

#### Seznam zdrojů

* `/exams`
* `/exams/{id}`
* `/exams/{id}/attendees` _…studenti přihlášení na termín_


## Rozvrhové paralelky  {#par:paralelky}

Studijní paralelka je množina studentů téhož ročníku, pro něž bývají nekonfliktně rozvrhovány stejné přednášky. **Rozvrhová paralelka** je pak vztah mezi instancí předmětu, množinou studentů, jedním až čtyřmi vyučujícími, _rozvrhovými lístky_ a navazujícími paralelkami jiného typu (hierarchie P-C-L). Jejími určujícími atributy jsou mj. typ paralelky (přednáška, cvičení, laboratoř).

**Rozvrhový lístek** je souvislý úsek hodin jednoho typu výuky z daného předmětu, který má být zařazen do rozvrhu. [@kos1998] Jedná se o vztah mezi paralelkou, termínem (den, čas, délka trvání, sudý/lichý) a místem konání výuky. Jedné rozvrhové paralelce _většinou_ náleží právě jeden rozvrhový lístek, ale neplatí to vždy! Například pokud má předmět dvě cvičení týdně, jedná se zpravidla o tutéž paralelku, ale dva rozvrhové lístky.

Mezi paralelkou a rozvrhovým lístkem je velmi těsný vztah; zpravidla klient potřebuje oba. Navíc ve většině případů náleží jedné paralelce právě jeden lístek. Z toho důvodu jsem oba zdroje sloučil a lístky jsou zanořeným elementem pod paralelkou.

#### Seznam zdrojů

* `/parallels`
* `/parallels/{id}`
* `/parallels/{id}/related` _…navazující paralelky_
* `/parallels/{id}/students`


## Semestry  {#par:semestry}

Semestr (z lat. _semestris_ – šestiměsíční: _sex_, šest, a _mensis_, měsíc) je označení pro pololetí na vysokých školách (zimní semestr, letní semestr) [@wiki-semestr]. Skládá se z výukové části (obvykle 12-13 týdnů) a následujícího zkouškového období. V KOSu má též označení _zápisové období_ a je nejmenší jednotkou, za kterou se sledují studijní výsledky. [@kos1998]

KOS navíc obsahuje fiktivní semestry (tzv. „pro uznané“), které se používají pro zápis předmětu „mimo semestr“, např. při uznávání předmětu z předchozího studia apod. Dle dohody by se pro tento účel měl používat „semestr“ s označením `A000` (min. na FIT a FEL), ale mimo něj je v KOSu ještě dalších 9 používaných (kód začínající na `A00`, nebo `0000`). Vzhledem k tomu, že se _de facto_ nejedná o skutečné semestry, ale o jakousi obezličku, tak je KOSapi standardně nevypisuje.

Každá fakulta si určuje začátek a konec semestru rozdílně, rektorát pouze stanoví rozsah, ve kterém se musí pohybovat. KOS však tuto skutečnost nerespektuje, takže data začátku a konce semestru v tabulce semestrů neodpovídají skutečnosti.

Kód semestru má dle KOS tvar **CYYS**, kde **C** značí století (A, 20. století; B, 21. století), **YY** dvojčíslí roku a **S** semestr (1, zimní; 2, letní). Například zimní semestr roku 2010 se označuje B101.

#### Seznam zdrojů

* `/semesters`
* `/semesters/{code}`
* `/semesters/current` _…aktuální semestr, ve kterém probíhá výuka_
* `/semesters/next` _…příští semestr_
* `/semesters/prev` _…předchozí semestr_
* `/semesters/scheduling` _…semestr, ve kterém probíhají zápisy do rozvrhu_


## Studenti / studia  {#par:studenti}

Student je pro tuto entitu poněkud matoucí pojmenování, neboť ve skutečnosti představuje _studium_ studenta, resp. osoby. Jedna osoba může mít na ČVUT více souběžných studií, dokonce i v rámci jediné fakulty. Takoví studenti existují a ačkoli jde o minoritní případy, je nutné s nimi počítat! Z praktických důvodů však reprezentace studenta/studia obsahuje i položky osoby, takže jsem se nakonec rozhodl zachovat název „student“ (po vzoru KOS).

Jako identifikátor studenta jsem zvolil uživatelské jméno, opět z praktických důvodů. Jenže to jednoznačně identifikuje osobu, nikoli studium. Co v případě, kdy má osoba více souběžných studií? Zavedl jsem proto ještě fiktivní číslo studia, které se připojí jako přípona za uživatelské jméno (např. `jirutjak-1`). Algoritmus zjednodušeně funguje tak, že seřadí studia od nejnovější po nejstarší, přičemž přednost mají aktuálně aktivní studia. Je navržený tak, aby ve valné většině případů dostalo to studium, které nás obvykle zajímá, číslo 0. Přípona `-0` se vynechává, takže potom kód odpovídá jednoduše uživatelskému jménu.

#### Seznam zdrojů

* `/students`
* `/students/{username}(-{suffix})`
* `/students/{username}(-{suffix})/enrolledCourses`
* `/students/{username}(-{suffix})/parallels`
* `/students/{username}(-{suffix})/registeredExams`


## Vyučující  {#par:vyucujici}

Mezi vyučující se počítají i externí školitelé, vedoucí závěrečných prací aj. kteří mnohdy nemají školní _login_. V takovém případě se jako identifikátor použije databázové ID s předponou `id-` (např. `id-123456`).

Vyučující je v podstatě _role_ osoby, ale z praktických důvodů reprezentace vyučujícího obsahuje i všechny položky osoby. Jinak řečeno, vyučující rozšiřuje třídu osoba.

#### Seznam zdrojů

* `/teachers`
* `/teachers/{usernameOrId}`
* `/teachers/{usernameOrId}/courses`
* `/teachers/{usernameOrId}/parallels`


## Lidé  {#par:lide}

Lidé zahrnují studenty a vyučující, tedy akademické osoby. Obsahuje pouze údaje specifické pro osobu, nikoli její roli (student, vyučující), a seznam „rolí“ s odkazem na jeden z předchozích dvou zdrojů. Jedna osoba může mít libovolný počet studentských rolí (tj. studií) a nejvýše jednu učitelskou roli.

V předchozí verzi byly zdroje studentů a vyučujících navrženy jako _podzdroje_ lidí (tj. `/people/{username}/student`) a obsahovaly pouze údaje specifické pro studenta, resp. vyučujícího. Tento přístup však měl dvě nevýhody. Klienti k údajům role prakticky vždy potřebovali i údaje osoby, takže se museli zbytečně dotazovat dvakrát. To by sice bylo řešitelné i s podzdroji, ovšem dále se ukázalo, že tato struktura URI je pro uživatele poněkud neintuitivní a bude tedy lepší oba podzdroje přesunout na základní úroveň.

#### Seznam zdrojů

* `/people`
* `/people/{username}`


## Místnosti  {#par:mistnosti}

Místnosti zahrnují všechny výukové i kancelářské prostory. Eviduje se jejich typ (přednášková, kancelář…) a u výukových i kapacita pro výuku a zkoušení. Identifikátorem místnosti je její krátký kód, např. TH:A-1333, T9:342b apod.

Místnosti se dále dělí do _lokalit_ – prostor, uvnitř kterého se lze z místnosti do místnosti přesunout během přestávky mezi vyučovacími hodinami. Například Dejvice a Karlovo náměstí jsou dvě lokality, protože se mezi nimi nelze přesunout do 15 min. Na přesun mezi budovami v Thákurově ulici a Technické ulici stačí přestávka, takže jsou součástí jedné lokality.

#### Seznam zdrojů

* `/rooms`
* `/rooms/{code}`


## Organizační jednotky  {#par:orgjednotky}

Organizační jednotky, jinak řečeno střediska (v terminologii KOSu se nazývají „nákladová střediska“), tvoří rektorát, fakulty, katedry a tzv. podkatedry. Tyto jsou uspořádány ve stromové struktuře, kde nejníže leží katedry a podkatedry, nad nimi fakulty a nad fakultami rektorát.

#### Seznam zdrojů

* `/divisions`
* `/divisions/{code}`
* `/divisions/{code}/courses` _…předměty zajišťované daným střediskem nebo jeho podstředisky_
* `/divisions/{code}/subdivisions` _…podřízená střediska_
* `/divisions/{code}/teachers` _…vyučující, kteří spadají pod dané středisko nebo jeho podstřediska_



URL parametry
=============

Tato sekce obsahuje přehled všech obecných URL parametrů udávaných za otazníkem. Není-li uvedeno jinak, tak parametr platí pro všechny zdroje.


## detail

Úroveň detailu vypsání zdroje. Zatím se používá pouze u předmětu, kde hodnota 1 zapne výpis tzv. dlouhých textů. Výchozí hodnota je 0.

## fields

Filtrace vypisovaných elementů pomocí _XPartial_. Vztahuje se na všechny zdroje, ale pouze pro formát XML/Atom.

## lang

Jazyk obsahu, přepíše hodnotu zadanou HTTP hlavičkou `Accept-Language`. Platné hodnoty jsou `cs`, nebo `en`.

## limit  {#par:3:limit}

Maximální počet požadovaných záznamů, neboli po kolika záznamech se má stránkovat. Horní limit je nastavený na 1 000. Vztahuje se na všechny zdroje kolekcí.

## locEnums

Tímto parametrem je možné zapnout lokalizaci výčtových typů (enum) podle nastaveného jazyka.

Ve výchozím nastavení (hodnota `false`) API vrací výčtový kód KOSapi, například `PROJECT_TEAM`. Ten je vhodné používat pro strojové zpracování, ale pochopitelně není vhodný pro zobrazení uživateli aplikace. Zároveň je zbytečné, aby si každá aplikace musela udržovat překladovou mapu, pokud tyto údaje pouze zobrazuje. Klient si tedy může zapnout lokalizaci, a tím dostane rovnou řetězec „projekt (týmový)“, nebo „Project (team)“; dle zvoleného jazyka.

## multilang  {#par:3:multilang}

Parametr určující, zda se mají vypsat vícejazyčné názvy ve všech jazycích, nebo jen v zadaném (pomocí HTTP hlavičky `Accept-Language` nebo parametru `lang`). Výsledný efekt můžete vidět na [ukázce kódu](#fig:multilang).

```{label="fig:multilang" caption="Ukázka elementů se zapnutým/vypnutým multilang" .XML}
<!-- multilang=true -->
<name xml:lang="cs">Webové služby a middleware</name>
<name xml:lang="en">Web Services and Middleware</name>

<!-- multilang=false -->
<name>Webové služby a middleware</name>
```

## offset  {#par:3:offset}

Index prvního požadovaného záznamu pro stránkování (číslované od nuly). Vztahuje se na všechny zdroje kolekcí.

## orderBy  {#par:3:orderBy}

Seřadí záznamy v kolekci dle zadaných elementů. Vstupem je pole hodnot oddělených čárkami, hodnotou název elementu (z první úrovně pod `atom:content`), podle kterého se mají záznamy seřadit. Obrácený směr řazení se specifikuje prefixem „-“ (spojovník) před názvem elementu (např. `-name`). Výchozí směr řazení je vzestupný. Vztahuje se na všechny zdroje kolekcí.

## query

Vyhledá záznamy odpovídající zadanému RSQL výrazu (viz [sekce](#par:rsql)). Vztahuje se na všechny zdroje kolekcí.

## sem  {#par:3:sem}

Vyhledá záznamy platné pro dané semestry. V některých zdrojích má širší význam, který je poté explicitně uveden v dokumentaci příslušného zdroje. Argumentem mohou být následující hodnoty, příp. množina hodnot oddělená čárkami (některé zdroje omezují jejich počet).

* KOSí kód semestru ve tvaru **CYYS** (viz [sekce](#par:semestry)).
* Alternativní kód semestru ve tvaru **YYYYS**;
	* **YYYY** je rok
	* **S** je období roku; W pro zimní, nebo S pro letní.
* Relativní semestr:
	* **curr** / **current** – aktuální semestr,
	* **next** – příští semestr,
	* **prev** — předchozí semestr,
	* **sched** / **scheduling** – semestr, ve kterém probíhají zápisy do rozvrhu.
* Speciální:
	* **none** – vypnutí filtru.

 Vztahuje se na všechny zdroje, které mají vazbu ke konkrétnímu semestru.

**Příklad:** `sem=B112,B122,current,2042W`


Rozdíly oproti první verzi
==========================

Oproti první verzi popsané v mé bakalářské práci [@jirutka2010] se KOSapi změnilo doslova k nepoznání; celou implementaci i RESTové rozhraní jsem kompletně přepsal. V následujících odstavcích naleznete souhrn nejvýraznějších změn.


## Od exportů k SQL pohledům

Nejzásadnější změna spočívá ve změně datového zdroje. První verze KOSapi získávala data z XML exportu rozvrhových dat KOS (tzv. _rz.xml_), který jednou denně načítala do vlastní relační databáze. Tehdy to představovalo jediné dostupné řešení, neboť SQL přístup do databáze KOS nám byl zcela zapovězen.

Export obsahoval data pouze pro jeden semestr a KOSapi nedělalo přírůstkové aktualizace, tudíž záznamy z minulých semestrů nebyly dostupné. Samotný rozsah dat byl velmi omezený a kvůli špatně navržené struktuře některé důležité vazby chyběly. Byl omezen pouze na data jedné fakulty a nerespektoval tzv. horizontální prostupnost studiem [^2]. To znamená, že v něm chyběli např. studenti z „cizích“ fakult ČVUT, kteří ale měli zapsaný nějaký předmět z naší fakulty. Samotné generování exportů na straně KOSu bylo velmi nespolehlivé a prakticky neustále s ním byly problémy.

Nevýhody řešení postaveného na exportu jsou zjevné. Pro mnoho aplikací bylo KOSapi kvůli omezenému rozsahu dat či jejich zpoždění daným aktualizacemi stále nedostatečné.

Nová verze KOSapi již přistupuje k datům přímo přes databázové pohledy v KOS. Jedná se o celkem 45 klasických SQL pohledů a dva materializované. Vyjma několika pohledů týkající se lidí již nejsou omezené co do rozsahu dat. Těch několik, které omezené jsou, důsledně respektují horizontální prostupnost studia. Všechny pohledy jsou ovšem s přístupem pouze pro čtení.

Při přechodu z exportů na SQL pohledy bylo nutné vyřešit řadu problémů a komplikací. V prvé řadě sestavit a odladit samotné pohledy v KOSu, na čemž jsem se spolupodílel. Dále přizpůsobit ORM mapování v KOSapi a ošetřit různé obskurní situace – například _boolean_ hodnoty, které se v KOSu reprezentují asi pěti různými způsoby (!), mnohdy se prolínajícími i v rámci jedné tabulky.

## Reprezentace zdrojů

První verze KOSapi poskytovala reprezentace ve formátu XML a JSON (generovaný z XML). Metadata se omezovala pouze na „odkaz sama na sebe“ a databázové ID záznamu (viz [ukázka](#fig:entry-1)). Chyběly zde navigační odkazy a metadata pro stránkování (viz [ukázka](#fig:feed-1)).

```{label="fig:entry-1" caption="Reprezentace zdroje střediska v KOSapi 1" .XML}
<department xmlns="http://kosapi.feld.cvut.cz/schema/1" 
		uri="http://kosapi.fit.cvut.cz/api/1/departments/18102" 
		id="1004106">
	<code>18104</code>
	<nameCz>katedra softwarového inženýrství</nameCz>
	<nameEn>Department of Software Engineering</nameEn>
	<parent uri="http://kosapi.fit.cvut.cz/api/1/departments/18000/" 
		id="10"/>
</department>
```

```{label="fig:feed-1" caption="Reprezentace zdroje kolekcí v KOSapi 1" .XML}
<departmentConverters>
	<department uri="http://.../api/1/departments/1/" id="1">
		...
	</department>
	<department uri="http://.../api/1/departments/18000/" id="10">
		...
	</department>
	...
</departmentConverters>
```

V nové verzi jsem využil _Atom Syndication Format_ [@rfc4287], což je standardizovaný formát založený na XML, který definuje sadu elementů pro popis webových zdrojů (zjednodušeně řečeno). Přestože původně byl navržen jako náhrada za RSS, ujal se i coby formát pro RESTful API založená na XML.

KOSapi využívá Atom elementy pro zápis _metadat_ zdroje (viz [ukázka kódu](#fig:entry-3)). Každá reprezentace tak obsahuje své ID (ve formátu URN), datum poslední změny záznamu, autora záznamu, titulek (v požadovaném jazyce), odkaz „sama na sebe“ a výchozí URI služby. Kolekce navíc obsahuje navigační odkazy ve formátu _Atom Link_ pro přechod na další, resp. předchozí stránku a parametry stránkování ve formátu _OpenSearch_ [@opensearch]\ (viz [ukázka kódu](#fig:feed-3)).

Nová verze také více využívá XML atributy, zejména pro definování jazyka textu u vícejazyčných elementů.


```{label="fig:entry-3" caption="Reprezentace zdroje střediska v KOSapi 3" .XML}
<atom:entry xmlns="http://kosapi.feld.cvut.cz/schema/3" 
		xmlns:atom="http://www.w3.org/2005/Atom" 
		xmlns:xlink="http://www.w3.org/1999/xlink" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xml:base="https://kosapi.fit.cvut.cz/api/v3/" xml:lang="cs">

	<atom:title>katedra softwarového inženýrství</atom:title>
	<atom:id>urn:cvut:kos:division:1004106</atom:id>
	<atom:updated>2012-10-24T12:07:07.0</atom:updated>
	<atom:author>
		<atom:name>halaska</atom:name>
	</atom:author>
	<atom:link rel="self" href="divisions/18102/"/>

	<atom:content atom:type="xml" xsi:type="division">
		<abbrev xml:lang="cs">KSI</abbrev>
		<abbrev xml:lang="en">DSI</abbrev>
		<code>18102</code>
		<divisionType>DEPARTMENT</divisionType>
		<name xml:lang="cs">katedra softwarového inženýrství</name>
		<name xml:lang="en">Department of Software Engineering</name>
		<parent xlink:href="divisions/18000/">
			Fakulta informačních technologií
		</parent>
	</atom:content>
</atom:entry>
```

```{label="fig:feed-3" caption="Reprezentace zdroj kolekcí v KOSapi 3" .XML}
<atom:feed xmlns="..."
		xml:base="https://kosapi.fit.cvut.cz/api/3/" xml:lang="cs">
	<atom:id>urn:cvut:kos:division</atom:id>
	<atom:updated>2013-05-09T00:42:34.125</atom:updated>
	<atom:link rel="next" href="divisions?offset=1&amp;limit=2"/>
	<atom:entry>...</atom:entry>
	<atom:entry>...</atom:entry>
	...
	<osearch:startIndex>0</osearch:startIndex>
	<osearch:itemsPerPage>2</osearch:itemsPerPage>
</atom:feed>
```

## Nové vlastnosti a funkce

V nové verzi přibyla pokročilá podpora parametrického vyhledávání RSQL a „částečných odpovědí“ (filtrování elementů) XPartial. Jejich podrobný popis naleznete v následující kapitole.

Podpora vícejazyčných textů doznala výrazného zdokonalení; jak na úrovni RESTful API, tak i implementace. Klient si může zvolit, zda si přeje reprezentaci se všemi jazykovými mutacemi, nebo pouze ve zvoleném jazyce [^1]. Navíc je možné volitelně zapnout lokalizaci výčtových typů. V následující kapitole nastíním implementační řešení.

Parametry pro stránkování byly přejmenovány v souladu s novou konvencí na `limit` a `offset`.

Počet zdrojů se rozrostl z původních 13 na 38, počet základních entit (mapovaných na reprezentaci) z původních 6 na 16. Časově proměnlivé zdroje umožňují snadno filtrovat záznamy pro zvolený/é semestr(y).


## Nepodporované funkce

Oproti první verzi jsem odebral export kalendářních rozvrhů ve formátu iCalendar, neboť ten bude součástí samostatné služby pro podporu organizace času na fakultě, na které paralelně pracuje kolega Tibor Szolár.

Společně se změnami RESTové vrstvy zanikla i podpora pro zanořování výpisu (parametr _level_). Původní implementace byla nevhodně navržená a jelikož tato funkce nebyla moc využívaná, tak jsem ji v nové verzi neimplementoval.

Dále dočasně zanikla podpora formátu JSON (souvisí s přechodem na Atom), jeho doplnění je plánované v další verzi.


[^1]: Týká se pouze textů, které KOS eviduje ve více jazycích.
[^2]: Zlepšení horizontální prostupnosti studia je jedním z cílů Dlouhodobého záměru ČVUT na období 2011-2015.
