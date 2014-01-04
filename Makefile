GO_EASY_ON_ME = 1
include theos/makefiles/common.mk

TWEAK_NAME = CurlSwitcher
CurlSwitcher_FILES = CurlSwitcher.m CSSettings.m Tweak.xm
CurlSwitcher_FRAMEWORKS = QuartzCore UIKit Foundation CoreGraphics
CurlSwitcher_LDFLAGS += -L. -lactivator

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += curlswitchersettings
include $(THEOS_MAKE_PATH)/aggregate.mk
