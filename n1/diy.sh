#!/bin/bash

# Default IP
sed -i 's/192.168.1.1/192.168.1.2/g' package/base-files/files/bin/config_generate

# Git sparse clone
function git_sparse_clone() {
    branch="$1" repourl="$2" && shift 2
    git clone --single-branch --depth=1 -b $branch --filter=blob:none --sparse $repourl
    repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
    cd $repodir && git sparse-checkout set $@
    mv -f $@ ../package
    cd .. && rm -rf $repodir
}

# Add packages
git clone --single-branch --depth=1 https://github.com/ophub/luci-app-amlogic package/luci-app-amlogic
git_sparse_clone master https://github.com/immortalwrt/packages net/rsync utils/docker-compose utils/sshpass utils/zstd