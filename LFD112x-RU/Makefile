include ../Common.mk

$(RESULT_PDF): $(ROOT_ASCIIDOC) $(CHAPTERS) $(THEME)
	$(ASCIIDOCTOR_PDF) \
    	-r asciidoctor-mathematical \
    	-a mathematical-format=svg \
		--theme $(THEME) \
		--out-file='$@' '$<'
