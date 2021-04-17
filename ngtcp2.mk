ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += ngtcp2
NGTCP2_COMMIT  := 169c68127b78ea906c96b49b9e18d4f805ab8eda
NGTCP2_VERSION := 1.0.0+git20210414.$(shell echo $(NGTCP2_COMMIT) | cut -c -7)
DEB_NGTCP2_V   ?= $(NGTCP2_VERSION)

ngtcp2-setup: setup
	$(call GITHUB_ARCHIVE,ngtcp2,ngtcp2,v$(NGTCP2_COMMIT),$(NGTCP2_COMMIT))
	$(call EXTRACT_TAR,ngtcp2-v$(NGTCP2_COMMIT).tar.gz,ngtcp2-$(NGTCP2_COMMIT),ngtcp2)

ifneq ($(wildcard $(BUILD_WORK)/ngtcp2/.build_complete),)
ngtcp2:
	@echo "Using previously built ngtcp2."
else
ngtcp2: ngtcp2-setup openssl libev libjemalloc
	cd $(BUILD_WORK)/ngtcp2 && autoreconf -i && ./configure \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--without-gnutls \
		CFLAGS="$(CFLAGS) -D__APPLE_USE_RFC_3542" \
		CXXFLAGS="$(CXXFLAGS) -D__APPLE_USE_RFC_3542"
	+$(MAKE) -C $(BUILD_WORK)/ngtcp2
	+$(MAKE) -C $(BUILD_WORK)/ngtcp2 install \
		DESTDIR="$(BUILD_STAGE)/ngtcp2"
	+$(MAKE) -C $(BUILD_WORK)/ngtcp2 install \
		DESTDIR="$(BUILD_BASE)"
	touch $(BUILD_WORK)/ngtcp2/.build_complete
endif

ngtcp2-package: ngtcp2-stage
	# ngtcp2.mk Package Structure
	rm -rf $(BUILD_DIST)/*ngtcp2*/
	mkdir -p \
		$(BUILD_DIST)/libngtcp2-{0,dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# ngtcp2.mk Prep libngtcp2-0
	cp -a $(BUILD_STAGE)/ngtcp2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libngtcp2{,_crypto_openssl}.0.dylib $(BUILD_DIST)/libngtcp2-0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# ngtcp2.mk Prep libngtcp2-dev
	cp -a $(BUILD_STAGE)/ngtcp2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/pkgconfig $(BUILD_DIST)/libngtcp2-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/ngtcp2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libngtcp2{,_crypto_openssl}.{dylib,a} $(BUILD_DIST)/libngtcp2-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/ngtcp2/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libngtcp2-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# ngtcp2.mk Sign
	$(call SIGN,libngtcp2-0,general.xml)

	# ngtcp2.mk Make .debs
	$(call PACK,libngtcp2-0,DEB_NGTCP2_V)
	$(call PACK,libngtcp2-dev,DEB_NGTCP2_V)

	# ngtcp2.mk Build cleanup
	rm -rf $(BUILD_DIST)/*ngtcp2*/

.PHONY: ngtcp2 ngtcp2-package
