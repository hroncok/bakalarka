% Návrh a realizace nových funkcí

V této kapitole se zaměřím pouze na několik vybraných funkcí a aspektů, které považuji za nejzajímavější. Vzhledem k velikosti projektu by kompletní popis návrhu a realizace celého KOSapi byl příliš rozsáhlý a dalece překročil požadovaný rozsah práce.


RESTful Service Query Language {#par:rsql}
==============================

RSQL je dotazovací jazyk a nástroj pro parametrické vyhledávání v RESTových službách. Je určený pro vyhledávání strukturovaných dat dle jejich atributů, nad konkrétním RESTovým zdrojem. Navrhl jsem ho původně pro KOSapi, ale své uplatnění najde i ve kterékoli jiné službě podobného charakteru. 

Syntaxe je inspirovaná _Feed Item Query Language_ (FIQL) [@atompub-fiql] – IETF _draft_ dotazovacího jazyka pro formát Atom, který je určený k vyhledávání záznamů dle jejich Atom metadat. Syntaxe FIQL je výhodná svým prvoplánovým určením pro zápis v URI, díky čemuž ji není potřeba separátně kódovat. Na druhou stranu je tím poněkud neobvyklá a ne příliš intuitivní. V rámci implementace vlastního parseru [^5] jsem se rozhodl tuto syntaxi využít a zároveň ji rozšířit o alternativní způsob zápisu.

Vlastní výkonná část RSQL, překlad na databázové dotazy, je implementována nad frameworkem Hibernate, který tvoří základ perzistentní vrstvy KOSapi. RSQL se překládá prostřednictvím Hibernate Criteria Query do SQL.

Proč jsem vlastně vyvíjel vlastní řešení a nevyužil nějaké standardizované? Důvod je prostý, žádné takové kupodivu neexistovalo (anebo jsem jej nenašel). Vyjma standardu _Open Data Protocol_ [@odata-v3], který mimo jiné zahrnuje pokročilou podporu pro dotazování. OData je však příliš komplexní a implementace v Javě je v teprve ranném stádiu vývoje (a spíše stagnuje). Jeho využití pro KOSapi jsem proto nakonec zavrhl.

V následujícím textu budu uvažovat použití s formátem Atom/XML, který využívá KOSapi, ovšem samotné RSQL, i jeho implementace, je nezávislé na konkrétní reprezentaci. Záleží pouze na tom, jak si definujeme selektor. Všechny zdroje KOSapi jsou koncipované tak, že Atom elementy využívají pouze pro metadata a vlastní data z KOSu jsou obsažena v _Atom Content_ ve strukturované podobě.


Gramatika a sémantika
---------------------

RSQL výraz se skládá z jednoho či více _kritérií_, které se spojují logickými (Booleovskými) operátory:

* konjunkce: `";"` podle FIQL, nebo alternativní `" and "`;
* disjunkce: `","` podle FIQL, nebo alternativní `" or "`.

Operátor `AND` má standardně přednost, tj. všechny operátory `OR` se vyhodnocují až po něm. Pořadí lze změnit klasicky pomocí uzávorkování výrazů.

```{caption="Gramatika RSQL zapsaná v EBNF notaci" .EBNF}
expression    = [ "(" ],
                ( constraint | expression ),
                [ logical-op, ( constraint | expression ) ],
                [ ")" ];
constraint    = selector, comparison-op, argument;

logical-op    = ";" | " and " | "," | " or ";
comparison-op = "==" | "=" | "!=" | "=lt=" | "<" | "=le=" | "<=" | 
                "=gt=" | ">" | "=ge=" | ">=";

selector      = identifier, { ("/" | "."), identifier };
identifier    = ? ["a"-"z", "A"-"Z", "_", "0"-"9", "-"]+ ?
argument      = arg_ws | arg_sq | arg_dq;
argument-ws   = ? ( ~["(", ")", ";", ",", " "] )+ ?;
argument-sq   = ? "'" ~["'"]+ "'" ?;
argument-dq   = ? "\"" ~["\""]+ "\"" ?;
```

Kritérium se skládá ze selektoru, který identifikuje parametr hledání, operátoru porovnání (viz [tabulka](#tab:operatory)) a argumentu. Selektor odpovídá názvu elementu v Atom Content nebo jeho relativní cestě, pakliže je zanořený. Může také obsahovat „dereferenci“ XLink vazby pomocí tečkové notace.

Argumenty mohou být dvojího typu. Libovolná sekvence znaků uzavřená mezi jednoduché či dvojité uvozovky, nebo sekvence znaků bez mezer, kulatých závorek, čárek a středníků.

| Název				| FIQL	| Alt.	| Platné datové typy						|
|-------------------+-------+-------+-------------------------------------------|
| rovná se			| `==`	| `=`	| text, číslo, datum, výčtový typ, XLink	|
| nerovná se		| `!=`	| `!=`	| text, číslo, datum, výčtový typ, XLink	|
| menší než			| `=lt=`| `<`	| číslo, datum								|
| menší nebo rovno	| `=le=`| `<=`	| číslo, datum								|
| větší než			| `=gt=`| `>`	| číslo, datum								|
| větší nebo rovno	| `=ge=`| `>=`	| číslo, datum								|

Table: Operátory porovnání {#tab:operatory}

Při porovnávání řetězců lze využít „divoké karty“ (wildcard) a hledat pomocí nich i podle části řetězce. Způsob zápisu je stejný jako v SQL `LIKE`, pouze s tím rozdílem, že místo znaku `%` (procento) se zde používá `*` (hvězdička). Například podmínce `name=prog_am*` vyhoví všechny předměty, jejichž název začíná na „prog“, následuje jeden libovolný znak, pak „am“ a cokoli (opět bez ohledu na velikost písmen).

Porovnávání textových řetězců nezohledňuje velikost písmen (je _case insensitive_). Argumentem pro element reprezentující výčtový typ (enum) je jeho kód. Argumentem pro XLink je identifikátor záznamu použitý v URI, což většinou bývá kód, nebo ID.

Implementace v KOSapi pracuje s vícejazyčnými názvy. Pokud je URL parametr `multilang` nastaven na `true`, tak zohledňuje texty v obou jazycích (neplatí pro dereferencované atributy). V opačném případě vyhledává pouze ve zvoleném jazyce (podle hlavičky `Accept-Language`, nebo URL parametru `lang`).


„Dereference“ vazeb (aka JOIN)
------------------------------

V dotazu je možné přistupovat i k atributům _odkazovaných_ zdrojů (na které vede XLink) pomocí tzv. „dereference“. Jinak řečeno umožňuje zápis podmínky s _implicitním_ spojením (SQL `JOIN`) entit, mezi kterými existuje explicitní průchozí vazba (obdobně jako v Hibernate Query Language). Vazbami se prochází pomocí tečkové notace a je možné i zanořování. 

Vezměme si například zdroj `/courses/{code}/students`, který vrací studenty zapsané na daný předmět v aktuálním semestru. Student má vazbu na studijní obor, na který je zapsaný, a ten zase na katedru, pod níž patří. Požadavek `/courses/MI-W20/students` s RSQL dotazem `branch.division.code==18102` vrátí studenty předmětu MI-W20 v aktuálním semestru, kteří jsou zapsáni na oboru zajišťovaném katedrou s kódem 18102 (Katedra softwarového inženýrství). Jelikož zdroj organizačních jednotek (division) je identifikovaný svým kódem, tak lze v tomto případě `code` vynechat a psát jen `branch.division==18102`, ale pro lepší názornost ponechejme úplnou podobu dotazu. Zapsáno v SQL by výsledný dotaz mohl vypadat jako v [ukázce kódu](#fig:rsql-sql).

```{caption="Ukázka reprezentace /courses/MI-W20/students" .XML}
<atom:feed>
	...
	<atom:entry>
		<atom:link rel="self" href="students/flynnsam/"/>
		...
		<atom:content atom:type="xml" xsi:type="student">
			<firstName>Sam</firstName>
			<lastName>Flynn</lastName>
			<branch xlink:href="branches/4254/">
				Web a multimédia (bakalářský)
			</branch>
			...
		</atom:content>
	</atom:entry>
	...
</atom:feed>
```

```{caption="Ukázka reprezentace /branches/4254" .XML}
<atom:entry>
	<atom:title>Web a multimédia (bakalářský)</atom:title>
	<atom:link rel="self" href="branches/4254/"/>
	...
	<atom:content atom:type="xml" xsi:type="branch">
		<department xlink:href="divisions/18102/">
			Katedra softwarového inženýrstvi
		</department>
		...
	</atom:content>
</atom:entry>
```

```{caption="Ukázka reprezentace /divisions/18102" .XML}
<atom:entry>
	<atom:title>Katedra softwarového inženýrstvi</atom:title>
	<atom:link rel="self" href="divisions/18102/" />
	...
	<atom:content atom:type="xml" xsi:type="division">
		<code>18102</code>
		<divisionType>DEPARTMENT</divisionType>
		...
	</atom:content>
</atom:entry>
```

```{label="fig:rsql-sql" caption="Ilustrativní SQL dotaz pro příklad s dereferencí vazby" .SQL}
select s.*
from students s
	join courses_registrations r on s.id = r.student_id
	join courses c on r.course_id = c.id
	join branches b on s.branch_id = b.id     --rsql
	join divisions d on b.division_id = d.id  --rsql
where c.code = 'MI-W20' 
	and d.code = '18102';  --rsql
```

Skládá se vlastně ze dvou částí. První odpovídá předdefinovanému dotazu podzdroje `/courses/{code}/students`, druhá část je generovaná z RSQL dotazu (označena komentářem). Jak vidno, zápis dotazu pomocí RSQL je výrazně jednodušší a efektivně uživatele odstiňuje od implementační komplexnosti schované za ním.


Příklady
--------

* \texttt{/courses?query=\textbf{name=='programování v*'}} – najde předměty, jejichž název začíná na „programování v“
* \texttt{/courses?query\textbf{=credits>5}} – najde předměty za více než 5 kreditů
* \texttt{/courses?query=\textbf{season==WINTER;(name==*ruby*,name=*java*)}} – najde předměty vypsané v zimním sem. a mající v názvu „ruby“ nebo „java“
* \texttt{/students?query=\textbf{supervisor.lastName==Kordík}} – najde studenty jejichž školitel se jmenuje Kordík


Implementace
------------

Implementace RSQL se skládá ze dvou částí. První je knihovna „RSQL-parser“, která provádí lexikální analýzu, parsování a sestavení objektové reprezentace zadaného RSQL výrazu. Druhou část představuje knihovna „RSQL-hibernate“, implementace RSQL pro ORM framework Hibernate. Zajišťuje převod dotazu na _Hibernate Criteria Query_ (objektová reprezentace HQL [^1]), z něhož se následně generuje SQL dotaz do relační databáze.

Využití Criteria Query namísto přímého převodu do SQL přináší dvě zásadní výhody. Jednak značně zjednodušuje implementaci konvertoru a činí ho flexibilnějším. Jednak umožňuje relativně snadno slučovat více dotazů do jednoho (vč. _joinů_) nebo připojovat k výslednému dotazu další podmínky. To znamená, že je možné ke staticky zapsanému dotazu v DAO připojit uživatelem zadaný RSQL dotaz. Této vlastnosti se využívá především u podzdrojů, které jsou v podstatě předdefinovanými dotazy.

Obě knihovny jsem v roce 2011 uvolnil pod licencí MIT a umístil na GitHub (viz [@rsql-parser], [@rsql-hibernate]). V prosinci téhož roku jsem měl o RSQL krátkou přednášku v rámci sdružení CZJUG (Czech Java User Group).


### Parser

Vlastní parser je implementován s pomocí nástroje JavaCC – generátor parseru a lexikální analyzátor pro Javu. Jeho vstup tvoří formální gramatika zapsaná v EBNF notaci a syntaxi založené na Javě, výstupem pak kompletní kód parseru v jazyce Java. Parser dostane na vstup textový řetězec představující RSQL výraz, který zparsuje a sestaví jeho objektovou reprezentaci.

Vzhledem k tomu, že jazyk RSQL je nadmnožinou FIQL, lze tento parser použít rovněž pro parsování FIQL výrazu.


### Knihovna pro Hibernate

Nejzajímavější na implementaci RSQL je jeho převod do Hibernate Criteria Query, který zjednodušeně funguje následujícím způsobem. 

Nejprve se zparsuje daný výraz pomocí knihovny RSQL-parser. Poté se projde výsledný strom výrazu, zpracují se logické operátory, příp. provede překlad selektoru přes _Mapper_ a jednotlivá kritéria (trojice selektor, operátor porovnání a argument) se delegují na příslušné instance _CriterionBuilder_. Ty má konvertor připravené v kolekci, jíž iteruje dokud nenalezne takový, který umí obsloužit danou dvojici selektoru a operátoru.

Třídy implementující rozhraní _CriterionBuilder_ jsou zodpovědné za vytvoření instance Hibernate _Criterion_ pro dané kritérium. Nejdůležitější část spočívá v navázání selektoru (typicky název nebo cesta XML elementu) na konkrétní atribut (_property_) entity a konverzi argumentu na odpovídající typ pomocí _ArgumentParser_. Zde se využívá Hibernate metamodel a reflexe.

Knihovna poskytuje několik základních implementací a je navržená tak, aby bylo možné snadno doplnit vlastní či upravit stávající. Mezi těmi základními nechybí implementace pro obsluhu selektorů mapovaných na asociaci mezi entitami a argument představující ID asociované entity nebo její přirozený klíč (_NaturalID_). Dále obsluha „dereferencí“ vazeb a v případě KOSapi také vícejazyčných názvů.

Konvertor také umožňuje nastavit omezení na počet vygenerovaných SQL spojení (_join_) – pro případ, že si uživatel API vymyslí příliš komplikovaný dotaz, který by neúměrně zatížil databázi.



XPartial {#par:xpartial}
========

V době, kdy jsem podporu „částečných odpovědí“ do KOSapi zaváděl, neexistovala žádná dostupná implementace, kterou bych mohl využít. Navrhl jsem si tedy vlastní, jmenuje se _XPartial_.

XPartial přímo vychází z návrhu _Partial Response_ od Googlu [@gdata-reference], ale implementuje jen jeho podmnožinu. Jako takový je určený pro XML, ovšem samotný jazyk pro zápis filtrovacího výrazu a jeho parser lze bez problémů použít např. pro JSON, jen se některé jeho vlastnosti nevyužijí (konkrétně filtrování podle atributů).


Gramatika a sémantika
---------------------

Cesty všech elementů jsou relativní vůči kořenovému elementu. Názvy elementů a cesty se oddělují čárkami, např. `updated,content/name`. Mohou, ale nemusí, obsahovat prefix jmenného prostoru, např. `atom:entry/atom:updated`.

Cesta k zanořenému elementu se skládá z po sobě jdoucích elementů oddělených lomítkem, např. `entry/content/name`. Zápis více zanořených elementů na stejné úrovni lze zkrátit pomocí podvýběru mezi kulatými závorkami, např. `content(name,code)`. Toto lze libovolně zanořovat a kombinovat, např. `entry(content/name,content(code,range))`.

Výběr pouze těch elementů, které obsahují požadované XML atributy, se zapisuje jako `element[@atribut='hodnota']`, například `name[@lang='cs']`. Mezi hranaté závorky lze zapsat více podmínek oddělených čárkami, například `name[@lang='cs',@type='xml']`.

```{caption="Gramatika XPartial zapsaná v EBNF notaci"}
expression = path,
             { ",", path };
path       = node,
             ( { "/", node } | subselect );
subselect  = "(", expression, ")"
node       = name,
             [ "[", attributes, "]" ];
attributes = attribute,
             { ",", attribute };
attribute  = "@", att-name, "=", '"', att-value, '"';
att-name   = "a"-"z" | "A"-"Z" | "0"-"9" | "-" | "_" | ":";
att-value  = ? ~["\""]+ ?;
```


Implementace
------------

Implementace XPartial se skládá z parseru XPartial výrazu a SAX [^2] filtru. 

Parser jsem opět implementoval s pomocí JavaCC, stejně jako RSQL-parser. Jednalo se o můj první počin s JavaCC a vůbec první návrh gramatiky. Na XPartial jsem si problematiku osvojil a nedlouho poté nabyté zkušenosti zužitkoval při návrhu RSQL.

SAX filtr je vlastní výkonná část, která aplikuje restriktivní projekci nad výstupní reprezentací. V podstatě odřízne jednotlivé větve XML stromu, které nesplňují zadaný XPartial výraz (předaný URL parametrem). Implementačně jednoduché i výkonné řešení, leč má své stinné stránky. 

Filtr se aplikuje až po zpracování celého požadavku, tedy po načtení dat z databáze (či cache) a jejich zpracování. Načtou se tedy i ta data, která se následně zahodí, výkon vlastní služby to nijak nezvýší. Dále je řešení svázané s konkrétní reprezentací dat (XML). Pro jiné reprezentace by bylo nutné implementovat samostatný filtr nebo data transformovat přes XML.

Toto řešení bude naopak výhodné pro integraci do API fasády, kde tak může poskytnout podporu XPartial i službám, které ho přímo nepodporují.


Mapování vícejazyčných textů  {#par:4:multilang}
=============================

KOS eviduje většinu textů ve dvou jazycích: češtině a angličtině. Pro takový údaj jsou pak v tabulce dva sloupce (např. `nazev_cs` a `nazev_an`). Otázka je, jak tyto sloupce přes ORM namapovat na atributy (_property_) entity.

V první verzi byl každý sloupec mapován jako separátní atribut entity, s kódem jazyka jako příponou (např. `nameCs` a `nameEn`). Tento přístup se později ukázal jako nevyhovující. Mezi sémanticky shodnými atributy, lišícími se jen v jazyce, takto neexistovala žádná programová vazba. Nemluvě o komplikaci s přidáváním dalších jazyků, ačkoli tato možnost je v případě KOSu spíše hypotetická.

Zásadní komplikace však nastala při mapování na XML, kde bylo žádoucí jazyk textu deklarovat standardním atributem (viz [ukázka kódu](#fig:multistring-xml)). A dále umožnit vypsání textů pouze v jednom vybraném jazyce, tentokrát už bez atributu (neboť se deklaruje na kořenovém elementu).

Článek na blogu Eyal Lupu [@lupu2007] mě inspiroval k výrazně lepšímu řešení s využitím Hibernate _CompositeUserType_.


## Hibernate UserType

Hibernate umožňuje na SQL (resp. JDBC) typy mapovat i vlastní datové typy. Stačí implementovat rozhraní `UserType`, ve kterém se určí, jak instanci příslušného typu _serializovat_ do JDBC a vice versa. Jednomu atributu entity zpravidla odpovídá právě jeden sloupec v tabulce.

Ovšem pro Hibernate není problém namapovat jeden typ (resp. jeden atribut) i na více sloupců tabulky! Jedná se o kompozitní uživatelský typ, který se vytvoří implementací rozhraní `CompositeUserType`. Pomocí něj pak lze zapsat mapování jako na [ukázce kódu](#fig:multistring-entity). `MultiString` je obyčejná třída (resp. rozhraní v tomto případě), která obsahuje kolekci názvů v různých jazycích a příslušné přístupové metody.

```{label="fig:multistring-entity" caption="Použití MultiString v entitě" .Java}
@Columns(columns = {
    @Column(name = "NAZEV_CS", length=100),
    @Column(name = "NAZEV_AN", length=100)})
@Type(type = MultiStringUserType.class)
private MultiString name;
```

## XML Adaptér

Druhá část problému spočívá v mapování vícejazyčných textů do XML v podobě znázorněné na [ukázce](#fig:multistring-xml), tedy s rozlišením jazyka pomocí atributu.

```{label="fig:multistring-xml" caption="MultiString v XML" .XML}
<name xml:lang="cs">Webové služby a middleware</name>
<name xml:lang="en">Web Services and Middleware</name>
```

Pro mapování mezi objekty a XML používám _EclipseLink MOXy_ [^3], což je rozšířená implementace JAXB [^4]. JAXB umožňuje _adaptovat_ libovolný datový typ (Java třídu) na jiný typ, který dokáže mapovat, a tím (v omezené míře) přizpůsobit jeho konverzi do/z XML; rozšířením třídy `XmlAdapter`.

### Komplikace

Problém je, že v tomto případě vlastně potřebujeme, aby „výstupem“ adaptéru byly dva elementy, na stejné úrovni (tzn. bez obalujícího elementu) a s dynamickým názvem (tj. definovaným v mapování). A to v JAXB (ani MOXy) kvůli jeho omezením nelze. Přišel jsem však na malý _hack_, kterým lze dosáhnout kýženého výsledku – prostřednictvím kolekce.

Nejprve však musím vysvětlit, jak JAXB pracuje s kolekcemi. Máme-li třídu `Unit` obsahující atribut `"List<String> names"` s anotací `@XmlElement`, tak bez dalších úprav bude výstupem XML s kořenovým elementem `Unit`, který bude mít jako potomky elementy `<names>...</names>` odpovídající prvkům seznamu. Místo jednoduchého řetězcového typu může kolekce obsahovat i instance tříd s JAXB mapováním nebo jakýchkoli tříd, pro které napíšeme XML adaptér. Jeho cílovým typem opět může být i třída s JAXB mapováním. K tomu je nutné dodat, že použijeme-li na kolekci XML adaptér (anotace `@XmlJavaTypeAdapter`), tak „vstupem“ adaptéru nebude celá kolekce, nýbrž jednotlivé prvky kolekce!

### Řešení

Již zmíněná třída `MultiString` je ve skutečnosti rozhraní implementované třídou `ArrayMultiString`. Ta zároveň speciálním způsobem implementuje rozhraní `Collection`, což z ní dělá kolekci, se kterou už dokáže JAXB pracovat. Prvkem této kolekce je třída `Entry`, která obsahuje atributy pro řetězcovou hodnotu a kód jazyka.

K tomu jsem poté napsal XML adaptér `MultiStringXmlAdapter`, který ve zjednodušené podobě vidíte na [ukázce kódu](#fig:multistring-adapter) (metoda `unmarshal()` je vynechaná). Zdrojovým typem je _prvek_ třídy `MultiString`, tedy text s definovaným jazykem. Cílovým typem pak třída `AdaptedEntry`, která text mapuje na hodnotu XML elementu a kód jazyka na jeho atribut(viz [předchozí ukázka](#fig:multistring-xml)).

Tento adaptér zároveň řeší možnost vypsání pouze zvolených jazykových mutací, resp. vynechání celých elementů s jiným než zvoleným jazykem. Třída má prostřednictvím instance `RequestParams` přístup k parametrům _aktuálně zpracovávaného_ požadavku. Podle nich poté metoda `marshal()` vrátí instanci `AdaptedEntry` (`Entry` obsahuje požadovaný jazyk), nebo `null` (tj. element se zcela vynechá). V případě, kdy má být výstupem pouze jedna jazyková varianta, navíc vynechá atribut jazyka.

```{label="fig:multistring-adapter" caption="XML adaptér pro vícejazyčné názvy" .Java}
@Configurable
class MultiStringXmlAdapter extends XmlAdapter<AdaptedEntry, Entry> {
    
    @Autowired RequestParams reqParams;
    
    public AdaptedEntry marshal(Entry entry) {
        if (entry.getValue() == null) {
            return null;
        }
        if (reqParams.isMultilang()) {
            return new AdaptedEntry(entry, true);
        }    
        if (reqParams.getLang() == entry.getLang()) {
            return new AdaptedEntry(entry, false);   
        } 
        return null;
    }
    
    @XmlType(name = "textEntry")
    protected static class AdaptedEntry {    
        @XmlAttribute Lang lang;
        @XmlValue String value;

        protected AdaptedEntry(Entry entry, boolean lang) {
            this.lang = lang ? entry.getLang() : null;
            this.value = entry.getValue();
        }
    }
}
```



[^1]: HQL je objektově orientovaný dotazovací jazyk odvozený od SQL. Vychází z něj i jazyk JPQL (JPA Query Language), který vznikl v podstatě standardizací vybrané podmnožiny HQL.

[^2]: SAX (Simple API for XML) je API pro událostmi řízený XML parser se sekvenčním přístupem. Oproti DOM parserům nestaví objektovou reprezentaci zdroje v paměti, tudíž je méně paměťově náročný a zpravidla rychlejší. SAX je specifikovaný v JSR 63.

[^3]: Říkám mu „JAXB na steroidech“, neboť oproti samotnému JAXB, který je pro cokoli komplexnějšího téměř nepoužitelný, umožňuje relativně snadno definovat i složitější mapování. Za hlavní výhodu však považuji možnost definovat OXM mapování v XML souboru namísto anotací, což je pro řadu situací mnohem výhodnější.

[^4]: JAXB (Java Architecture for XML Binding) je API pro mapování mezi objekty a XML. Staví na anotacích a reflexi, umí pracovat s XML schématy. JAXB je specifikované v JSR 22.

[^5]: Nenašel jsem žádnou existující implementaci FIQL pro Javu, proto jsem se rozhodl pro implementaci vlastní.