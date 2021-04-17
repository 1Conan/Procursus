ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    	+= nghttp3
NGHTTP3_COMMIT  := 86eefc93c0a5c1850ccc768a6e0c56720816be5c
NGHTTP3_VERSION := 1.0.0+git20210414.$(shell echo $(NGHTTP3_COMMIT) | cut -c -7)
DEB_NGHTTP3_V   ?= $(NGHTTP3_VERSION)

nghttp3-setup: setup
	$(call GITHUB_ARCHIVE,ngtcp2,nghttp3,v$(NGHTTP3_COMMIT),$(NGHTTP3_COMMIT))
	$(call EXTRACT_TAR,nghttp3-v$(NGHTTP3_COMMIT).tar.gz,nghttp3-$(NGHTTP3_COMMIT),nghttp3)

ifneq ($(wildcard $(BUILD_WORK)/nghttp3/.build_complete),)
nghttp3:
	@echo "Using previously built nghttp3."
else
nghttp3: nghttp3-setup
	cd $(BUILD_WORK)/nghttp3 && autoreconf -i && ./configure \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/nghttp3
	+$(MAKE) -C $(BUILD_WORK)/nghttp3 install \
		DESTDIR="$(BUILD_STAGE)/nghttp3"
	+$(MAKE) -C $(BUILD_WORK)/nghttp3 install \
		DESTDIR="$(BUILD_BASE)"
	touch $(BUILD_WORK)/nghttp3/.build_complete
endif

nghttp3-package: nghttp3-stage
	# nghttp3.mk Package Structure
	rm -rf $(BUILD_DIST)/*nghttp3*/
	mkdir -p \
		$(BUILD_DIST)/libnghttp3-{0,dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# nghttp3.mk Prep libnghttp3-0
	cp -a $(BUILD_STAGE)/nghttp3/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libnghttp3.0.dylib $(BUILD_DIST)/libnghttp3-0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# nghttp3.mk Prep libnghttp3-dev
	cp -a $(BUILD_STAGE)/nghttp3/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/pkgconfig $(BUILD_DIST)/libnghttp3-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/nghttp3/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libnghttp3.{a,dylib} $(BUILD_DIST)/libnghttp3-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/nghttp3/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libnghttp3-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)


	# nghttp3.mk Sign
	$(call SIGN,libnghttp3-0,general.xml)

	# nghttp3.mk Make .debs
	$(call PACK,libnghttp3-0,DEB_NGHTTP3_V)
	$(call PACK,libnghttp3-dev,DEB_NGHTTP3_V)

	# nghttp3.mk Build cleanup
	rm -rf $(BUILD_DIST)/*nghttp3*/

.PHONY: nghttp3 nghttp3-package
