# cower - a simple AUR downloader

OUT        = cower
VERSION    = $(shell git describe)

SRC        = ${wildcard *.c}
OBJ        = ${SRC:.c=.o}
DISTFILES  = Makefile README.pod bash_completion zsh_completion config cower.c

PREFIX    ?= /usr/local
MANPREFIX ?= ${PREFIX}/share/man

CPPFLAGS  := -DCOWER_VERSION=\"${VERSION}\" ${CPPFLAGS}
CFLAGS    := -std=c99 -g -pedantic -Wall -Wextra -pthread ${CFLAGS}
LDFLAGS   := -lcurl -lalpm -lyajl -larchive -lcrypto -pthread ${LDFLAGS}

all: ${OUT} doc

${OUT}: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

doc: cower.1
cower.1: README.pod
	pod2man --section=1 --center="Cower Manual" --name="COWER" --release="cower ${VERSION}" $< > $@

strip: ${OUT}
	strip --strip-all ${OUT}

install: cower cower.1
	install -D -m755 cower ${DESTDIR}${PREFIX}/bin/cower
	install -D -m644 cower.1 ${DESTDIR}${MANPREFIX}/man1/cower.1
	install -D -m644 bash_completion ${DESTDIR}/usr/share/bash-completion/completions/cower
	install -D -m644 zsh_completion ${DESTDIR}${PREFIX}/share/zsh/site-functions/_cower
	install -D -m644 config ${DESTDIR}${PREFIX}/share/doc/cower/config

uninstall:
	@echo removing executable file from ${DESTDIR}${PREFIX}/bin
	rm -f ${DESTDIR}${PREFIX}/bin/cower
	@echo removing man page from ${DESTDIR}${MANPREFIX}/man1/cower.1
	rm -f ${DESTDIR}/${MANPREFIX}/man1/cower.1
	@echo removing bash completion
	rm -f ${DESTDIR}/etc/bash_completion.d/cower
	@echo removing zsh completion
	rm -f ${DESTDIR}${PREFIX}/share/zsh/site-functions/_cower
	@echo removing sample config
	rm -f ${DESTDIR}${PREFIX}/share/cower/config

dist: clean
	mkdir cower-${VERSION}
	cp ${DISTFILES} cower-${VERSION}
	sed "s/\(^VERSION *\)= .*/\1= ${VERSION}/" Makefile > cower-${VERSION}/Makefile
	tar czf cower-${VERSION}.tar.gz cower-${VERSION}
	rm -rf cower-${VERSION}

distcheck: dist
	tar xf cower-${VERSION}.tar.gz
	${MAKE} -C cower-${VERSION}
	rm -rf cower-${VERSION}

clean:
	${RM} ${OUT} ${OBJ} cower.1

.PHONY: clean dist doc install uninstall

