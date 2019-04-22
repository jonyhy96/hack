# lambda内发送Event超时

## Steps

1. 配置DNS:
```
sudo chmod +222 /etc/hosts && echo "`ip -4 addr show enp3s0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'`  host.docker.internal" >> /etc/hosts
```

2. 在docker-compose.local.yml中localstack添加挂载本地的hosts到容器中
```
    volumes:
	- /etc/hosts:/etc/hosts
```