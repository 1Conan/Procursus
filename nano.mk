ifneq ($(CHECKRA1N_MEMO),1)
$(error Use the main Makefile)
endif

NANO_VERSION := 4.5
DEB_NANO_V   ?= $(NANO_VERSION)

ifneq ($(wildcard $(BUILD_WORK)/nano/.build_complete),)
nano:
	@echo "Using previously built nano."
else
nano: setup ncurses
	cd $(BUILD_WORK)/nano && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--disable-debug \
		--disable-dependency-tracking \
		--enable-color \
		--enable-extra \
		--enable-multibuffer \
		--enable-nanorc \
		NCURSESW_LIBS=$(BUILD_BASE)/usr/lib/libncursesw.dylib
	$(MAKE) -C $(BUILD_WORK)/nano
	$(FAKEROOT) $(MAKE) -C $(BUILD_WORK)/nano install \
		DESTDIR=$(BUILD_STAGE)/nano
	touch $(BUILD_WORK)/nano/.build_complete
endif

.PHONY: nano
