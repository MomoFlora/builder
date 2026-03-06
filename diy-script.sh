#!/bin/bash

# 移除要替换的包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/{luci-app-argon-config,luci-app-dae,luci-app-daed,luci-app-dockerman,luci-app-homeproxy,luci-app-openclash,luci-app-passwall,luci-app-ramfree,luci-app-unblockneteasemusic,luci-app-vlmcsd,luci-app-vsftpd}
rm -rf feeds/packages/net/{open-app-filter,mosdns,vlmcsd,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}

# drop attendedsysupgrade
sed -i '/luci-app-attendedsysupgrade/d' \
    feeds/luci/collections/luci-nginx/Makefile \
    feeds/luci/collections/luci-ssl-openssl/Makefile \
    feeds/luci/collections/luci-ssl/Makefile \
    feeds/luci/collections/luci/Makefile

# fixed rust host build download llvm in ci error
sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile
grep -q -- '--ci false \\' feeds/packages/lang/rust/Makefile || sed -i '/x\.py \\/a \        --ci false \\' feeds/packages/lang/rust/Makefile

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# Custom firmware version and author metadata
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='ZeroWrt-$(date +%Y%m%d)'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By MomoFlora'/g" package/base-files/files/etc/openwrt_release
sed -i "s|^OPENWRT_RELEASE=\".*\"|OPENWRT_RELEASE=\"ZeroWrt 标准版 @R$(date +%Y%m%d) BY MomoFlora\"|" package/base-files/files/usr/lib/os-release

# default password
default_password=$(openssl passwd -5 password)
sed -i "s|^root:[^:]*:|root:${default_password}:|" package/base-files/files/etc/shadow

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# GO 1.26
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/Xiaokailnol/packages_lang_golang -b 26.x feeds/packages/lang/golang

# 雅典娜LED控制
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led

# openwrt_helloworld
git clone --depth=1 https://github.com/ZeroWrt/openwrt_helloworld package/new/helloworld

# openwrt_packages
git clone --depth=1 https://github.com/ZeroWrt/openwrt_packages package/openwrt_packages

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://github.com/MomoFlora/luci-app-dockerman -b openwrt-25.12 feeds/luci/applications/luci-app-dockerman
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
git clone https://github.com/MomoFlora/packages_utils_docker feeds/packages/utils/docker
git clone https://github.com/MomoFlora/packages_utils_dockerd feeds/packages/utils/dockerd
git clone https://github.com/MomoFlora/packages_utils_containerd feeds/packages/utils/containerd
git clone https://github.com/MomoFlora/packages_utils_runc feeds/packages/utils/runc

./scripts/feeds update -a
./scripts/feeds install -a
