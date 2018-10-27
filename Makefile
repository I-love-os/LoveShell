NAME=LoveShell
SOURCE=src/LoveShell.cr

define SHELLS
/bin/LoveShell
/usr/bin/LoveShell
endef

.PHONY: run
run:
	DEV=1 crystal run $(SOURCE)

.PHONY: build
build:
	crystal build --release $(SOURCE)

.PHONY: install
install: build
ifeq (,$(wildcard /usr/bin/LoveShell))
	sudo mv $(NAME) /usr/bin/$(NAME)
else
	sudo rm /usr/bin/$(NAME) && sudo mv $(NAME) /usr/bin/$(NAME)
endif

#RUN TESTS