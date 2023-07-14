ASCIIDOCTOR_PDF = asciidoctor-pdf
ASCIIDOCTOR = asciidoctor
PANDOC = pandoc

ROOT_ASCIIDOC_NAME = Course

CHAPTERS_DIR = Chapters
CHAPTERS = $(wildcard $(CHAPTERS_DIR)/*.adoc)

ROOT_ASCIIDOC = $(ROOT_ASCIIDOC_NAME).adoc
RESULT_PDF = $(ROOT_ASCIIDOC_NAME).pdf
RESULT_XML = $(ROOT_ASCIIDOC_NAME).xml
RESULT_DOCX = $(ROOT_ASCIIDOC_NAME).docx

THEME = theme.yml
REFERENCE = custom-reference.docx
STYLE = tango

.PHONY: all
all: $(RESULT_PDF) $(RESULT_DOCX)

.PHONY: asciidoctor
asciidoctor: $(RESULT_PDF) $(RESULT_XML)

.PHONY: pandoc
pandoc: $(RESULT_DOCX)

$(RESULT_PDF): $(ROOT_ASCIIDOC) $(CHAPTERS) $(THEME)
	$(ASCIIDOCTOR_PDF) \
    	-r asciidoctor-mathematical \
    	-a mathematical-format=svg \
		--theme $(THEME) \
		--out-file='$@' '$<'

$(RESULT_XML): $(ROOT_ASCIIDOC) $(CHAPTERS)
	$(ASCIIDOCTOR) \
		--backend docbook \
		--out-file='$@' '$<'

$(RESULT_DOCX): $(RESULT_XML) $(REFERENCE)
	$(PANDOC) \
		--from docbook \
		--reference-doc=$(REFERENCE) \
		--highlight-style $(STYLE) \
		--output '$@' '$<'

.PHONY: clean
clean:
	$(RM) $(RESULT_PDF) $(RESULT_XML) $(RESULT_DOCX)
