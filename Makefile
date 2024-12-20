TARGET ?= ./target
NAME = tldr-cr
ENV_NAME = tldr-build
INVOKER ?= podman run --rm -v $$(pwd):/tex -w /tex $(ENV_NAME)

all: $(TARGET)/$(NAME).pdf

MACROS = common/macro.tex common/amsthm.tex

$(TARGET):
	mkdir -p $@

$(TARGET)/$(NAME).pdf: $(NAME).tex document.tex $(MACROS) $(TARGET)/$(NAME).bbl | $(TARGET)
	$(INVOKER) lualatex -synctex=1 -interaction=batchmode -output-directory=$(TARGET) $(NAME)

build-once: | $(TARGET)
	$(INVOKER) lualatex -synctex=1 -interaction=batchmode -output-directory=$(TARGET) $(NAME)

debug: | $(TARGET)
	$(INVOKER) lualatex -synctex=1 -output-directory=$(TARGET) $(NAME)

$(TARGET)/$(NAME).bbl: $(TARGET)/$(NAME).bcf $(NAME).bib
	$(INVOKER) biber $(basename $<) --quiet

$(TARGET)/$(NAME).bcf: $(NAME).tex
	$(INVOKER) lualatex -synctex=1 -interaction=batchmode -output-directory=$(TARGET) $(NAME)


clean: | $(TARGET)
	rm $(TARGET)/*

env: Containerfile
	podman build . -t $(ENV_NAME)
