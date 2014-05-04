Markdown to XeLaTeX
===================

Credit for the system and initial content goes to @jirutka

To generate the PDF, run `make`.


Dependencies
------------

I have the following packages installed (on Fedora):

    linux-libertine-fonts
    pandoc
    texlive
    texlive-arara
    texlive-bera
    texlive-biblatex
    texlive-cs
    texlive-cslatex
    texlive-datatool
    texlive-dirtree
    texlive-etoolbox
    texlive-glossaries
    texlive-hyphen-czech
    texlive-ifplatform
    texlive-libertine
    texlive-logreq
    texlive-minted
    texlive-pgfopts
    texlive-substr
    texlive-vlna
    texlive-xetex
    texlive-xfor
    texlive-xstring

And `biber` from [this copr repository](http://copr.fedoraproject.org/coprs/cbm/Biber/).

Note that maybe not all those packages are really necessary and some may be missing (let me know).

To scale the images as pdfs I use [cpdf](http://community.coherentpdf.com/), feel free to suggest any free software alternative.
