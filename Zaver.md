Cílem práce bylo sestavit sadu doporučení pro návrh RESTful API. Následně rozšířit stávající verzi KOSapi o nové domény dat, místo XML exportů využít přímý přístup do databáze KOSu, navrhnout nové RESTful API a především vše implementovat. Tento cíl byl úspěšně naplněn.

KOSapi má za sebou bezmála tři roky provozu na dvou fakultách a připravuje se nasazení na třetí. Aktuálně ho využívá 25 fakultních i studentských projektů. Postupně se stalo prakticky nezbytnou součástí školní infrastruktury a umožnilo vznik celé řady projektů, které dříve byly nemyslitelné.

Tato práce posunula KOSapi o velký krok kupředu. Zejména díky přímému napojení na KOS, celkovému zdokonalení RESTového rozhraní a jeho obohacení o nadstandardní podporu vyhledávání. Navrhl jsem a implementoval vlastní řešení pro parametrické vyhledávání nad RESTovými zdroji a integroval ho s \mbox{frameworkem} Hibernate (objektově-relační mapování).


Budoucí vývoj
=============

Aktuálně se pracuje na integraci s fakultním ESB, které bude sloužit jako fasáda nad API všech školních systémů. Pilotně se testuje zabezpečení přes protokol OAuth 2.0, díky čemuž bude možné lépe řídit a kontrolovat přístup. V nejbližší době je v plánu zprovoznění prvních zdrojů umožňující zápis do KOSu, konkrétně pro závěrečné práce.