# DOCKER-GHOST

Ubuntu: `16.04`  
NodeJS: `6.10.3`
GHOST: `0.11.9`  (支持升级)  

## 快速开始

> 国内主机可将 `idiswy/ghost:latest` 换成 `docker.wangyan.org/docker/ghost:latest`  
> 国内主机可增加`-e APT_MIRRORS=aliyun` 选项，使用国内的镜像源。 

```
docker run --restart=always --name ghost \
-v /opt/ghost:/opt/ghost \
-p 2368:2368 \
-p 80:80 \
-p 443:443 \
-e APT_MIRRORS=aliyun \
-d idiswy/ghost:latest
```
## Ghost 版本升级

```
docker exec -it ghost ghost-upgrade
```

注：请将 `ghost` 换成你容器的名称

## 文件路径

**nginx:**  `/etc/nginx/conf.d/default.conf`
**ghost:**  `/var/lib/ghost`、`/opt/ghost`

## 容器内操作命令

重启 nginx：`sv restart nginx`
重启 ghost: `pm2 restart ghost`