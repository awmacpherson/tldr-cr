TARGET ?= ./target
NAME = tldr-cr
ENV_NAME = tldr-build
INVOKER ?= podman run --rm --network none -v $$(pwd):/tex:Z -w /tex oci-archive:$(ENV_NAME).tar

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

$(TARGET)/$(NAME).bbl: $(TARGET)/$(NAME).bcf $(NAME).bib | $(TARGET)
	$(INVOKER) biber $(basename $<) --quiet

$(TARGET)/$(NAME).bcf: $(NAME).tex | $(TARGET)
	$(INVOKER) lualatex -synctex=1 -interaction=batchmode -output-directory=$(TARGET) $(NAME)


clean: | $(TARGET)
	rm $(TARGET)/*

env: $(ENV_NAME).tar

$(ENV_NAME).tar: Containerfile
	-podman build . -t oci-archive:$@

rm-env:
	rm $(ENV_NAME).tar

#env: Containerfile
#	podman build . -t $(ENV_NAME)
