# SPDX-License-Identifier: GPL-2.0-only
#
# There is no downloads.openwrt.org target for meson/axg. Omit that
# URL so apk update uses only the shared aarch64_cortex-a53 feeds.

define FeedSourcesAppendAPK
( \
  $(strip $(if $(CONFIG_PER_FEED_REPO), \
	echo '%U/packages/%A/base/packages.adb'; \
	$(foreach feed,$(FEEDS_AVAILABLE), \
		$(if $(CONFIG_FEED_$(feed)), \
			echo '$(if $(filter m,$(CONFIG_FEED_$(feed))),# )%U/packages/%A/$(feed)/packages.adb';)))) \
) >> $(1)
endef
