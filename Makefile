# Makefile for mktheinit

VERSION = $(shell if test -f VERSION; then cat VERSION; else git describe | sed 's/-/./g;s/^v//;'; fi)

DIRS = \
	/usr/bin \
	/usr/share/bash-completion/completions \
	/usr/share/zsh/site-functions \
	/etc/theinit.d \
	/etc/theinit/hooks \
	/etc/theinit/install \
	/usr/lib/theinit/hooks \
	/usr/lib/theinit/install \
	/usr/lib/theinit/udev \
	/usr/lib/kernel/install.d \
	/usr/share/man/man8 \
	/usr/share/man/man5 \
	/usr/share/man/man1 \
	/usr/share/theinit \
	/usr/lib/tmpfiles.d

BASH_SCRIPTS = \
	mktheinit \
	lsinitcpio

ALL_SCRIPTS=$(shell grep -rIzlE '^#! ?/.+(ba|d|k)?sh' --exclude-dir=".git" ./)

all: install

MANPAGES = \
	man/mktheinit.8 \
	man/theinit.conf.5 \
	man/lsinitcpio.1

install: all
	install -dm755 $(addprefix $(DESTDIR),$(DIRS))

	sed -e 's|\(^_f_config\)=.*|\1=/etc/theinit.conf|' \
	    -e 's|\(^_f_functions\)=.*|\1=/usr/lib/theinit/functions|' \
	    -e 's|\(^_d_hooks\)=.*|\1=/etc/theinit/hooks:/usr/lib/theinit/hooks|' \
	    -e 's|\(^_d_install\)=.*|\1=/etc/theinit/install:/usr/lib/theinit/install|' \
	    -e 's|\(^_d_presets\)=.*|\1=/etc/theinit.d|' \
	    -e 's|%VERSION%|$(VERSION)|g' \
	    < mktheinit > $(DESTDIR)/usr/bin/mktheinit

	sed -e 's|\(^_f_functions\)=.*|\1=/usr/lib/theinit/functions|' \
	    -e 's|%VERSION%|$(VERSION)|g' \
	    < lsinitcpio > $(DESTDIR)/usr/bin/lsinitcpio

	chmod 755 $(DESTDIR)/usr/bin/lsinitcpio $(DESTDIR)/usr/bin/mktheinit

	install -m644 theinit.conf $(DESTDIR)/etc/theinit.conf
	install -m755 -t $(DESTDIR)/usr/lib/theinit init shutdown
	install -m644 -t $(DESTDIR)/usr/lib/theinit init_functions functions
	cp -ar udev $(DESTDIR)/usr/lib/theinit/

	cp -art $(DESTDIR)/usr/lib/theinit hooks install
	install -m644 -t $(DESTDIR)/usr/share/theinit theinit.d/*
	install -m644 tmpfiles/theinit.conf $(DESTDIR)/usr/lib/tmpfiles.d/theinit.conf

	# install -m644 man/mktheinit.8 $(DESTDIR)/usr/share/man/man8/mktheinit.8
	# install -m644 man/theinit.conf.5 $(DESTDIR)/usr/share/man/man5/theinit.conf.5
	# install -m644 man/lsinitcpio.1 $(DESTDIR)/usr/share/man/man1/lsinitcpio.1
	install -m644 shell/bash-completion $(DESTDIR)/usr/share/bash-completion/completions/mktheinit
	# ln -s mktheinit $(DESTDIR)/usr/share/bash-completion/completions/lsinitcpio
	install -m644 shell/zsh-completion $(DESTDIR)/usr/share/zsh/site-functions/_mktheinit

# doc: $(MANPAGES)
# man/%: man/%.txt Makefile
# 	a2x -d manpage \
# 		-f manpage \
# 		-a manversion="mktheinit $(VERSION)" \
# 		-a manmanual="mktheinit manual" $<

check:
	@r=0; for t in test/test_*; do $$t || { echo $$t fail; r=1; }; done; exit $$r
	@r=0; for s in $(BASH_SCRIPTS); do bash -O extglob -n $$s || r=1; done; exit $$r

shellcheck:
	shellcheck -W 99 --color $(ALL_SCRIPTS)

clean:
	$(RM) mktheinit-$(VERSION).tar.gz.sig mktheinit-$(VERSION).tar.gz $(MANPAGES)

dist: doc mktheinit-$(VERSION).tar.gz
mktheinit-$(VERSION).tar.gz:
	echo $(VERSION) > VERSION
	git archive --format=tar --prefix=mktheinit-$(VERSION)/ -o mktheinit-$(VERSION).tar HEAD
	bsdtar -rf mktheinit-$(VERSION).tar -s ,^,mktheinit-$(VERSION)/, $(MANPAGES) VERSION
	gzip -9 mktheinit-$(VERSION).tar
	$(RM) VERSION

mktheinit-$(VERSION).tar.gz.sig: mktheinit-$(VERSION).tar.gz
	gpg --detach-sign $<

upload: mktheinit-$(VERSION).tar.gz mktheinit-$(VERSION).tar.gz.sig
	scp $^ repos.archlinux.org:/srv/ftp/other/mktheinit

version:
	@echo $(VERSION)

.PHONY: clean dist install shellcheck tarball version
