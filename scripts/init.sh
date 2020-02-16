#!/bin/bash
#**************************************************************
#Author:                     Linus
#QQ:                         100010
#Date:                       2020-02-16
#FileName:                   1.sh
#Description:                Init configure files.
#Copyright (C):              2020 Copyright ©  站点名称  版权所有
#************************************************************
GREEN="\033[1;32m"
RED="\033[1;31m"
END_COLOR="\033[0m"

DOMAIN_EXAMPLE='v2ray.v2ray.com'
UUID=$(cat /proc/sys/kernel/random/uuid)
ALTID=$(cat /dev/urandom | tr -dc '1-9' | head -c2)
path=$(cat /dev/urandom | tr -dc '1-9a-z' | head -c10)

read -p "请输入你的域名: " -e -i ${DOMAIN_EXAMPLE} DOMAIN
echo -e "你输入的域名是${GREEN} ${DOMAIN} ${END_COLOR}"

read -n1 -r -p "Press any key to continue..."

#仅仅是为了输出内容好看点
echo "正在生成UUID..."
sleep 3
echo -e "UUID生成成功: ${GREEN} ${UUID} ${END_COLOR}"
echo "正在生成ALTID..."
sleep 3
echo -e "ALTID生成成功: ${GREEN} ${ALTID} ${END_COLOR}"
echo "正在生成path变量..."
sleep 3
echo -e "path变量生成成功: ${GREEN} ${path} ${END_COLOR}"

#生成nginx配置文件
echo "正在生成nginx配置文件..."
mv ../nginx/conf.d/v2ray.v2ray.com.conf ../nginx/conf.d/${DOMAIN}.conf
sed -i "s/v2ray.v2ray.com/${DOMAIN}/g" ../nginx/conf.d/${DOMAIN}.conf
sed -i "s/fo3TrSb/${path}/g" ../nginx/conf.d/${DOMAIN}.conf
sleep 3
echo -e "生成nginx配置文件完成: ${GREEN} nginx/conf.d/${DOMAIN}.conf ${END_COLOR}"

#生成v2ray配置文件
echo "正在生成v2ray配置文件..."
sed -i "s@6f3d1f2c-6bc4-4a1f-a564-a3d10badf160@${UUID}@" ../v2ray/config.json
sed -i "/alterId/s@73@${ALTID}@" ../v2ray/config.json
sed -i "/path/s@fo3TrSb@${path}@" ../v2ray/config.json
sleep 3
echo -e "生成v2ray配置文件完成: ${GREEN} v2ray/config.json ${END_COLOR}"

#打印vmess链接
echo "打印vmess链接..."
sed -i "s@v2ray.v2ray.com@${DOMAIN}@" 1.json
sed -i "s@6f3d1f2c-6bc4-4a1f-a564-a3d10badf160@{UUID}@" 1.json
sed -i "/alterId/s@73@${ALTID}@" 1.json
sed -i "/path/s@fo3TrSb@${path}@" 1.json
vmess_link="vmess://$(cat 1.json | base64 -w 0)"
echo -e "${GREEN} ${vmess_link} ${END_COLOR}"
