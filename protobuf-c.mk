ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS        += protobuf-c
PROTOBUF-C_VERSION := 1.3.3
DEB_PROTOBUF-C_V   ?= $(PROTOBUF-C_VERSION)

protobuf-c-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) \
		https://github.com/protobuf-c/protobuf-c/releases/download/v$(PROTOBUF-C_VERSION)/protobuf-c-$(PROTOBUF-C_VERSION).tar.gz
	$(call EXTRACT_TAR,protobuf-c-$(PROTOBUF-C_VERSION).tar.gz,protobuf-c-$(PROTOBUF-C_VERSION),protobuf-c)

ifneq ($(wildcard $(BUILD_WORK)/protobuf-c/.build_complete),)
protobuf-c:
	@echo "Using previously built protobuf-c."
else
protobuf-c: protobuf-c-setup libprotobuf
	cd $(BUILD_WORK)/protobuf-c && ./configure \
		$(DEFAULT_CONFIGURE_FLAGS)

	+$(MAKE) -C $(BUILD_WORK)/protobuf-c
	+$(MAKE) -C $(BUILD_WORK)/protobuf-c install \
		DESTDIR="$(BUILD_STAGE)/protobuf-c"
	+$(MAKE) -C $(BUILD_WORK)/protobuf-c install \
		DESTDIR="$(BUILD_BASE)"

	touch $(BUILD_WORK)/protobuf-c/.build_complete
endif

protobuf-c-package: protobuf-c-stage
	# protobuf-c.mk Package Structure
	rm -rf \
		$(BUILD_DIST)/libprotobuf-c{1,-dev} \
		$(BUILD_DIST)/protobuf-c-compiler
	mkdir -p \
		$(BUILD_DIST)/libprotobuf-c{1,-dev}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
		$(BUILD_DIST)/protobuf-c-compiler/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)

	# protobuf-c.mk Prep libprotobuf-c1
	cp -a $(BUILD_STAGE)/protobuf-c/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libprotobuf-c.1.dylib $(BUILD_DIST)/libprotobuf-c1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# protobuf-c.mk Prep libprotobuf-c-dev
	cp -a $(BUILD_STAGE)/protobuf-c/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libprotobuf-c-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	cp -a $(BUILD_STAGE)/protobuf-c/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libprotobuf-c.{dylib,a} $(BUILD_DIST)/libprotobuf-c-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/protobuf-c/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/pkgconfig $(BUILD_DIST)/libprotobuf-c-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# protobuf-c.mk Prep protobuf-c-compiler
	cp -a $(BUILD_STAGE)/protobuf-c/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin $(BUILD_DIST)/protobuf-c-compiler/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)


	# protobuf-c.mk Sign
	$(call SIGN,libprotobuf-c1,general.xml)
	$(call SIGN,protobuf-c-compiler,general.xml)

	# protobuf-c.mk Make .debs
	$(call PACK,libprotobuf-c1,DEB_PROTOBUF-C_V)
	$(call PACK,libprotobuf-c-dev,DEB_PROTOBUF-C_V)
	$(call PACK,protobuf-c-compiler,DEB_PROTOBUF-C_V)

	# protobuf-c.mk Build cleanup
	rm -rf \
		$(BUILD_DIST)/libprotobuf-c{1,-dev} \
		$(BUILD_DIST)/protobuf-c-compiler

.PHONY: protobuf-c protobuf-c-package
