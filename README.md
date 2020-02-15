## 食用方法

应该先部署docker环境和docker-compose

```bash
docker version > /dev/null || curl -fsSL get.docker.com | bash 
service docker restart 
systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
```

### 一、克隆代码

克隆代码到/opt目录

### 二、域名解析

比如autopiano.uscwifi.xyz解析到123.123.234.234

### 三、将证书放到nginx/ssl/目录下

```bash
[root@logstash v2ray-project]# ll nginx/ssl/
total 8
-rw-r--r-- 1 root root 3567 Feb 14 09:34 fullchain.cer
-rw-r--r-- 1 root root 1675 Feb 14 09:27 uscwifi.xyz.key
```

### 四、修改config.json三个变量

文件在v2ray/config.json

```bash
# uuid
cat /proc/sys/kernel/random/uuid

# altid
cat /dev/urandom | tr -dc '1-9' | head -c2

#path
cat /dev/urandom | tr -dc '1-9a-zA-Z' | head -c10
```

### 五、修改nginx配置文件

文件在nginx/conf.d

```bash
# 修改域名和path及证书名称即可
```

### 六、docker-compose部署

```bash
cd /opt/v2ray-project && docker-compose up -d
```


