% vim: set fenc=utf-8
%
% Customized class for CTU FIT theses
%
% This class should be used with XeLaTeX and UTF-8 documents only!
%
% You need to install BibLaTeX style for CSN ISO 690 that you can download from 
% https://github.com/michal-h21/biblatex-iso690 (it’s not in CTAN yet).
% 
% Sice XeLaTeX uses OpenType fonts provided by your operation system, make sure
% that you have these open-source fonts installed:
%   * Linux Libertine Fonts (http://www.linuxlibertine.org/)
%   * DejaVu Fonts (http://dejavu-fonts.org/)
% Or choose another fonts you like and change \setmainfont and \setmonofont.
% 
% @author:  Ondrej Guth <ondrej.guth@fit.cvut.cz>, 
%           Jakub Jirutka <jakub.jirutka@fit.cvut.cz>
% @version: 2013-05-10
% 
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{FITthesisXE}[2013/04/26 CTU FIT customized class for theses]

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Options
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

\newif \if@thesistypedefined
\DeclareOption {thesis=B} { \gdef \@thesistype{B} \@thesistypedefinedtrue }
\DeclareOption {thesis=M} { \gdef \@thesistype{M} \@thesistypedefinedtrue }

\newif \if@langdefined
\newif \if@langczech
\DeclareOption {czech} {
	\@langczechtrue
	\@langdefinedtrue
}
\DeclareOption {english} {
	\@langczechfalse
	\@langdefinedtrue
}
\DeclareOption {10pt} { \PassOptionsToClass {\CurrentOption} {memoir} }
\DeclareOption {11pt} { \PassOptionsToClass {\CurrentOption} {memoir} }
\DeclareOption {12pt} { \PassOptionsToClass {\CurrentOption} {memoir} }

\ExecuteOptions {12pt, czech}
\ProcessOptions

\if@langdefined \else
	\ClassError {FITthesis} {Language not specified} {Add option czech for Czech language or option english for English language.}
\fi

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Settings
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

\LoadClass [a4paper,twoside] {memoir} [2008/08/07]

\setsecnumdepth {subsubsection}
\chapterstyle {madsen}

\let \newfloat \relax			% use floatrow package instead of float
\RequirePackage {floatrow}		% ...so we can force caption position

\RequirePackage {fontspec}		% font selection for XeLaTeX
\RequirePackage {xltxtra}		% extras for XeTeX
\RequirePackage {polyglossia}	% replacement for babel
\RequirePackage {hyperref}		% hyperlinks support
\RequirePackage {minted}		% source code highlighting via Pygments
\RequirePackage {etoolbox}

% microtype currently supports only protrusion with XeLaTeX :(
\RequirePackage [protrusion=true] {microtype}

% support for acronyms
\RequirePackage [acronym,nonumberlist,sort=def] {glossaries}

% define new glossary style for list of acronyms
\newglossarystyle {acronyms} {%
	\glossarystyle {long}  % style that uses longtable
	\renewcommand {\glossarysection}[2][] {}  % disable header
	\renewcommand {\glsgroupskip} {}  % disable grouping

	% renew the entry field to make the entries bold
	\renewcommand* {\glossaryentryfield}[5] {%
		\bfseries\glsentryitem{##1}\glstarget{##1}{##2} & ##3\glspostdescription\space ##5%
		\tabularnewline
	}
}

\newfloat{dirfigure}{htbp}{lod}[chapter]

\if@langczech
	\setmainlanguage {czech}
	\setotherlanguage {english}

	\RequirePackage {csquotes}	% context sensitive quotation facilities
	\DeclareQuoteStyle {czech}%
		{\quotedblbase}			% opening outer mark
		{\textquotedblleft}		% closing outer mark
		{\textquoteleft}		% opening inner mark
		{\textquoteright}		% closing inner mark
	\setquotestyle {czech}

	\RequirePackage [backend=biber, citestyle=iso-numeric, autolang=other,%
					sorting=nyt, urldate=iso8601]{ biblatex }

	\renewcommand*{\acronymname}{Seznam použitých zkratek}
	\renewcommand*{\dirfigurename}{Adresářová struktura}
	\newcommand{\listdirfigurename}{Seznam adresářových struktur}
\else
	\setdefaultlanguage [variant=british] {english}
	\RequirePackage [backend=biber, citestyle=iso-numeric, autolang=other,%
					sorting=nyt, urldate=iso8601]{ biblatex }
	\renewcommand*{\dirfigurename}{Directory structure}
	\newcommand{\listdirfigurename}{List of Directory structures}
\fi

\newlistof{listofdirfigures}{lod}{\listdirfigurename}
\newlistentry{dirfigure}{lod}{0}
\floatsetup[dirfigure]{justification=justified}

% disable per-chapter numbering for footnotes
\counterwithout* {footnote} {chapter}

\setlrmargins {4cm} {*} {*} \checkandfixthelayout

% declare conditional list of tables that prints list only if there's some
% table in the document
\AtEndEnvironment {table} {%
	\gdef \there@is@a@table{}
}
\AtEndDocument {%
	\ifdefined \there@is@a@table \label{tab:was:used:in:doc} \fi
}
\DeclareRobustCommand {\listoftablescond} {%
	\@ifundefined {r@tab:was:used:in:doc} {} {\listoftables*} 
}

\renewcommand{\memchapinfo}[4]{%
  \addtocontents{lol}{\protect\addvspace{10pt}}}

% declare conditional list of listings that prints list only if there's some
% listing in the document
\AtEndEnvironment {listing} {%
	\gdef \there@is@a@listing{}
}
\AtEndDocument {%
	\ifdefined \there@is@a@listing \label{listing:was:used:in:doc} \fi
}
\DeclareRobustCommand {\listoflistingscond} {%
	\@ifundefined {r@listing:was:used:in:doc} {} {\listoflistings} 
}

% declare conditional list of figures that prints list only if there's some
% figure in the document
\AtEndEnvironment {figure} {%
	\gdef \there@is@a@figure{}
}
\AtEndDocument {%
	\ifdefined \there@is@a@figure \label{figure:was:used:in:doc} \fi
}
\DeclareRobustCommand {\listoffigurescond} {%
	\@ifundefined {r@figure:was:used:in:doc} {} {\listoffigures*} 
}

% declare conditional list of dirfigures that prints list only if there's some
% dirfigure in the document
\AtEndEnvironment {dirfigure} {%
	\gdef \there@is@a@dirfigure{}
}
\AtEndDocument {%
	\ifdefined \there@is@a@dirfigure \label{dirfigure:was:used:in:doc} \fi
}
\DeclareRobustCommand {\listofdirfigurescond} {%
	\@ifundefined {r@dirfigure:was:used:in:doc} {} {\listofdirfigures*} 
}

% line breaks in URL
\def \UrlBreaks {\do\/\do\-}

% change default fonts (provided by OS)
\setmainfont [Ligatures=TeX, BoldFont={* Semibold}] {Linux Libertine O}
\setmonofont [Scale=.80] {DejaVu Sans Mono}

% increase line spacing to 115 % for better readability
\DisemulatePackage {setspace}
\RequirePackage {setspace}
\setstretch {1.15}

% use sans-serif font for titles
\setsecheadstyle		{ \Large \bfseries \sffamily }
\setsubsecheadstyle		{ \large \bfseries \sffamily }
\setsubsubsecheadstyle	{ \normalsize \bfseries \sffamily }

% do not indent the first line of a paragraph and add blank line after each
\DisemulatePackage {parskip}
\RequirePackage [parfill] {parskip}

%\floatsetup [table] {style = plaintop}
%\floatsetup [listing] {style = plaintop}

% use sans-serif and smaller font for captions
\DisemulatePackage {caption}
\RequirePackage {caption}
\captionsetup {
	font = {small, sf},
	labelfont = {bf}
}

% adjust boxes size
\setlength {\fboxsep} {8pt}

% tune hyphenation
\pretolerance=1500
%\tolerance=1000

% try to minimalize widows and orphans
\widowpenalty=10000
\clubpenalty=10000

% adjust settings for minted if used
\AtBeginDocument {%
	\renewcommand*{\today}{10. května 2014} % FIXME
	\@ifpackageloaded {minted} {%
		% use smaller font in code listings
		\AtBeginEnvironment {minted} { \singlespacing \fontsize{11}{11} \selectfont }

		% define background color for listing box; it should be passed as parametr
		% to every minted block, e.g. \begin{minted}[bgcolor=codebg]{json}
		\definecolor {codebg} {rgb} {0.92, 0.92, 0.92}

		% use per-chapter numbering
		\counterwithin {listing} {chapter}

		% set prefix of the code listing caption
		\if@langczech 
			\renewcommand \listingscaption{Ukázka kódu} 
			\renewcommand \listoflistingscaption{Seznam ukázek kódu}
		\fi
	}
}

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% General commands
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

\DeclareRobustCommand {\chapterstyletitle}[1] {
	\@makechapterhead{#1}
	\noindent
}

\newenvironment {introduction} {
	\setsecnumdepth{part}
	\if@langczech \chapter{Úvod} \else \chapter{Introduction} \fi
}{
	\setsecnumdepth {subsubsection}
}

\newenvironment {conclusion} {
	\setsecnumdepth {part}
	\if@langczech \chapter{Závěr} \else \chapter{Conclusion} \fi
}{
	\setsecnumdepth {subsubsection}
}

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Template
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

\newif \if@supervisordefined
\DeclareRobustCommand {\supervisor}[1] {
	\def\thesupervisor{#1}
	\@supervisordefinedtrue
}

\newif \if@departmentdefined
\DeclareRobustCommand {\department}[1] {
	\def\thedepartment{#1}
	\@departmentdefinedtrue
}

\newif \if@acknowledgementsdefined
\DeclareRobustCommand {\acknowledgements}[1] {
	\def\theacknowledgements{#1}
	\@acknowledgementsdefinedtrue
}

\newif \if@abstractcsdefined
\DeclareRobustCommand {\abstractCS}[1] {
	\def\theabstractcs{#1}
	\@abstractcsdefinedtrue
}

\newif \if@abstractendefined
\DeclareRobustCommand {\abstractEN}[1] {
	\def\theabstracten{#1}
	\@abstractendefinedtrue
}

% \newif \if@declarationofauthenticitydefined
% \DeclareRobustCommand {\declarationOfAuthenticity}[1] {
% 	\def\thedeclarationofauthenticity{#1}
% 	\@declarationofauthenticitydefinedtrue
% }

\newif \if@cityfordeclarationdefined
\DeclareRobustCommand {\placeForDeclarationOfAuthenticity}[1] {
	\def\thecityfordeclaration{#1}
	\@cityfordeclarationdefinedtrue
}

\newif \if@keywordscsdefined
\DeclareRobustCommand {\keywordsCS}[1] {
	\def\thekeywordscs{#1}
	\@keywordscsdefinedtrue
}

\newif \if@keywordsendefined
\DeclareRobustCommand {\keywordsEN}[1] {
	\def\thekeywordsen{#1}
	\@keywordsendefinedtrue
}

\newif \if@authorwithdegreesdefined
\DeclareRobustCommand {\authorWithDegrees}[1] {
	\def\theauthorwithdegrees{#1}
	\@authorwithdegreesdefinedtrue
}

\newif \if@authorGNdefined
\DeclareRobustCommand {\authorGN}[1] {
	\def\theauthorGN{#1}
	\@authorGNdefinedtrue
}

\newif \if@authorFNdefined
\DeclareRobustCommand {\authorFN}[1] {
	\def\theauthorFN{#1}
	\@authorFNdefinedtrue
}

\DeclareRobustCommand {\thesistype} {%
	\if@thesistypedefined
		\if\@thesistype B%
			\if@langczech {Bakalářská práce} \else {Bachelor's thesis} \fi
		\else
			\if\@thesistype M%
				\if@langczech {Diplomová práce} \else {Master's thesis} \fi
			\else
				\ClassError {FITthesis} {Thesis type not specified} {Add option thesis=B for bachelor's thesis or option thesis=M for master's thesis.}
			\fi
		\fi
	\else
		\ClassError {FITthesis} {Thesis type not specified} {Add option thesis=B for bachelor's thesis or option thesis=M for master's thesis.}
	\fi
}

\newif\if@declarationOptionSelected
\DeclareRobustCommand{\declarationOfAuthenticityOption}[1]{
	\ifx1#1 \DeclareRobustCommand{\thedeclarationofauthenticity}{\if@langczech{%
		Prohlašuji, že jsem předloženou práci vypracoval samostatně a že jsem uvedl veškeré použité informační zdroje v~souladu s~Metodickým pokynem o~etické přípravě vysokoškolských závěrečných prací.

		Beru na vědomí, že se na moji práci vztahují práva a povinnosti vyplývající ze zákona č.~121/2000~Sb., autorského zákona, ve znění pozdějších předpisů, zejména skutečnost, že České vysoké učení technické v~Praze má právo na uzavření licenční smlouvy o~užití této práce jako školního díla podle §~60 odst.~1 autorského zákona.
		}\else{%
		I hereby declare that the presented thesis is my own work and that I have cited all sources of information in accordance with the Guideline for adhering to ethical principles when elaborating an academic final thesis.
		
		I acknowledge that my thesis is subject to the rights and obligations stipulated by the Act No.~121/2000 Coll., the Copyright Act, as amended, in particular that the Czech Technical University in Prague has the right to conclude a license agreement on the utilization of this thesis as a school work under the provisions of Article~60(1) of the Act.
		}\fi
	}\@declarationOptionSelectedtrue\fi
	\ifx2#1 \DeclareRobustCommand{\thedeclarationofauthenticity}{\@declarationOptionSelectedtrue\if@langczech{%
		Prohlašuji, že jsem předloženou práci vypracoval samostatně a že jsem uvedl veškeré použité informační zdroje v~souladu s~Metodickým pokynem o~etické přípravě vysokoškolských závěrečných prací.

		Beru na vědomí, že se na moji práci vztahují práva a povinnosti vyplývající ze zákona č.~121/2000~Sb., autorského zákona, ve znění pozdějších předpisů. V~souladu s~ust. §~46 odst.~6 tohoto zákona tímto uděluji nevýhradní oprávnění (licenci) k~užití této mojí práce, a to včetně všech počítačových programů, jež jsou její součástí či přílohou a veškeré jejich dokumentace (dále souhrnně jen „Dílo“), a to všem osobám, které si přejí Dílo užít. Tyto osoby jsou oprávněny Dílo užít jakýmkoli způsobem, který nesnižuje hodnotu Díla, avšak pouze k~nevýdělečným účelům. Toto oprávnění je časově, teritoriálně i množstevně neomezené.
		}\else{%
		I hereby declare that the presented thesis is my own work and that I have cited all sources of information in accordance with the Guideline for adhering to ethical principles when elaborating an academic final thesis.
		
		I acknowledge that my thesis is subject to the rights and obligations stipulated by the Act No.~121/2000 Coll., the Copyright Act, as amended. In accordance with Article~46(6) of the Act, I hereby grant a nonexclusive authorization (license) to utilize this thesis, including any and all computer programs incorporated therein or attached thereto and all corresponding documentation (hereinafter collectively referred to as the ``Work''), to any and all persons that wish to utilize the Work. Such persons are entitled to use the Work for non-profit purposes only, in any way that does not detract from its value. This authorization is not limited in terms of time, location and quantity.
		}\fi
	}\fi
	\ifx3#1 \DeclareRobustCommand{\thedeclarationofauthenticity}{\if@langczech{%
		Prohlašuji, že jsem předloženou práci vypracoval samostatně a že jsem uvedl veškeré použité informační zdroje v~souladu s~Metodickým pokynem o~etické přípravě vysokoškolských závěrečných prací.

		Beru na vědomí, že se na moji práci vztahují práva a povinnosti vyplývající ze zákona č.~121/2000~Sb., autorského zákona, ve znění pozdějších předpisů. Dále prohlašuji, že jsem s~Českým vysokým učením technickým v~Praze uzavřel licenční smlouvu o~užití této práce jako školního díla podle §~60 odst.~1 autorského zákona. Tato skutečnost nemá vliv na ust. §~47b zákona č.~111/1998~Sb., o~vysokých školách, ve znění pozdějších předpisů.
		}\else{%
		I hereby declare that the presented thesis is my own work and that I have cited all sources of information in accordance with the Guideline for adhering to ethical principles when elaborating an academic final thesis.
		
		I acknowledge that my thesis is subject to the rights and obligations stipulated by the Act No.~121/2000 Coll., the Copyright Act, as amended. I further declare that I have concluded a license agreement with the Czech Technical University in Prague on the utilization of this thesis as a school work under the provisions of Article~60(1) of the Act. This fact shall not affect the provisions of Article~47b of the Act No.~111/1998 Coll., the Higher Education Act, as amended.
		}\fi
	}\@declarationOptionSelectedtrue\fi
	\ifx4#1 \DeclareRobustCommand{\thedeclarationofauthenticity}{\if@langczech{%
		Prohlašuji, že jsem předloženou práci vypracoval samostatně a že jsem uvedl veškeré použité informační zdroje v~souladu s~Metodickým pokynem o~etické přípravě vysokoškolských závěrečných prací.

		Beru na vědomí, že se na moji práci vztahují práva a povinnosti vyplývající ze zákona č.~121/2000~Sb., autorského zákona, ve znění pozdějších předpisů. V~souladu s~ust. §~46 odst.~6 tohoto zákona tímto uděluji nevýhradní oprávnění (licenci) k~užití této mojí práce, a to včetně všech počítačových programů, jež jsou její součástí či přílohou a veškeré jejich dokumentace (dále souhrnně jen „Dílo“), a to všem osobám, které si přejí Dílo užít. Tyto osoby jsou oprávněny Dílo užít jakýmkoli způsobem, který nesnižuje hodnotu Díla a za jakýmkoli účelem (včetně užití k~výdělečným účelům). Toto oprávnění je časově, teritoriálně i~množstevně neomezené. Každá osoba, která využije výše uvedenou licenci, se však zavazuje udělit ke každému dílu, které vznikne (byť jen zčásti) na základě Díla, úpravou Díla, spojením Díla s~jiným dílem, zařazením Díla do díla souborného či zpracováním Díla (včetně překladu), licenci alespoň ve výše uvedeném rozsahu a zároveň zpřístupnit zdrojový kód takového díla alespoň srovnatelným způsobem a ve srovnatelném rozsahu, jako je zpřístupněn zdrojový kód Díla.
		}\else{%
		I hereby declare that the presented thesis is my own work and that I have cited all sources of information in accordance with the Guideline for adhering to ethical principles when elaborating an academic final thesis.
		
		I acknowledge that my thesis is subject to the rights and obligations stipulated by the Act No.~121/2000 Coll., the Copyright Act, as amended. In accordance with Article~46(6) of the Act, I hereby grant a nonexclusive authorization (license) to utilize this thesis, including any and all computer programs incorporated therein or attached thereto and all corresponding documentation (hereinafter collectively referred to as the ``Work''), to any and all persons that wish to utilize the Work. Such persons are entitled to use the Work in any way (including for-profit purposes) that does not detract from its value. This authorization is not limited in terms of time, location and quantity. However, all persons that makes use of the above license shall be obliged to grant a license at least in the same scope as defined above with respect to each and every work that is created (wholly or in part) based on the Work, by modifying the Work, by combining the Work with another work, by including the Work in a collection 
of works or by adapting the Work (including translation), and at the same time make available the source code of such work at least in a way and scope that are comparable to the way and scope in which the source code of the Work is made available.
		}\fi
	}\@declarationOptionSelectedtrue\fi
	\ifx5#1 \DeclareRobustCommand{\thedeclarationofauthenticity}{\if@langczech{%
		Prohlašuji, že jsem předloženou práci vypracoval samostatně a že jsem uvedl veškeré použité informační zdroje v~souladu s~Metodickým pokynem o~etické přípravě vysokoškolských závěrečných prací.

		Beru na vědomí, že se na moji práci vztahují práva a povinnosti vyplývající ze zákona č.~121/2000~Sb., autorského zákona, ve znění pozdějších předpisů. V~souladu s~ust. §~46 odst.~6 tohoto zákona tímto uděluji nevýhradní oprávnění (licenci) k~užití této mojí práce, a to včetně všech počítačových programů, jež jsou její součástí či přílohou a veškeré jejich dokumentace (dále souhrnně jen „Dílo“), a to všem osobám, které si přejí Dílo užít. Tyto osoby jsou oprávněny Dílo užít jakýmkoli způsobem, který nesnižuje hodnotu Díla a za jakýmkoli účelem (včetně užití k~výdělečným účelům). Toto oprávnění je časově, teritoriálně i množstevně neomezené.
		}\else{
		I hereby declare that the presented thesis is my own work and that I have cited all sources of information in accordance with the Guideline for adhering to ethical principles when elaborating an academic final thesis.
		
		I acknowledge that my thesis is subject to the rights and obligations stipulated by the Act No.~121/2000 Coll., the Copyright Act, as amended. In accordance with Article~46(6) of the Act, I hereby grant a nonexclusive authorization (license) to utilize this thesis, including any and all computer programs incorporated therein or attached thereto and all corresponding documentation (hereinafter collectively referred to as the ``Work''), to any and all persons that wish to utilize the Work. Such persons are entitled to use the Work in any way (including for-profit purposes) that does not detract from its value. This authorization is not limited in terms of time, location and quantity.
		}\fi
	}\@declarationOptionSelectedtrue\fi
	\ifx6#1 \DeclareRobustCommand{\thedeclarationofauthenticity}{\if@langczech{%
		Prohlašuji, že jsem předloženou práci vypracoval samostatně a že jsem uvedl veškeré použité informační zdroje v~souladu s~Metodickým pokynem o~etické přípravě vysokoškolských závěrečných prací.

		Beru na vědomí, že se na moji práci vztahují práva a povinnosti vyplývající ze zákona č.~121/2000~Sb., autorského zákona, ve znění pozdějších předpisů. Dále prohlašuji, že jsem s~Českým vysokým učením technickým v~Praze uzavřel dohodu, na základě níž se ČVUT vzdalo práva na uzavření licenční smlouvy o~užití této práce jako školního díla podle §~60 odst.~1 autorského zákona. Tato skutečnost nemá vliv na ust. §~47b zákona č.~111/1998~Sb., o~vysokých školách, ve znění pozdějších předpisů.
		}\else{
		I hereby declare that the presented thesis is my own work and that I have cited all sources of information in accordance with the Guideline for adhering to ethical principles when elaborating an academic final thesis.
		
		I acknowledge that my thesis is subject to the rights and obligations stipulated by the Act No.~121/2000 Coll., the Copyright Act, as amended. I further declare that I have concluded an agreement with the Czech Technical University in Prague, on the basis of which the Czech Technical University in Prague has waived its right to conclude a license agreement on the utilization of this thesis as a school work under the provisions of Article~60(1) of the Act. This fact shall not affect the provisions of Article~47b of the Act No.~111/1998 Coll., the Higher Education Act, as amended. 
		}\fi
	}\@declarationOptionSelectedtrue\fi
	
}

\DeclareRobustCommand{\titlepage}{
	\begin{titlingpage}
		\begin{center}
			\noindent\begin{tabular*}{\textwidth}{m{.77\textwidth}m{.165\textwidth}}
				{\large\scshape \if@langczech{
						České vysoké učení technické v~Praze
					}\else{
						Czech Technical University in Prague
					}\fi
					
					\vspace{4mm}
					
					\if@langczech{
						Fakulta informačních technologií
					}\else{
						Faculty of Information Technology
					}\fi
					
					\vspace{4mm}
					
					\if@departmentdefined
						\thedepartment
					\else
						\ClassError{FITthesis}{Department unspecified}{Specify the department using the \department command.}
					\fi
				} & \hfill\includegraphics[width=.16\textwidth]{pdfs/cvut-logo-bw}
			\end{tabular*}
		\end{center}
		

		\vfill

		{\Large
			\noindent\thesistype
		}
		\vspace{1cm}

		\if\thetitle\empty
			\ClassError{FITthesis}{Thesis' title unspecified}{Specify title of this thesis using the \protect\title\space command.}
		\else
			\noindent\textbf{\LARGE \begin{flushleft}\thetitle\end{flushleft}}
		\fi

		\vspace{4mm}

		\if@authorwithdegreesdefined
			\noindent\textbf{\Large \textit{\theauthorwithdegrees}}
		\else
			\ClassError{FITthesis}{Thesis' author with degrees unspecified}{Specify author of this thesis (i.e. your name \& degrees) using the \protect\theauthorwithdegrees\space command.}
		\fi

		\vfill

		\noindent\if@langczech{Vedoucí práce:}\else{Supervisor:}\fi
			\if@supervisordefined%
				~\thesupervisor
			\else
				\ClassError{FITthesis}{Thesis' supervisor unspecified}{Specify the supervisor of this thesis using the \protect\thesupervisor\space command.}
			\fi

		\vspace{1cm}

		\noindent\today
	\end{titlingpage}
}

\DeclareRobustCommand{\acknowledgementspage}{
	\if@acknowledgementsdefined
		\cleardoublepage
		\thispagestyle{empty}
		
		~
		
		\vfill

		\if@langczech\chapterstyletitle{Poděkování}\else\chapterstyletitle{Acknowledgements}\fi\theacknowledgements
	\fi
}

\DeclareRobustCommand{\declarationofauthenticitypage}{
	\cleardoublepage
	\thispagestyle{empty}

	~
	
	\vfill
		
	\if@declarationOptionSelected
		\if@langczech\chapterstyletitle{Prohlášení}\else\chapterstyletitle{Declaration}\fi\thedeclarationofauthenticity{}
		
		\vspace{1cm}

		\noindent
			\if@cityfordeclarationdefined
				\if@langczech{}\else{In }\fi\thecityfordeclaration{} \if@langczech{dne}\else{on}\fi~\today \hfill \dots\dots\dots\dots\dots\dots\dots
			\else
				\ClassError{FITthesis}{Místo prohlášení nebylo zadáno}{Nastavte místo, kde bylo podepsáno prohlášení, včetně předložky (např. V~Praze) pomocí příkazu \placeForDeclaration.}
			\fi

	\else
		\ClassError{FITthesis}{Declaration of authenticity unspecified}{Select the declaration of authenticity using the \declarationOfAuthenticityOption command.}
	\fi
}

\DeclareRobustCommand{\imprintpage}{
	\clearpage
	\thispagestyle{empty}
	
	~
	
	\vfill
	
	\if@langczech{
		\noindent České vysoké učení technické v~Praze

		\noindent Fakulta informačních technologií}\else{
		\noindent Czech Technical University in Prague
		
		\noindent Faculty of Information Technology
	}\fi
	
	\noindent \textcopyright{} \the\year{} \theauthorGN{} \theauthorFN{}. \if@langczech{Všechna práva vyhrazena.}\else{All rights reserved.}\fi
	
	\if@langczech{
		\noindent \textit{Tato práce vznikla jako školní dílo na Českém vysokém učení technickém v~Praze, Fakultě informačních technologií. Práce je chráněna právními předpisy a mezinárodními úmluvami o~právu autorském a právech souvisejících s~právem autorským. K~jejímu užití, s~výjimkou bezúplatných zákonných licencí, je nezbytný souhlas autora.}}\else{
		\noindent \textit{This thesis is a school work as defined by Copyright Act of the Czech Republic. It has been submitted at Czech Technical University in Prague, Faculty of Information Technology. The thesis is protected by the Copyright Act and its usage without author's permission is prohibited (with exceptions defined by the Copyright Act).}
	}\fi
	
	\if@langczech{\subsection*{Odkaz na tuto práci} \theauthorFN{}, \theauthorGN{}. \textit{\thetitle{}}. \thesistype{}. Praha: České vysoké učení technické v~Praze, Fakulta informačních technologií, \the\year.}\else{\subsection*{Citation of this thesis} \theauthorFN{}, \theauthorGN{}. \textit{\thetitle{}}. \thesistype{}. Czech Technical University in Prague, Faculty of Information Technology, \the\year.}\fi
}

\DeclareRobustCommand{\abstractpage}{%
	\if@abstractcsdefined
		\cleardoublepage
		\thispagestyle{empty}
		~
		\vfill
		\chapterstyletitle{Abstrakt}\theabstractcs
	\else
		\ClassError{FITthesis}{Abstract in Czech unspecified}{Specify abstract in Czech language using the \abstractCS command.}
	\fi
	
	\if@keywordscsdefined
		\paragraph*{Klíčová slova} \thekeywordscs{}
	\else
		\ClassError{FITthesis}{Czech keywords unspecified}{Specify the keywords in Czech of your thesis using \keywordsCS command.}
	\fi

	\if@abstractendefined
		%\cleardoublepage
		%\thispagestyle{empty}
		%~
		%\vfill
		\chapterstyletitle{Abstract}\theabstracten
	\else
		\ClassError{FITthesis}{Abstract in English unspecified}{Specify abstract in English using the \abstractEN command.}
	\fi
	\if@keywordsendefined%
		\paragraph*{Keywords} \thekeywordsen{}
	\else
		\ClassError{FITthesis}{English keywords unspecified}{Specify the keywords in English of your thesis using \keywordsEN command.}
	\fi

}

\AtBeginDocument{
	%\pagestyle{plain}
	\cleardoublepage
	\titlepage
	
	\setcounter{page}{5}
	\acknowledgementspage

	\declarationofauthenticitypage
	\imprintpage

	\abstractpage

	\cleardoublepage
	\tableofcontents*

	\cleardoublepage
	\listoflistingscond

	\cleardoublepage
	\listofdirfigurescond

	\cleardoublepage
	\listoftablescond

	\cleardoublepage
	\listoffigurescond

	\pagestyle{ruled}
}
