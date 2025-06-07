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

# 第一步：删除可能冲突的feeds包
echo "清理可能冲突的feeds包..."
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/themes/luci-theme-design
rm -rf feeds/luci/applications/luci-app-design-config
rm -rf feeds/packages/net/ddns-go
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/luci/applications/luci-app-serverchan
rm -rf feeds/luci/applications/luci-app-lucky
rm -rf feeds/luci/applications/luci-app-openclash

# 第二步：从small-package选择性提取需要的包
echo "从small-package选择性提取包..."
git clone --depth=1 https://github.com/kenzok8/small-package package/small

# 提取需要的包
if [ -d "package/small/luci-app-wechatpush" ]; then
    mv package/small/luci-app-wechatpush package/luci-app-wechatpush
fi

if [ -d "package/small/luci-app-openclash" ]; then
    mv package/small/luci-app-openclash package/luci-app-openclash-small
fi

# 可以根据需要添加更多包
# if [ -d "package/small/其他包名" ]; then
#     mv package/small/其他包名 package/其他包名
# fi

# 清理small包目录，避免冲突
rm -rf package/small

# 第三步：添加科学上网和其他必要包
echo "添加科学上网包..."
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall-packages
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/openwrt-passwall

# 第四步：添加主题和UI包
echo "添加主题和UI包..."
git clone -b 18.06 --single-branch --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone -b 18.06 --single-branch --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# 第五步：添加系统工具
echo "添加系统工具..."
git clone --depth=1 https://github.com/ophub/luci-app-amlogic package/amlogic
git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/ddnsgo
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/lucky

# 第六步：添加网络工具（使用更稳定的版本）
echo "添加网络工具..."
# 使用小包版本的OpenClash，如果上面没有成功提取，则使用官方版本
if [ ! -d "package/luci-app-openclash-small" ]; then
    git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash
fi

git clone -b v5-lua --single-branch --depth 1 https://github.com/sbwml/luci-app-mosdns package/mosdns

# 第七步：添加iStore相关
echo "添加iStore..."
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# 第八步：从其他源添加特定包
echo "添加其他特定包..."
git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-lucky

# 第九步：golang版本修复（重要！）
echo "修复golang版本..."
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# 第十步：系统配置修改
echo "修改系统配置..."
# 修改默认IP
sed -i 's/192.168.1.1/192.168.2.254/g' package/base-files/luci2/bin/config_generate
# 备用路径（根据OpenWrt版本不同）
if [ -f "package/base-files/files/bin/config_generate" ]; then
    sed -i 's/192.168.1.1/192.168.2.254/g' package/base-files/files/bin/config_generate
fi

# 修改默认时间格式
sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $(find ./package/*/autocore/files/ -type f -name "index.htm" 2>/dev/null || true)

echo "配置修复完成！"
echo "主要修改："
echo "1. 修复了missing small-package的问题"
echo "2. 添加了正确的包管理流程"
echo "3. 增加了错误检查和容错处理"
echo "4. 保持了版本兼容性控制"
