# Gitlab 搭建全过程

### 环境：

 > * centos 7.2
 > * docker 1.13.1
 > * docker-compose 1.23.2
 > * pip 19.0.3
 > * certbot 0.30.2

### 搭建过程：

1,建立挂载文件夹

```
/srv
├── gitlab
│   ├── config
│   ├── data
│   └── logs
└── gitlab-runner
```

2,生成Let’s Encrypt 证书

```
$ yum -y install nginx

$ service nginx start

$ sudo certbot --nginx certonly

$ cp /etc/letsencrypt/live/{DOMAIN}/privkey.pem ./privkey.pem # 密钥

$ cp /etc/letsencrypt/live/{DOMAIN}/fullchain.pem ./fullchain.pem # 证书

$ service nginx stop

$ yum remove -y nginx
```


3,编写docker-compose.yml

```yaml
version: "3.5"

services:
  gitlab:
    container_name: gitlab
    image: "gitlab/gitlab-ce:latest"
    restart: always
    hostname: "{DOMAIN}"
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url "https://{DOMAIN}"	  # Must use https protocol
        gitlab_rails['gitlab_shell_ssh_port'] = 20222
        nginx['redirect_http_to_https'] = true
        nginx['ssl_certificate']= "/etc/letsencrypt/live/{DOMAIN}/fullchain.pem"
        nginx['ssl_certificate_key'] = "/etc/letsencrypt/live/{DOMAIN}/privkey.pem"  
        gitlab_rails['initial_root_password'] = "***********" # root 帐号的密码
        nginx['custom_gitlab_server_config']="allow 127.0.0.1;\n deny all;\n location ~ /.well-known { \n allow all; \n }"
        letsencrypt['contact_emails'] = ['email'] 
        letsencrypt['enable'] = true                      # GitLab 10.5 and 10.6 require this option
        letsencrypt['key_size'] = 2048
        letsencrypt['owner'] = 'root'
        letsencrypt['wwwroot'] = '/var/opt/gitlab/nginx/www'
        letsencrypt['auto_renew'] = true # 证书自更新配置
        letsencrypt['auto_renew_hour'] = "12"
        letsencrypt['auto_renew_minute'] = "30"
        letsencrypt['auto_renew_day_of_month'] = "*/7"
        unicorn['enable'] = true
        unicorn['worker_timeout'] = 60
        unicorn['worker_processes'] = 4 # 工作进程数 官方推荐CPU个数 + 1 
        unicorn['worker_memory_limit_min'] = "200 * 1 << 20" #内存最低值200m
        unicorn['worker_memory_limit_max'] = "400 * 1 << 20" #内存最大值400m
        sidekiq['concurrency'] = 16
        postgresql['shared_buffers'] = "256MB" # 数据库共享内存大小
        postgresql['max_worker_processes'] = 8

    ports:
      - "80:80"
      - "443:443"
      - "20222:22"
    volumes:
      - "/srv/gitlab/config:/etc/gitlab"
      - "/srv/gitlab/logs:/var/log/gitlab"
      - "/srv/gitlab/data:/var/opt/gitlab"
      - "./fullchain.pem:/etc/letsencrypt/live/{DOMAIN}/fullchain.pem"
      - "./privkey.pem:/etc/letsencrypt/live/{DOMAIN}/privkey.pem"
```

4,运行gitlab-runner

```
$ mkdir -p /srv/gitlab-runner/config

$ docker run -d --name gitlab-runner-test --restart always \
   -v /srv/gitlab-runner/config:/etc/gitlab-runner \
   -v /var/run/docker.sock:/var/run/docker.sock \
   {REGISTRY_DOMAIN}/ci/gitlab-ci

$ gitlab-runner register -n \
   --url https://{DOMAIN}/ \
   --registration-token TOKEN \
   --executor docker \
   --description "test runner" \
   --docker-image "docker:stable" \
   --docker-volumes /var/run/docker.sock:/var/run/docker.sock  \
   --docker-privileged
```

----

### 遇到问题：

#### gitlab 占用内存过大

问题详情：
```
$ free -mh
              total        used        free      shared  buff/cache   available
Mem:           7.6G        3.3G        928M         33M        3.4G        4.0G
Swap:            0B          0B          0B
```

解决办法：

```
unicorn['enable'] = true
unicorn['worker_timeout'] = 60
unicorn['worker_processes'] = 4 # 工作进程数 官方推荐CPU个数 + 1 
unicorn['worker_memory_limit_min'] = "200 * 1 << 20" #内存最低值200m
unicorn['worker_memory_limit_max'] = "400 * 1 << 20" #内存最大值400m
sidekiq['concurrency'] = 16
postgresql['shared_buffers'] = "256MB" # 数据库共享内存大小
postgresql['max_worker_processes'] = 8
```

#### gitlab-ci 无法运行docker命令

问题详情：

    gitlab-ci runner内没有docker命令，在.gitlab-ci.yml中写docker info会报 docker: command not found      异常。
    由于我们的ci是用docker跑的，只有在ci中做docker in docker才可以实现在ci中运行docker命令。
    用ci自动化构建最新通过测试的docker镜像，推送到私库方便部署.


解决办法：

    在启动docker时加上/var/run/docker.sock挂载，自定义gitlab-ci镜像，在镜像中安装好docker.
    runner注册时加上参数  --executor docker \
    --docker-image "docker:stable" \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock  \
    --docker-privileged
    使得对应的JOB容器可以直接使用宿主机的docker(image内需安装docker-cli)可以理解为docker in docker in docker

#### uploads文件无法删除

问题详情：

    在release的时候attach的file一直存在uploads内，没有相关界面可以删除

解决办法：

     gitlab_rails['uploads_storage_path']

#### 删除tag时不会自动删除release

问题详情：

    在删除tag的时候对应的release没有自动删除

解决办法：

    通过curl命令访问api取删除对应的release,会同时将tag删除掉

[gitlab api](https://docs.gitlab.com/ee/api/releases/links.html#delete-a-link)
    

### TODO：

- [ ] 验证证书是否自更新
- [ ] 代码备份
- [ ] 确认docker in docker in docker是否可用

### 参考文档：

[官方docker文档](https://docs.gitlab.com/omnibus/docker/)

[Gitlab-runner](https://docs.gitlab.com/runner/install/docker.html)

[Ci配置](https://docs.gitlab.com/runner/register/)

[Ci docker](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html)

[Nginx配置](https://docs.gitlab.com/omnibus/settings/nginx.html)

[内存优化](https://blog.csdn.net/ouyang_peng/article/details/84066417)

[使用docker搭建gitlab以及ci平台，完整版本(使用springboot项目演示)](https://juejin.im/post/5ba1c6d65188255c8b6ee5bc)

[GitLab内存占用过高的解决方法](https://www.shaobin.wang/post/18.html)

[代码备份](https://blog.csdn.net/u014258541/article/details/79317180)

[gitlab.rb 模板](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template)

[let证书自更新配置](https://docs.gitlab.com/omnibus/settings/ssl.html#automatic-lets-encrypt-renewal)

[docker-compose 部署gitlab](https://cnodejs.org/topic/5bb4caa69545eaf107b9c7e6)