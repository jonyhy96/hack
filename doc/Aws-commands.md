# AWS 命令合集

### 环境：

 > * pip 19.0.3
 > * aws-cli 1.16.116
 > * aws-shell
 > * ecs-cli 1.12.1
 > * Ubuntu 18.04

### 查看已注册lambda函数

[AWS 基本操作流](https://docs.aws.amazon.com/zh_cn/streams/latest/dev/fundamental-stream.html)

```shell
//localstack
aws --endpoint-url=http://0.0.0.0:4574 lambda list-functions 

//localstack1
aws --endpoint-url=http://0.0.0.0:5574 lambda list-functions 
```

### 查看已注册的kinesis流

[AWS 基本操作流](https://docs.aws.amazon.com/zh_cn/streams/latest/dev/fundamental-stream.html)

```shell
//localstack
aws --endpoint-url=http://0.0.0.0:4568 kinesis list-streams

//localstack1
aws --endpoint-url=http://0.0.0.0:5568 kinesis list-streams
```

### 查看SSM存储值

[AWS SSM](https://docs.aws.amazon.com/systems-manager/latest/userguide/integration-ps-secretsmanager.html)

```shell
aws ssm get-parameter --name key --with-decryption
```

### 查看lambda日志流

[aws-shell](https://github.com/awslabs/aws-shell)

```shell
➜  ~ aws-shell
aws> logs describe-log-groups |grep Admin
aws> logs describe-log-streams --log-group-name /aws/lambda/AdminSiteAccount-dev-sendCASAC
aws> logs get-log-events --log-group-name /aws/lambda/AdminSiteAccount-dev-sendCASAC --log-stream-name 
```

### 查看ECS实例日志

```shell
➜  ~ aws-shell
aws> ecs list-tasks --cluster dev-or-ecs-fargate-cluster --service-name dev-or-admin-site-acct-cmd-service

ctrl+d

➜  ~ ecs-cli logs --task-id  ID --cluster CLUSTER |grep -v "nginx"

//持续查看日志
➜  ~ watch -n 2 'ecs-cli logs --task-id ID --cluster CLUSTER |grep "018-"'
```

e.g. 
![Screenshot_from_2019-03-05_16-02-10](uploads/ae7078bdc23ccdb5851fea5c912b45ed/Screenshot_from_2019-03-05_16-02-10.png)

### 查看ECS镜像

```shell
➜  ~ ecs-cli images --tagged  [REPOSITORY NAME]
```

### 查看ECS实例详情

```shell
➜  ~ aws-shell
aws> ecs describe-services --services SERVICE --cluster CLUSTER
aws> ecs describe-container-instances --container-instances CONTAINERID --cluster CLUSTER
```
