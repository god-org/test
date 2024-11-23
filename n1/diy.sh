#!/bin/bash

# Default IP
sed -i 's/192.168.1.1/192.168.1.2/g' package/base-files/files/bin/config_generate

# Git sparse clone
git_sparse_clone() {
    branch="$1" repourl="$2" && shift 2
    git clone --depth=1 -b "$branch" --single-branch --filter=blob:none --sparse "$repourl" tmp_package
    cd tmp_package && git sparse-checkout set "$@"
    mv -f "$@" ../package
    cd .. && rm -rf tmp_package
}

# Add packages
git clone --single-branch --depth=1 https://github.com/ophub/luci-app-amlogic package/luci-app-amlogic
git_sparse_clone master https://github.com/immortalwrt/packages net/rsync utils/zstd
rm -rf feeds/packages/net/rsync feeds/packages/utils/zstd
