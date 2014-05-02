mds = $(shell for F in *.md; do echo $${F%.md}; done | grep -v README)
ymls = $(shell for F in *.yml; do echo $${F%.yml}; done)

BP_Hroncok_Miroslav_2014.pdf: library.bib BP_Hroncok_Miroslav_2014.tex $(addsuffix .tex,$(mds) $(ymls)) bin/compile images template biblatex-iso690
	./bin/compile

$(addsuffix .tex,$(mds) $(ymls)): $(addsuffix .md,$(mds)) $(addsuffix .yml,$(ymls)) bin/convert
	./bin/convert

clean:
	git clean -Xf

.PHONY: clean
