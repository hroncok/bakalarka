% Teoretická část (TODO název)

V této kapitole osvětlím problematiku své bakalářské práce s důrazem na důvody vedoucí k její potřebě.

DevAssistant
============

DevAssistant je aplikací, která programátorům pomáhá vytvářet nové vývojářské projekty, vydávat kód a dělat další věci, které programátory zdržují od toho nejdůležitějšího, od psaní softwaru. Nezáleží na tom, jestli jste právě objevili svět vývoje softwaru, nebo jestli už programujete dvě dekády, vždy se najde něco, s čím vám DevAssistant ulehčí život [@RedHatInc.2013]. DevAssistant je možné používat z příkazové řádky nebo pomocí GUI, jak je vidět na [obrázku](#par:da-gui).

![Grafické rozhraní aplikace DevAssistant {#par:da-gui}](images/da-gui.pdf)

Jedná se o svobodný software, je vydaný pod licencí GNU GPL verze 2 nebo vyšší [@RedHatInc.2013].

Asistenty
---------

DevAssistant umožňuje spouštění takzvaných asistentů, které lze zařadit do čtyř kategorií:

 * *vytvářecí asistenty* pomáhají uživateli začít nový projekt,
 * *modifikační asistenty* pomáhají uživateli projekt upravit nebo do něj něco přidat,
 * *připravovací asistenty* pomáhají uživateli zapojit se do nějakého projektu,
 * *úkolové asistenty* pomáhají uživateli s věcmi, které se netýkají konkrétního projektu [@Kabrda2013a].

Jednotlivé asistenty jsou představovány YAML soubory, které definují jak metadata, tak kód, který asistent spouští. Asistenty jsou hierarchicky řazeny do jednotlivých kategorií popsaných výše [@Kabrda2013]. Zatímco existuje základní sada asistentů, která je v některých případech distribuována společně s aplikací [@Kabrda2014], existuje také možnost vytvářet a používat své vlastní asistenty [@Kabrda2013].
