#  Copyright (C) 2019 Tobias Oetiker

AUTOMAKE_OPTIONS =  foreign

THIRDPARTY_DIR := $(shell pwd)

# THIRDPARTY_DIST := $(shell test -d cache && find cache -type f )
CPANSNAPV := cpanfile-$(shell $(PERL) -MConfig -e 'my $$v = $$Config{version}; $$v =~ s/\.\d+$$//; print $$v').snapshot


#EXTRA_DIST = $(THIRDPARTY_DIST) $(wildcard bin/cpanm)
EXTRA_DIST = $(wildcard cpanfile*snapshot)

all-local: $(CPANSNAPV)

bin/cpanm:
	$(AM_V_at)mkdir -p bin
	$(URL_CAT) https://cpanmin.us > bin/cpanm
	$(AM_V_at)chmod 755 bin/cpanm

$(CPANSNAPV): ../cpanfile bin/cpanm
	$(AM_V_at)echo "** Installing Dependencies using Carton install"
	test -f $(CPANSNAPV) && cp $(CPANSNAPV) ../cpanfile.snapshot || true
	test -x carton/bin/carton || PERL_CPANM_OPT= PERL_CPANM_HOME=$(THIRDPARTY_DIR) $(PERL) bin/cpanm -q --notest --local-lib-contained $(THIRDPARTY_DIR)/carton Carton Date::Parse
	PERL_CPANM_OPT= PERL_CPANM_HOME=$(THIRDPARTY_DIR) PERL5LIB=$(THIRDPARTY_DIR)/carton/lib/perl5 PERL_CARTON_PATH=$(THIRDPARTY_DIR) $(PERL) $(THIRDPARTY_DIR)/carton/bin/carton install  || ( cat build.log && exit 1 )
	mv ../cpanfile.snapshot $(CPANSNAPV)
	$(AM_V_at)touch touch

update: $(CPANSNAPV)
	$(AM_V_at)echo "** Updating Dependencies using Carton update"
	$(AM_V_at)cp $(CPANSNAPV) ../cpanfile.snapshot
	$(AM_V_at)PERL_CPANM_OPT= PERL_CPANM_HOME=$(THIRDPARTY_DIR) PERL5LIB=$(THIRDPARTY_DIR)/carton/lib/perl5 PERL_CARTON_PATH=$(THIRDPARTY_DIR) $(PERL) $(THIRDPARTY_DIR)/carton/bin/carton update
	$(AM_V_at)mv ../cpanfile.snapshot $(CPANSNAPV)

clean-local:
	ls -1 | grep -v Makefile | grep -v cpanfile |grep -v bin | xargs rm -rf

distclean-local:
	ls -1 | grep -v Makefile | grep -v cpanfile | xargs rm -rf

install-exec-hook:
	cp -fr lib/perl5/* $(DESTDIR)$(libdir)
