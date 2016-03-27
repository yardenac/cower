# cower - a simple AUR downloader

OUT        = cower

VERSION    = 16
VDEVEL     = $(shell test -d .git && git describe 2>/dev/null)

ifneq "$(VDEVEL)" ""
VERSION    = $(VDEVEL)
endif

PREFIX    ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man

BUILD      = release

warning_flags = \
	-Wclobbered \
	-Wempty-body \
	-Wfloat-equal \
	-Wignored-qualifiers \
	-Wmissing-declarations \
	-Wmissing-parameter-type \
	-Wsign-compare \
	-Wmissing-prototypes \
	-Wold-style-declaration \
	-Wtype-limits \
	-Woverride-init \
	-Wunused \
	-Wstrict-prototypes \
	-Wuninitialized

# build configurations
cflags.common  = $(warning_flags) -std=c99 -g -pthread -pedantic -Wall -Wextra -fstack-protector-strong

cflags.release = -O2

cflags.debug = -fvar-tracking-assignments -gdwarf-4

cflags.tsan = -fsanitize=thread
ldflags.tsan = -fsanitize=thread

cflags.asan = -fsanitize=address
ldflags.asan = -fsanitize=address

# global flag definitions
CPPFLAGS  := -D_GNU_SOURCE -DCOWER_VERSION=\"$(VERSION)\" $(CPPFLAGS)
CFLAGS    := $(cflags.common) $(cflags.$(BUILD)) $(CFLAGS)
LDFLAGS   := -pthread $(ldflags.$(BUILD)) $(LDFLAGS)
LDLIBS     = -lcurl -lalpm -lyajl -larchive -lcrypto

bash_completiondir = /usr/share/bash-completion/completions

# default target
all: $(OUT) doc

# object rules
OBJ=

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

# documentation
MANPAGES = \
	cower.1
doc: $(MANPAGES)
cower.1: README.pod
	pod2man --section=1 --center="Cower Manual" --name="COWER" --release="cower $(VERSION)" $< $@

# aux
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

