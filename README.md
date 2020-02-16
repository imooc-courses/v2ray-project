## 食用方法

> 已经在阿里云临时服务器上测试可用，

应该先部署docker环境和docker-compose

```bash
docker version > /dev/null || curl -fsSL get.docker.com | bash 
service docker restart 
systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
```

### 一、克隆代码

克隆代码到/opt目录

```bash
apt install git -y
cd /opt && git clone https://github.com/imooc-courses/v2ray-project.git
```

### 二、域名解析

比如autopiano.uscwifi.xyz解析到123.123.234.234

### 三、将证书放到nginx/ssl/目录下

```bash
[root@logstash v2ray-project]# ll nginx/ssl/
total 8
-rw-r--r-- 1 root root 3567 Feb 14 09:34 fullchain.cer
-rw-r--r-- 1 root root 1675 Feb 14 09:27 uscwifi.xyz.key
```

### 四、使用脚本初始化nginx,v2ray配置文件

文件在scripts/init.sh

```bash
# 按照提示输入上面解析的域名即可，脚本生成了uuid，altid，path，并替换nginx和v2ray配置文件中的相应数值
cd /opt/v2ray-project/scripts/ && bash init.sh
```

### 五、修改nginx配置文件

文件在nginx/conf.d

```bash
# 请手动修改证书和key文件的名字
ssl_certificate       /etc/nginx/ssl/fullchain.cer;
ssl_certificate_key   /etc/nginx/ssl/uscwifi.xyz.key;
```

### 六、docker-compose部署

```bash
cd /opt/v2ray-project && docker-compose up -d
```


