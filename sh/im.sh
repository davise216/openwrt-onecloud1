#!/bin/bash

function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../
  cd .. && rm -rf $repodir
}

git_sparse_clone main https://github.com/shiyu1314/openwrt-onecloud device

cp -r device/* ./
rm -rf device

git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash

git_sparse_clone master https://github.com/kenzok8/openwrt-packages luci-app-adguardhome

echo "config AdGuardHome 'AdGuardHome'
	option enabled '0'
	option httpport '3000'
	option redirect 'none'
	option configpath '/etc/AdGuardHome.yaml'
	option workdir '/etc/AdGuardHome'
	option logfile '/tmp/AdGuardHome.log'
	option verbose '0'
	option binpath '/usr/bin/AdGuardHome/AdGuardHome'
	option upxflag ''">luci-app-adguardhome/root/etc/config/AdGuardHome

mv -f luci-app-openclash package

mv -f luci-app-adguardhome package

echo 'src-git dns https://github.com/sbwml/luci-app-mosdns' >>feeds.conf.default


./scripts/feeds update -a
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/adguardhome
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf package/emortal/default-settings

./scripts/feeds update -a
./scripts/feeds install -a

sed -i "s/192.168.1.1/192.168.2.2/" package/base-files/files/bin/config_generate
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

sudo rm -rf package/base-files/files/etc/banner

sed -i "s/%D %V %C/%D $(TZ=UTC-8 date +%Y.%m.%d)/" package/base-files/files/etc/openwrt_release

sed -i "s/%R/by shiyu1314/" package/base-files/files/etc/openwrt_release


date=$(date +"%Y-%m-%d")
echo "                                                    " >> package/base-files/files/etc/banner
echo ".___                               __         .__" >> package/base-files/files/etc/banner
echo "|   | _____   _____   ____________/  |______  |  |" >> package/base-files/files/etc/banner
echo "|   |/     \ /     \ /  _ \_  __ \   __\__  \ |  |" >> package/base-files/files/etc/banner
echo "|   |  Y Y  \  Y Y  (  <_> )  | \/|  |  / __ \|  |__" >> package/base-files/files/etc/banner
echo "|___|__|_|  /__|_|  /\____/|__|   |__| (____  /____/" >> package/base-files/files/etc/banner
echo "          \/      \/                        \/      " >> package/base-files/files/etc/banner
echo " -----------------------------------------------------" >> package/base-files/files/etc/banner
echo "         %D ${date} by shiyu1314                     " >> package/base-files/files/etc/banner
echo " -----------------------------------------------------" >> package/base-files/files/etc/banner
echo "                                                      " >> package/base-files/files/etc/banner
