# cower - a simple AUR downloader

OUT        = cower

VERSION    = 14
VDEVEL     = $(shell test -d .git && git describe 2>/dev/null)

ifneq "$(VDEVEL)" ""
VERSION    = $(VDEVEL)
endif

PREFIX    ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man

OBJ        =

CPPFLAGS  := -D_GNU_SOURCE -DCOWER_VERSION=\"$(VERSION)\" $(CPPFLAGS)
CFLAGS    := -std=c99 -g -pedantic -Wall -Wextra -pthread $(CFLAGS)
LDFLAGS   := -pthread $(LDFLAGS)
LDLIBS     = -lcurl -lalpm -lyajl -larchive -lcrypto

bash_completiondir = /usr/share/bash-completion/completions

all: $(OUT) doc

aur.o: \
	aur.c \
	aur.h
OBJ += aur.o

package.o: \
	package.c \
	package.h
OBJ += package.o

cower.o: \
	cower.c
OBJ += cower.o

cower: \
	aur.o \
	package.o \
	cower.o

MANPAGES = \
	cower.1

doc: $(MANPAGES)
cower.1: README.pod
	pod2man --section=1 --center="Cower Manual" --name="COWER" --release="cower $(VERSION)" $< $@

strip: $(OUT)
	strip --strip-all $(OUT)

install: all
	install -D -m755 cower "$(DESTDIR)$(PREFIX)/bin/cower"
	install -D -m644 cower.1 "$(DESTDIR)$(MANPREFIX)/man1/cower.1"
	install -D -m644 bash_completion "$(DESTDIR)$(bash_completiondir)/cower"
	install -D -m644 zsh_completion "$(DESTDIR)$(PREFIX)/share/zsh/site-functions/_cower"
	install -D -m644 config "$(DESTDIR)$(PREFIX)/share/doc/cower/config"

uninstall:
	$(RM) "$(DESTDIR)$(PREFIX)/bin/cower" \
		"$(DESTDIR)$(MANPREFIX)/man1/cower.1" \
		"$(DESTDIR)$(bash_completiondir)/cower" \
		"$(DESTDIR)$(PREFIX)/share/zsh/site-functions/_cower" \
		"$(DESTDIR)$(PREFIX)/share/doc/cower/config"

dist: clean
	git archive --format=tar --prefix=$(OUT)-$(VERSION)/ HEAD | gzip -9 > $(OUT)-$(VERSION).tar.gz

clean:
	$(RM) $(OUT) $(OBJ) $(MANPAGES)

upload: dist
	gpg --detach-sign $(OUT)-$(VERSION).tar.gz
	scp $(OUT)-$(VERSION).tar.gz $(OUT)-$(VERSION).tar.gz.sig code.falconindy.com:archive/$(OUT)/

.PHONY: clean dist doc install uninstall

