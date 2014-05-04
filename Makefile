mds = $(shell for F in *.md; do echo $${F%.md}; done | grep -v README)
ymls = $(shell for F in *.yml; do echo $${F%.yml}; done)
pngs = $(shell for F in images/*.png; do echo $${F%.png}; done)

BP_Hroncok_Miroslav_2014.pdf: library_.bib BP_Hroncok_Miroslav_2014.tex $(addsuffix .tex,$(mds) $(ymls)) template biblatex-iso690 $(addsuffix .pdf,$(pngs))
	arara BP_Hroncok_Miroslav_2014

meta.tex: meta.yml bin/convert
	./bin/convert meta.yml

acronyms.tex: acronyms.yml bin/convert
	./bin/convert acronyms.yml

%.tex: %.md bin/convert
	./bin/convert "$<"

images/%.pdf: images/%.png bin/png2scaledpdf
	./bin/png2scaledpdf "$<"

library_.bib: library.bib
	sed 's|\\_|_|g' library.bib > library_.bib

clean:
	git clean -Xf

.PHONY: clean
