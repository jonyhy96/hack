# Ubuntu install socks5

------

### Environment
 - Ubuntu 18.04 
 - shadowsocks-local-linux64-1.1.5
 - cow 0.9.8

### Binary

[ss-local](uploads/e27a7926727b7dea460ae6c4d739c719/ss-local)

####  Download ss-local

ss-local
```
    rm -r /opt/shadowsocks/*
    wget ss-local
    mv ss-local /opt/shadowsocks/
    chmod +x ss-local
```

#### Use multiple server


```
    vi /opt/shadowsocks/config.json
```

config.json
```
{
	"local_port": 1080,
	"server_password": [
		["server1:port", "password", "method"],
		["server2:port", "password", "method"]
	]
}
```

#### Systemd

shadowsocks.service
```
[Unit]
Description=Shadowsocks
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
Restart=on-failure
ExecStart=/opt/shadowsocks/ss-local -c /opt/shadowsocks/config.json
WorkingDirectory=/opt/shadowsocks

[Install]
WantedBy=multi-user.target
```
```
    sudo vi /etc/systemd/system/shadowsocks.service
    systemctl daemon-reload
    service shadowsocks restart
```

:label: `Now，shadowsocks is available to use，the flowing document is about separate request which will use socks5`

#### Install cow

cow
```
    curl -L git.io/cow | bash
```

configure
```
    vi ~/.cow/rc
    // 将socks5://127.0.0.1:1080 所在行取消注释
```

Ubuntu proxy setting

| Type | Address | Port |
|:----:|:-------:|:----:|
| HTTP PROXY |  127.0.0.1 | 7777 |
| HTTPS PROXY | 127.0.0.1 | 7777 |
| Socks Host | 127.0.0.1 | 1080 |

:warning: 

### Problems

#### Ubuntu pac not working

Detail：

    
    
Solution：

    use cow
    
#### proxy won't work after reboot

Detail：

    proxy exception
    
Solution：

    start cow while boot
