#!/bin/bash

# Default IP
sed -i 's/192.168.1.1/192.168.1.2/g' package/base-files/files/bin/config_generate

# Remove version
sed -i 's/openwrt-23.05/openwrt-24.10/g' feeds.conf.default

# Add packages
git clone --single-branch --depth=1 https://github.com/ophub/luci-app-amlogic package/luci-app-amlogic
