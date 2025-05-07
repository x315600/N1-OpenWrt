#!/bin/bash

# Git稀疏克隆，只克隆指定目录到本地

function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Add packages

#添加科学上网源

git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall-packages
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/openwrt-passwall
git clone -b 18.06 --single-branch --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone -b 18.06 --single-branch --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth=1 https://github.com/ophub/luci-app-amlogic package/amlogic
git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddnsgo
#git clone --depth=1 https://github.com/sirpdboy/luci-app-lucky package/lucky
git clone --depth=1  https://github.com/gdy666/luci-app-lucky.git package/lucky
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash
git clone -b v5-lua --single-branch --depth 1 https://github.com/sbwml/luci-app-mosdns package/mosdns


# iStore

git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci
#添加自定义的软件包源
git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-theme-edge
git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-lucky
Remove packages
#删除冲突插件
#rm -rf $(find ./feeds/packages/net/ -type d -regex ".*\(dns2socks\|geoview\|ipt2socks\|microsocks\|naiveproxy\|shadowsocks-rust\|shadowsocksr-libev\|shadowsocks-libev\|simple-obfs\|tcping\|tuic-client\|v2ray-plugin\|xray-plugin\).*")

#rm -rf $(find ./feeds/luci/ -type d -regex ".*\(passwall\|openclash\|alist\|easymesh\|adguardhome\|lucky\|wechatpush\|ddns-go\|ssr-plus\).*")




#删除lean库中的插件，使用自定义源中的包。
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/luci/applications/luci-app-mosdns
#rm -rf feeds/luci/themes/luci-theme-design
#rm -rf feeds/luci/applications/luci-app-design-config

# Default IP

sed -i 's/192.168.1.1/192.168.2.2/g' package/base-files/files/bin/config_generate

#修改默认时间格式
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $(find ./package/*/autocore/files/ -type f -name "index.htm")
