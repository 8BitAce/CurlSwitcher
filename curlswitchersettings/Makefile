GO_EASY_ON_ME=1
include theos/makefiles/common.mk

BUNDLE_NAME = curlswitchersettings
curlswitchersettings_FILES = curlswitchersettings.mm
curlswitchersettings_INSTALL_PATH = /Library/PreferenceBundles
curlswitchersettings_FRAMEWORKS = UIKit MessageUI QuartzCore Foundation CoreGraphics
curlswitchersettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/curlswitchersettings.plist$(ECHO_END)
