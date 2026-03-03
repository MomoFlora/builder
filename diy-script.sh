#!/bin/bash

# 移除要替换的包
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/{luci-app-argon-config,luci-app-dae,luci-app-daed,luci-app-dockerman,luci-app-homeproxy,luci-app-openclash,luci-app-passwall,luci-app-ramfree,luci-app-unblockneteasemusic,luci-app-vlmcsd,luci-app-vsftpd}
rm -rf feeds/packages/net/{open-app-filter,mosdns,vlmcsd,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}

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

./scripts/feeds update -a
./scripts/feeds install -a
