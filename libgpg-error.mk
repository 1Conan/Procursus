ifneq ($(CHECKRA1N_MEMO),1)
$(error Use the main Makefile)
endif

LIBGPG-ERROR_VERSION := 1.37
DEB_LIBGPG-ERROR_V   ?= $(LIBGPG-ERROR_VERSION)

ifneq ($(wildcard $(BUILD_WORK)/libgpg-error/.build_complete),)
libgpg-error:
	@echo "Using previously built libgpg-error."
else
libgpg-error: setup
	$(SED) -i '/{"armv7-unknown-linux-gnueabihf"  },/a \ \ \ \ {"$(GNU_HOST_TRIPLE)"},' $(BUILD_WORK)/libgpg-error/src/mkheader.c
	cd $(BUILD_WORK)/libgpg-error && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr
	$(MAKE) -C $(BUILD_WORK)/libgpg-error
	$(FAKEROOT) $(MAKE) -C $(BUILD_WORK)/libgpg-error install \
		DESTDIR=$(BUILD_STAGE)/libgpg-error
	$(FAKEROOT) $(MAKE) -C $(BUILD_WORK)/libgpg-error install \
		DESTDIR=$(BUILD_BASE)	
	touch $(BUILD_WORK)/libgpg-error/.build_complete
endif

.PHONY: libgpg-error
