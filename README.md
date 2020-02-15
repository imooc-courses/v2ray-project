
## config.json

主要生成三个参数：uuid   altid  path

uuid:
docker run --rm -it alpine cat /proc/sys/kernel/random/uuid

altid:
cat /dev/urandom | tr -dc '1-9' | head -c2

path:
cat /dev/urandom | tr -dc '1-9a-zA-Z' | head -c10


## nginx/conf.d/*.conf

path路径要对应上面
