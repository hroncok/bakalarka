Tady bude závěr.


Možnosti rozvoje
================

V rámci dalšího rozvoje aplikace vidím následující možnosti:

 * Zapisovací API pro nahrání dapu -- tedy především možnost nahrání dapu z příkazové řádky. Toto vyžaduje také autentifikaci v případě použití API, například pomocí tokenu.
 * Závislosti dapů mezi sebou. Časem jistě vyvstane potřeba, aby jeden dap vyžadoval ke své funkcionalitě dap jiný -- například, pokud chce využívat k běhu svých asistentů snipety v něm obsažené.
 * Deklarace podporovaných platforem. Jednotlivé asistenty mohou fungovat jen na některých platformách -- například kvůli specifikování závislostí pouze pomocí seznamu RPM balíčků nebude asistent plně fungovat na distribuci s jiným balíčkováním systémem, či asistent používající linuxový sed nebude vhodně fungovat na systému Mac OS.
 * Kontrola YAML DSL z daploaderu. Daploader nyní neprovádí žádné kontroly obsahu jednotlivých asistentů -- DevAssistant ale obsahuje kód, který kontroluje asistenty na validnost. Tento kód by bylo vhodné vyextrahovat do samostatné knihovny, kterou by používal jak DevAssistant, tak daploader.
 * Použití placené nebo vlastní instance OpenShiftu -- aktuálně použitá veřejná instance OpenShiftu poměrně trpí pod náporem uživatelů, což může mít za následek nepříjemné časy načítání jednotlivých stránek nebo odpovědí API.
 * Asistent na tvorbu asistentů a dapů.
 * Integrace do aplikace DevAssistant -- do grafického i příkazového rozhraní.
 * Pokročilé vyhledávání -- filtrování podle uživatelů, licence, hodnocení apod.
