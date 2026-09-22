#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY
#
# [S20L aurora 版]
# 本文件恢复了上游原版的 UPDATE_PACKAGE 函数体（补回 REPO_PATH），
# 修复 clone 落错目录导致 aurora 主题不被识别的问题。
# aurora / aurora-config 两行启用且【不带第 4 参数】，其余调用行全部注释。
# 已移除未被调用的 UPDATE_VERSION 函数，降低粘贴出错概率。

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local PKG_LIST=("$PKG_NAME" $5)
	local REPO_NAME=${PKG_REPO#*/}
	local REPO_PATH="./package/$REPO_NAME"

	echo " "

	# 删除本地可能存在的不同名称的软件包
	for NAME in "${PKG_LIST[@]}"; do
		echo "Search directory: $NAME"
		local FOUND_DIRS=$(find ./feeds/luci/ ./feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)

		if [ -n "$FOUND_DIRS" ]; then
			while read -r DIR; do
				rm -rf "$DIR"
				echo "Delete directory: $DIR"
			done <<< "$FOUND_DIRS"
		else
			echo "Not fonud directory: $NAME"
		fi
	done

	# 克隆 GitHub 仓库（目标为 ./package/，构建系统才能扫到）
	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git" $REPO_PATH

	# 仅"大杂烩仓库"需要 pkg 参数，单包仓库切勿加
	if [[ "$PKG_SPECIAL" == "pkg" ]]; then
		find $REPO_PATH/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./package \;
		rm -rf $REPO_PATH
	fi
}

# ============================================================
# 主题：aurora（本次启用）
#   clone 落到 ./package/luci-theme-aurora 与 ./package/luci-app-aurora-config
#   包名由目录名决定，与 Settings.sh 追加的配置项自动对齐
#   注意：这两行【不带】第 4 参数（pkg 会让包被 rm -rf 删除）
# ============================================================
UPDATE_PACKAGE "aurora" "eamonxg/luci-theme-aurora" "master"
UPDATE_PACKAGE "aurora-config" "eamonxg/luci-app-aurora-config" "master"

# ============================================================
# 以下全部注释
# ============================================================

# 备用主题
# UPDATE_PACKAGE "argon" "sbwml/luci-theme-argon" "openwrt-25.12"
# UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "master"
# UPDATE_PACKAGE "kucat-config" "sirpdboy/luci-app-kucat-config" "master"
# UPDATE_PACKAGE "noobwrt" "nooblk-98/luci-theme-noobwrt" "master"
# UPDATE_PACKAGE "shadcn" "eamonxg/luci-theme-shadcn" "main"
# UPDATE_PACKAGE "theme-fluent" "LazuliKao/luci-theme-fluent" "main"

# 代理类
# UPDATE_PACKAGE "momo" "nikkinikki-org/OpenWrt-momo" "main"
# UPDATE_PACKAGE "nikki" "nikkinikki-org/OpenWrt-nikki" "main"
# UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"
# UPDATE_PACKAGE "passwall" "Openwrt-Passwall/openwrt-passwall" "main" "pkg"
# UPDATE_PACKAGE "passwall2" "Openwrt-Passwall/openwrt-passwall2" "main" "pkg"

# 其他插件
# UPDATE_PACKAGE "diskmanager" "4IceG/luci-app-mini-diskmanager" "main"
# UPDATE_PACKAGE "easytier" "EasyTier/luci-app-easytier" "main"
# UPDATE_PACKAGE "qmodem" "FUjr/QModem" "main"
# UPDATE_PACKAGE "viking" "VIKINGYFY/packages" "main" "" "axonhub gecoosac sing-box luci-app-homeproxy luci-app-timewol luci-app-wolplus luci-app-wolultra"
# UPDATE_PACKAGE "vnt" "lmq8267/luci-app-vnt" "main"
# UPDATE_PACKAGE "diskman" "sbwml/luci-app-diskman" "main"
# UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5" "" "v2dat"
# UPDATE_PACKAGE "openlist2" "sbwml/luci-app-openlist2" "main"
# UPDATE_PACKAGE "qbittorrent" "sbwml/luci-app-qbittorrent" "master" "" "qt6base qt6tools rblibtorrent"
# UPDATE_PACKAGE "quickfile" "sbwml/luci-app-quickfile" "main"
# UPDATE_PACKAGE "ddns-go" "sirpdboy/luci-app-ddns-go" "main"
# UPDATE_PACKAGE "netspeedtest" "sirpdboy/netspeedtest" "main" "" "homebox ookla-speedtest"
# UPDATE_PACKAGE "netwizard" "sirpdboy/luci-app-netwizard" "main"
# UPDATE_PACKAGE "partexp" "sirpdboy/luci-app-partexp" "main"
# UPDATE_PACKAGE "timecontrol" "sirpdboy/luci-app-timecontrol" "main"

# NAT 穿透 / STUN
# UPDATE_PACKAGE "natmapt" "muink/openwrt-natmapt" "master"
# UPDATE_PACKAGE "stuntman" "muink/openwrt-stuntman" "master"
# UPDATE_PACKAGE "luci-app-natmapt" "muink/luci-app-natmapt" "master"

# 设备专用
# UPDATE_PACKAGE "airpi3000m-fancontrol" "LianXia233/luci-app-airpi3000m-fancontrol" "main"
# UPDATE_PACKAGE "chfs" "LianXia233/luci-app-chfs" "main"
# UPDATE_PACKAGE "fm350" "LianXia233/luci-app-fm350" "main"
# UPDATE_PACKAGE "h5000m-netmode" "LianXia233/luci-app-h5000m-netmode" "main"
# UPDATE_PACKAGE "mt5700" "LianXia233/luci-app-mt5700" "main"
# UPDATE_PACKAGE "mt5700m" "LianXia233/luci-app-mt5700m" "main"
# UPDATE_PACKAGE "netmonitor" "LianXia233/luci-app-netmonitor" "main"
# UPDATE_PACKAGE "qmodem-generic" "LianXia233/luci-app-qmodem-generic" "main"

#引入私有扩展脚本
if [ -f "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh" ]; then
	source "$GITHUB_WORKSPACE/Scripts/PRIVATE.sh"
fi
