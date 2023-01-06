################################################################################
#
# new_stella
# difference to buildroot's stella package:
# - easy way to update stella without waiting for new buildroot release
# - installs stella.pro into root's home directory for stella to find
#
################################################################################

NEW_STELLA_VERSION = 6.7
NEW_STELLA_SOURCE = stella-$(NEW_STELLA_VERSION)-src.tar.xz
NEW_STELLA_SITE = https://github.com/stella-emu/stella/releases/download/$(NEW_STELLA_VERSION)
NEW_STELLA_LICENSE = GPL-2.0+
NEW_STELLA_LICENSE_FILES = Copyright.txt License.txt

NEW_STELLA_DEPENDENCIES = sdl2

NEW_STELLA_CONF_OPTS = \
	--host=$(GNU_TARGET_NAME) \
	--prefix=/usr \
	--with-sdl-prefix=$(STAGING_DIR)/usr

ifeq ($(BR2_PACKAGE_LIBPNG),y)
NEW_STELLA_CONF_OPTS += --enable-png
NEW_STELLA_DEPENDENCIES += libpng
else
NEW_STELLA_CONF_OPTS += --disable-png
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
NEW_STELLA_CONF_OPTS += --enable-zip
NEW_STELLA_DEPENDENCIES += zlib
else
NEW_STELLA_CONF_OPTS += --disable-zip
endif

# The configure script is not autoconf based, so we use the
# generic-package infrastructure
define NEW_STELLA_CONFIGURE_CMDS
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure $(NEW_STELLA_CONF_OPTS) \
	)
endef

define NEW_STELLA_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define NEW_STELLA_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) DESTDIR="$(TARGET_DIR)" -C $(@D) install
	$(INSTALL) -D -m 0644 $(@D)/src/emucore/stella.pro $(TARGET_DIR)/root/.config/stella/stella.pro
endef

$(eval $(generic-package))
