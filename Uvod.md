Tato práce sleduje vývoj projektu KOSapi – _middleware_ poskytující RESTful API nad databází systému KOS, komponenty informačního systému ČVUT v Praze (dále jen ČVUT). Jeho vývoj započal před třemi lety mou bakalářskou prací „KOS API jako webová služba“ [@jirutka2010] pod vedením Ing. Martina Klímy z Fakulty elektrotechnické ČVUT (dále jen FEL).


Co je to KOS?
-------------

Komponenta Studium, známá pod zkratkou KOS, je systém pro podporu studijních agend na vysoké škole. Využívají ho všechny fakulty ČVUT a také AMU. Jedná se o již zastaralý systém postavený na databázovém stroji Oracle, jehož počátek se datuje k roku 1992. Původně ho vyvinula společnost _Tril, spol. s r. o._ v úzké spolupráci s FEL, v současné době podléhá správě Výpočetního a informačního centra ČVUT v Praze (zkráceně VIC). Více o historii KOSu se můžete dočíst v úvodu mé bakalářské práce.


Historie projektu
-----------------

V následujících odstavcích se pokusím zachytit tříletou historii projektu a zmínit nejdůležitější historické milníky.


### Motivace

Jaká byla a je motivace ke vzniku KOSapi? Na FIT a FEL, ale i dalších fakultách, se provozuje a vyvíjí celá řada aplikací (nejen) pro podporu výuky, které pro svou funkci potřebují přístup k rozvrhům, studijním plánům, informacím o předmětech, zkouškách atd. Potřebná data se uchovávají právě v KOSu. Většinou se jedná o aplikace, které vyvíjí sami akademičtí pracovníci nebo studenti v rámci závěrečných prací. Najdeme tu jak malé projekty pro specifické potřeby jednoho předmětu, tak velké pro celou fakultu.

Problém byl ovšem v tom, že až do vytvoření KOSapi neexistovalo žádné dostupné a zdokumentované aplikační rozhraní (API), které by umožňovalo strojový přístup k datům v KOSu. SQL přístup do databáze byl smrtelníkům zapovězen a o jakémkoli API se vývojářům jen snilo. Jediné, co měli k dispozici, byl neúplný a nezdokumentovaný XML export rozvrhových dat; jednou denně generovaný „dump“ části databáze KOS pro jeden semestr. To byla také výchozí situace pro mou bakalářskou práci.


### Počátky

První verze KOSapi čerpala data ze zmíněného exportu, který zpracovávala a dávkově načítala do vlastní SQL databáze. Nad tou bylo vystaveno RESTové rozhraní, které umožňovalo snadný přístup k rozvrhovým lístkům, základním informacím o předmětech, vyučujících, studentech, místnostech a katedrách; vše jen pro čtení a pro aktuální semestr. Mimo to generovala rozvrhy v kalendářní podobě, ve standardním formátu iCalendar. Trochu paradoxně k tomu, že se jednalo pouze o okrajovou funkcionalitu, se tato stala nejoblíbenější, zejména mezi studenty. 

KOSapi vyvolalo velký ohlas, takže jsem se jeho vývoji věnoval i nadále. V létě téhož roku jsem zanalyzoval a sepsal dokumentaci nově vzniknuvšího XML exportu části KOS týkající se studijních plánů (tzv. Bílá kniha). Během toho jsem zjistil, že export rozvrhů vůbec neodpovídá skutečné struktuře dat v KOS, o které jsem ovšem stále věděl pramálo. Stávající RESTové rozhraní tedy muselo doznat několika strukturálních změn, k tomu přibyly nové zdroje pro předměty z „Bílé knihy“ a „importovací“ modul načítal data již ze dvou exportů. Tím vznikla přechodná verze 2, která byla spuštěna v polovině září roku 2010. 

Ve stejné době byla také spuštěna druhá instance KOSapi, na nové Fakultě informačních technologií. Ta se také stala mým novým působištěm, neboť jsem zde nastoupil na magisterské studium.

KOSapi začalo získávat na důležitosti; využívalo ho již několik projektů a další stále přibývaly. Podařilo se mi získat alespoň DDL export struktury tabulek v KOS, díky čemuž jsem do jeho problémové domény konečně získal trochu lepší náhled. Zároveň začala svítat naděje na získání SQL přístupu do KOS a přibývat problémů i omezení způsobené jeho exporty. Začal jsem pomalu pracovat na KOSapi 3.0.


### Metamorfóza

Při vývoji třetí verze jsem se poučil z předchozích, získal nové znalosti a nakonec většinu KOSapi kompletně přepsal. Změnil jsem architekturu, některé frameworky a především přepracoval RESTovou vrstvu. Navrhl jsem a implementoval podporu pro parametrické vyhledávání nazvanou RSQL, částečné odpovědi XPartial, podporu pro automatické generování „hyperlinků“ z objektových vazeb atd.

Konečně jsem měl k dispozici informace o struktuře dat v KOS, takže jsem mohl implementovat mapování entit s ohledem na budoucí přímý přístup k databázi KOS. Z toho důvodu jsem dočasně vyřadil rozvrhová data, neboť jak už bylo zmíněno, jejich export se od skutečné struktury v databázi velmi lišil.

Na konci června roku 2011 proběhla prezentace k představení nové verze KOSapi, které se zúčastnili zástupci FEL, FIT, Fakulty dopravní a VIC. V té době už KOSapi využívalo více než deset fakultních projektů.

V září jsem společně s Ing. Halaškou a Mgr. Nagy z VIC začal připravovat databázové pohledy v KOS, které byly potřeba pro budoucí napojení KOSapi. Samotný přístup do databáze jsme získali až 9. 3. 2012.


Cíl práce
---------

Cílem této práce je sestavit sadu doporučení pro návrh RESTful API, a to s ohledem na příslušné standardy a obecně užívané konvence. Na základě těchto doporučení navrhnout rozhraní nové verze KOSapi. Dále přepsat KOSapi tak, aby namísto stávajících XML exportů využívalo přímý přístup do databáze KOS. Rozšířit doménu o nově zpřístupněná data z KOS, zejména tzv. „Bílou knihu“ – to zahrnuje jak perzistentní vrstvu, tak RESTové rozhraní. Nakonec na základě stanovených doporučení a požadavků novou verzi KOSapi implementovat a provést akceptační test splnění požadavků.


Členění textu
-------------

Text této práce je členěn do pěti kapitol. První se zabývá obecnými doporučeními pro návrh RESTful API. Ve druhé kapitole jsou definovány funkční a nefunkční požadavky na novou verzi KOSapi. Třetí kapitola obsahuje návrh nového RESTful API s popisem problémové domény a následujícím srovnáním s první verzí KOSapi. V kapitole čtvrté je popsán návrh a realizace nejzajímavějších funkcí nové verze – parametrického vyhledávání RSQL, „částečných odpovědí“ XPartial a implementačního řešení vícejazyčných textů. Poslední kapitola poté ověřuje splnění požadavků.
