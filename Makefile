include $(THEOS)/makefiles/common.mk
export TARGET = iphone:clang:latest:26.0
SDKVERSION = 26.0
TARGET_OS_DEPLOYMENT_VERSION = 26.0

THEOS_PACKAGE_SCHEME = rootless   # مهم جداً

TWEAK_NAME = WattpadNoAds
WattpadNoAds_FILES = Tweak.xm
WattpadNoAds_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-package::
	@echo "✅ تم بناء WattpadNoAds بنجاح!"
