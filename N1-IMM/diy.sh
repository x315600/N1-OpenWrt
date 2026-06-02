#!/bin/bash
# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b "$branch" --single-branch --filter=blob:none --sparse "$repourl"
  repodir=$(echo "$repourl" | awk -F '/' '{print $(NF)}')
  cd "$repodir" && git sparse-checkout set "$@"
  mv -f "$@" ../package
  cd .. && rm -rf "$repodir"
}

# Default IP
sed -i 's/192.168.1.1/192.168.2.2/g' package/base-files/files/bin/config_generate

# Add packages
# 添加科学上网源
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/openwrt-passwall-packages
git_sparse_clone main https://github.com/Openwrt-Passwall/openwrt-passwall luci-app-passwall
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash
git_sparse_clone main https://github.com/nikkinikki-org/OpenWrt-nikki luci-app-nikki nikki mihomo-meta mihomo-alpha

git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth=1 https://github.com/ophub/luci-app-amlogic package/amlogic
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/mosdns
git_sparse_clone main https://github.com/sbwml/luci-app-diskman luci-app-diskman
git clone --depth=1 https://github.com/tty228/luci-app-wechatpush package/luci-app-wechatpush
git_sparse_clone main https://github.com/sirpdboy/luci-app-taskplan luci-app-taskplan
git_sparse_clone main https://github.com/Lienol/openwrt-package luci-app-filebrowser

# luci-app-filemanager is part of upstream LuCI now; pull only the app subtree.
(
  git clone --depth=1 --filter=blob:none --sparse https://github.com/openwrt/luci package/luci-app-filemanager-src
  cd package/luci-app-filemanager-src || exit 1
  git sparse-checkout set applications/luci-app-filemanager
  mkdir -p ../luci-app-filemanager
  cp -a applications/luci-app-filemanager/. ../luci-app-filemanager/
)
rm -rf package/luci-app-filemanager-src

# 删除库中的插件，使用自定义源中的包。
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/utils/v2dat
