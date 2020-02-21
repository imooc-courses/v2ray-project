#!/bin/bash
#**************************************************************
#Author:                     Linus
#QQ:                         100010
#Date:                       2020-02-20
#FileName:                   init2.0.sh
#URL:                        https://xyz.uscwifi.xyz
#Description:                Initialize the new server
#Copyright (C):              2020 Copyright ©  站点名称  版权所有
#************************************************************
DOMAIN_EXAMPLE='v2ray.v2ray.com'
UUID=$(cat /proc/sys/kernel/random/uuid)
ALTID=$(cat /dev/urandom | tr -dc '1-9' | head -c2)
path=$(cat /dev/urandom | tr -dc '1-9a-z' | head -c10)


StandardOutput(){
    echo -e "\033[1;32m$1\033[0m"
}
ErrorOutput(){
    echo -e "\033[1;31m$1 ... \033[0m"
}
GreenBGOutput(){
     echo -e "\033[42;37m$1\033[0m"
}
RedBGOutput(){
     echo -e "\033[41;37m$1\033[0m"
}


#check system
source /etc/os-release
check_system(){
    if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]];then
        GreenBGOutput "当前系统为 Centos ${VERSION_ID} ${VERSION} ${Font}"
        INS="yum"
    elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]];then
        GreenBGOutput "当前系统为 Debian ${VERSION_ID} ${VERSION} ${Font}"
        INS="apt"
        $INS update
        ## 添加 Nginx apt源
    elif [[ "${ID}" == "ubuntu" && `echo "${VERSION_ID}" | cut -d '.' -f1` -ge 16 ]];then
        GreenBGOutput "当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME} ${Font}"
        INS="apt"
        $INS update
    else
        RedBGOutput "当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内，安装中断 ${Font}"
        exit 1
    fi
}

#make sure only root can run our scripts
rootness(){
    if [[ $EUID -ne 0 ]]; then
        ErrorOutput "Error:This script must be run as root."
    exit 1
    fi
}

installSoftware(){
    if [[ -n `command -v docker` ]]; then
        StandardOutput "Docker is already installed,stop install..."
    else
        curl -fsSL get.docker.com | bash 
	sleep 3
    fi
    service docker restart
    systemctl enable docker

    if [[ -n `command -v docker-compose` ]]; then
        StandardOutput "Docker-compose is already installed,stop install..."
    else
        TAG_URL="https://api.github.com/repos/docker/compose/releases/latest"
	NEW_VER=`curl ${PROXY} -s ${TAG_URL} --connect-timeout 10| grep 'tag_name' | head -1 | cut -d\" -f4`
	curl -L "https://github.com/docker/compose/releases/download/${NEW_VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
    fi
} 
PortDetect(){
    if lsof -i :$1 &>/dev/null;then 
        ErrorOutput "Port $1 is in use..."
        exit 2
    fi
}

GenerateCert(){
    docker run --name acme -it -p 80:80 -v acme.sh:/acme.sh -d neilpang/acme.sh:latest ping 127.0.0.1 
    docker exec -it acme "acme.sh --issue --standalone  -d $1"
    if [ $? != 0 ];then
        ErrorOutput "Generate certificate failed... Please check..."
	docker rm -f acme
	exit 3
    fi
    StandardOutput "Generate certificate success..."
    docker rm -f acme
}

dependency_install(){
    ${INS} install wget git lsof curl unzip  -y    
}


main(){
    rootness
    check_system
    dependency_install
    installSoftware
    PortDetect
}
main



cd /opt && git clone https://github.com/imooc-courses/v2ray-project.git

read -p "请输入你的域名: " -e -i ${DOMAIN_EXAMPLE} DOMAIN
echo -e "你输入的域名是${GREEN} ${DOMAIN} ${END_COLOR}"

read -n1 -r -p "Press any key to continue..."

#测试域名是否解析成功
RealIP=$(curl -s ip.sb)
DOMAIN_IP=`ping -c1 ${DOMAIN} | sed '1{s/[^(]*(//;s/).*//;q}'`
if [[ "${RealIP}" == "${DOMAIN_IP}" ]];then
    StandardOutput "域名解析测试成功..."
else
    ErrorOutput "域名解析测试失败，是否继续？如果继续，生成证书可能失败..."
    read -n1 -r -p "你可以按下任意键继续...或者CTRL+C终止脚本..."
fi

#生成证书
GenerateCert "${DOMAIN}"


#拷贝证书
docker run --rm -it  -v acme.sh:/acme.sh  -v /opt/v2ray-project/nginx/ssl/:/backup   neilpang/acme.sh "cp -a /acme.sh/${DOMAIN}/fullchain.cer /backup/"
docker run --rm -it  -v acme.sh:/acme.sh  -v /opt/v2ray-project/nginx/ssl/:/backup   neilpang/acme.sh "cp -a /acme.sh/${DOMAIN}/${DOMAIN}.key /backup/"

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
sed -i "s@6f3d1f2c-6bc4-4a1f-a564-a3d10badf160@${UUID}@" 1.json
sed -i "/alterId/s@73@${ALTID}@" 1.json
sed -i "/path/s@fo3TrSb@${path}@" 1.json
vmess_link="vmess://$(cat 1.json | base64 -w 0)"
echo -e "${GREEN} ${vmess_link} ${END_COLOR}"

