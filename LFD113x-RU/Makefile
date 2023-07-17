include ../Common.mk

$(RESULT_PDF): $(ROOT_ASCIIDOC) $(CHAPTERS) $(THEME)
	$(ASCIIDOCTOR_PDF) \
		--theme $(THEME) \
		--out-file='$@' '$<'
