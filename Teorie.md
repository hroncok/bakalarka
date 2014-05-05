% Teoretická část (TODO název)

V této kapitole osvětlím problematiku své bakalářské práce s důrazem na důvody vedoucí k její potřebě.

DevAssistant
============

DevAssistant je aplikací, která programátorům pomáhá vytvářet nové vývojářské projekty, vydávat kód a dělat další věci, které programátory zdržují od toho nejdůležitějšího, od psaní softwaru. Nezáleží na tom, jestli jste právě objevili svět vývoje softwaru, nebo jestli už programujete dvě dekády, vždy se najde něco, s čím vám DevAssistant ulehčí život [@RedHatInc.2013]. DevAssistant je možné používat z příkazové řádky nebo pomocí GUI, jak je vidět na [obrázku](#par:da-gui).

![Grafické rozhraní aplikace DevAssistant {#par:da-gui}](images/da-gui)

Jedná se o svobodný software, je vydaný pod licencí GNU GPL verze 2 nebo vyšší [@RedHatInc.2013].

Asistenty
---------

DevAssistant umožňuje spouštění takzvaných asistentů, které lze zařadit do čtyř kategorií:

 * *vytvářecí asistenty* pomáhají uživateli začít nový projekt,
 * *modifikační asistenty* pomáhají uživateli projekt upravit nebo do něj něco přidat,
 * *připravovací asistenty* pomáhají uživateli zapojit se do nějakého projektu,
 * *úkolové asistenty* pomáhají uživateli s věcmi, které se netýkají konkrétního projektu [@Kabrda2013a].

Jednotlivé asistenty jsou představovány YAML soubory, které definují jak metadata, tak kód, který asistent spouští. Asistenty jsou hierarchicky řazeny do jednotlivých kategorií popsaných výše [@Kabrda2013]. Zatímco existuje základní sada asistentů, která je v některých případech distribuována společně s aplikací [@Kabrda2014], existuje také možnost vytvářet a používat své vlastní asistenty [@Kabrda2013].

Příkladem vlastního asistentu může být například vytvářecí asistent, který studentům prvního ročníku Fakulty informačních technologií ČVUT v Praze pomůže s vytvořením úloh z předmětu *Programování a algoritmizace 1*. Takový asistent by zajistil, že studenti mají k dispozici potřebné programy (kompilátor apod.), a pomohl jim zkompilovat úlohy pomocí programu make [@FreeSoftwareFoundation2013]. Přestože by tento asistent byl jistě přínosný pro zmíněné studenty, pro další uživatele by nedávalo smysl, aby takový asistent byl distribuovaný společně s aplikací DevAssistant.

Přestože je technicky možné distribuovat uživatelům asistent ve formě souborů, které je potřeba rozbalit na určité místo, jedná se o poměrně nepraktické řešení. Proto vyvstává potřeba vytvořit jednotný formát distribuovatelných asistentů a místo, kde takové asistenty sdílet [@Kabrda2013b].
