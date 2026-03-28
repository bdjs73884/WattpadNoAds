include $(THEOS)/makefiles/common.mk
THEOS_DEPLOYMENT_TARGET = 26.0

THEOS_PACKAGE_SCHEME = rootless   # مهم جداً

TWEAK_NAME = WattpadNoAds
WattpadNoAds_FILES = Tweak.xm
WattpadNoAds_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-package::
	@echo "✅ تم بناء WattpadNoAds بنجاح!"
