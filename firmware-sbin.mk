ifneq ($(CHECKRA1N_MEMO),1)
$(error Use the main Makefile)
endif

FIRMWARE-SBIN_VERSION := 0-1
DEB_FIRMWARE-SBIN_V   ?= $(FIRMWARE-SBIN_VERSION)

ifneq ($(wildcard $(BUILD_STAGE)/firmware-sbin/.build_complete),)
firmware-sbin:
	@echo "Using previously built firmware-sbin."
else
firmware-sbin: setup
	mkdir -p $(BUILD_STAGE)/firmware-sbin/{sbin,usr/sbin}
	touch $(BUILD_STAGE)/firmware-sbin/{sbin/{fsck,fsck_apfs,fsck_exfat,fsck_hfs,fsck_msdos,launchd,mount,mount_apfs,newfs_apfs,newfs_hfs,pfctl},usr/sbin/{BTAvrcp,BTLEServer,BTMap,BTPbap,BlueTool,WirelessRadioManagerd,absd,addNetworkInterface,aslmanager,bluetoothd,cfprefsd,distnoted,filecoordinationd,ioreg,ipconfig,mDNSResponder,mDNSResponderHelper,mediaserverd,notifyd,nvram,pppd,racoon,rtadvd,scutil,spindump,syslogd,wifid,wirelessproxd}}
	touch $(BUILD_STAGE)/firmware-sbin/.build_complete
endif

firmware-sbin-package: firmware-sbin-stage
	# firmware-sbin.mk Package Structure
	rm -rf $(BUILD_DIST)/firmware-sbin
	mkdir -p $(BUILD_DIST)/firmware-sbin
	
	# firmware-sbin.mk Prep firmware-sbin
	$(FAKEROOT) cp -a $(BUILD_STAGE)/firmware-sbin/{sbin,usr} $(BUILD_DIST)/firmware-sbin
	
	# firmware-sbin.mk Make .debs
	$(call PACK,firmware-sbin,DEB_FIRMWARE-SBIN_V)
	
	# firmware-sbin.mk Build cleanup
	rm -rf $(BUILD_DIST)/firmware-sbin

.PHONY: firmware-sbin firmware-sbin-package
