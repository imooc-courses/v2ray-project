## 食用方法

> 已经在阿里云临时服务器上测试可用，

**应该先部署docker环境和docker-compose**

```bash
docker version > /dev/null || curl -fsSL get.docker.com | bash 
service docker restart 
systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
```

### 一、克隆代码

克隆代码到/opt目录

```bash
yum install git -y || apt install git -y
cd /opt && git clone https://github.com/imooc-courses/v2ray-project.git
```

### 二、域名解析

比如daohang.v2ray.xyz解析到123.123.234.234

### 三、使用脚本初始化nginx,v2ray配置文件

文件在scripts/init.sh

```bash
# 按照提示输入上面解析的域名即可，脚本生成了uuid，altid，path，并替换nginx和v2ray配置文件中的相应数值
cd /opt/v2ray-project/scripts/ && bash init.sh
```

### 四、docker-compose部署

```bash
cd /opt/v2ray-project && docker-compose up -d
```

### 五、设置bbr加速

```bash
curl -sSL https://raw.githubusercontent.com/teddysun/across/master/bbr.sh | bash
reboot
```


