# SPDX-License-Identifier: GPL-2.0-only
#
# There is no downloads.openwrt.org target for meson/axg. Keep the shared
# aarch64_cortex-a53 feeds, and serve kmods from the GitHub Pages tree
# published by .github/workflows/hubitat-c7-publish.yml. The version directory
# is the kernel this image was built with, so apk will only install matching
# modules.

define FeedSourcesAppendAPK
( \
  echo 'https://inindev.github.io/openwrt/targets/meson/axg/kmods/$(LINUX_VERSION)-$(LINUX_RELEASE)-$(LINUX_VERMAGIC)/packages.adb'; \
  $(strip $(if $(CONFIG_PER_FEED_REPO), \
	echo '%U/packages/%A/base/packages.adb'; \
	$(foreach feed,$(FEEDS_AVAILABLE), \
		$(if $(CONFIG_FEED_$(feed)), \
			echo '$(if $(filter m,$(CONFIG_FEED_$(feed))),# )%U/packages/%A/$(feed)/packages.adb';)))) \
) >> $(1)
endef
