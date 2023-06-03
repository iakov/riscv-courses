ASCIIDOCTOR_PDF = asciidoctor-pdf

ROOT_ASCIIDOC_NAME = Course

CHAPTERS_DIR = Chapters
CHAPTERS = $(wildcard $(CHAPTERS_DIR)/*.adoc)

ROOT_ASCIIDOC = $(ROOT_ASCIIDOC_NAME).adoc
RESULT_PDF = $(ROOT_ASCIIDOC_NAME).pdf

.PHONY: all
all: $(RESULT_PDF)

$(RESULT_PDF): $(ROOT_ASCIIDOC) $(CHAPTERS)
	$(ASCIIDOCTOR_PDF) --trace --out-file=$@ $<

.PHONY: clean
clean:
	$(RM) $(RESULT_PDF)
