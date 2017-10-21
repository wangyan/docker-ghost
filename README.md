# DOCKER-GHOST

Ubuntu: `16.04`  
NodeJS: `6.11.4`
GHOST: `1.1.3`

## 快速开始

> 国内主机可将 `idiswy/ghost:latest` 换成 `docker.wangyan.org/docker/ghost:latest`  
> 国内主机可增加`-e APT_MIRRORS=aliyun` 选项，使用国内的镜像源。 
> 增加`-e MAIL=smtp` 选项，初始化邮件服务。   

```
docker run --restart=always --name ghost \
-v /opt/ghost:/opt/ghost \
-p 2368:2368 \
-p 80:80 \
-p 443:443 \
-d idiswy/ghost:latest
```
## Ghost 版本升级

```
docker exec -it ghost ghost update
```

注：请将 `ghost` 换成你容器的名称

## 文件路径

**nginx:**  `/etc/nginx/conf.d/default.conf`
**ghost:**  `/var/lib/ghost`、`/opt/ghost`

## 容器内操作命令

重启 nginx：`sv restart nginx`
重启 ghost: `pm2 restart ghost`