.PHONY: all clean

RMDS = $(wildcard rmd/*.rmd)
HTMLS = $(patsubst rmd/%,html/%,$(patsubst %.rmd,%.html,$(RMDS)))
# Some of these trigger the creation of more than one file.
# This saves on the long load time for the data.
# Ideally we'd load the data once then make all the PDFs,
# but this granularity is a compromise between efficiency and flexibility.
PDFS = movement-artist-links.pdf movement-artist-links.pdf movement-artist-links.pdf

all: $(HTMLS) $(PDFS)

movement-artist-links.pdf: r/movement_artist_links.r
	cd r; Rscript movement_artist_links.r \
		-e 'plotMovementArtistLinksPDF("../pdf/movement-artist-links.pdf")'

movement-work-count.pdf: r/movement_artwork_counts.r
	cd r; Rscript movement-artist-links.r \
		-e 'plotMovementArtworkCountPDF("yba-work-count.pdf", "Young British Artists (YBA)")' \
		-e 'plotArtworkCountsByYearPDF("movement-work-count.pdf")'

movement-durations-name.pdf: r/movement_durations.r
	cd r; Rscript movement_durations.r \
		-e 'plotMovementDurationsNamePDF("movement-durations-name.pdf")' \
		-e 'plotMovementDurationsEraPDF("movement-durations-era.pdf")'

html/%.html: rmd/%.rmd
	cd html; Rscript -e 'library(knitr); knitr::knit2html("'../$^'")'

clean:
	rm -fv pdf/*.pdf
	rm -fv html/*.rmd.html
	rm -fv html/*.html
