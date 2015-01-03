TARGET_IPHONEOS_DEPLOYMENT_VERSION = 8.1
ARCHS = armv7 arm64
THEOS_BUILD_DIR = debs
DEBUG = 1
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = Isolate
Isolate_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += isolateprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 Messages; killall -9 backboardd"
