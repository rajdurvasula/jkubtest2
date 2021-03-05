# jkubtest2
A simple spring boot microservice with JPA, REST features.
- This is a 2-tier application with Spring Boot and MySQL services.

## Setup for AWS
1. Launch EKS managed cluster
2. Create ECR with name ending with /blogs/blogserver

## Setup Workspace
NOTE:
- This can be your Laptop / Server as well.

### EC2 Instance
- InstanceType: t2.micro
- Amazon Linux 2
- VPC = Created as part of EKS cluster
- Subnet = Any Public Subnet
- Security Group = SSH Access

### Workspace Machine Setup
- Update OS packages
- Install python3, python3-devel, python3-pip
- Make default python = python3
- Install docker, Start docker service
- Install awscli
- Install kubectl
  - kubectl executable should be in /usr/local/bin
- Install eksctl
   - eksctl executable should be in /usr/local/bin
- Install java-1.8.0-openjdl-devel
  - set JAVA_HOME in /etc/bashrc
- Install apache-maven
- update PATH=$PATH:/usr/local/bin

### Configure Workspace
- Setup aws credentials
- Setup KUBECONFIG
```
aws eks --region ap-southeast-1 update-kubeconfig --name rd-cluster
```
- Verify Cluster connectivity
```
kubectl get svc
```

- Get ECR password / token into env. variable
```
export ECR_PASSWORD=`aws ecr get-login-password --region ap-southeast-1`
```

### Prepare App Deployment
- Clone Git Repo:
```
https://github.com/rajdurvasula/jkubtest2.git
```
- Change directory to **blogserver**

- Create Namespace
```
kubectl create namespace blogs
```

#### Launch **blogdb** service

- Create secret for MySQL root password
```
kubectl apply -f mysql-root.yml -n blogs
```

- Laumch **blogdb** Pod
```
kubectl apply -f mysql-deploy.yml -n blogs
```

- Launch **blogdb** Service
```
kubectl apply -f mysql-service.yml -n blogs
```

- Create **blog_db** database, users
```
kubectl exec blogdb-76f566b5b-5q6p4 -n blogs -- mysql -u root -ps4p3rs3cr3t < blogdb.sqlkubectl exec blogdb-76f566b5b-5q6p4 -n blogs -- mysql -u root -ps4p3rs3cr3t < blogdb.sql
```

#### Launch **blogserver** service
- Make **blogs** namespace as default namespace
```
kubectl config set-context --current --namespace=blogs
```

- Verify **blogs** namespace is default namespace
```
kubectl config view --minify | grep namespace:
```
  - Output should be
  ```
  namespace: blogs
  ```

- Build SpringBoot jar
```
mvn -Djkube.docker.push.registry=?????????????..dkr.ecr.ap-southeast-1.amazonaws.com/SOMEPREFIX/blogs/blogserver clean package k8s:build -Pkubernetes -DskipTests
```

- Push to ECR repository
```
mvn -Djkube.docker.push.registry=?????????????.dkr.ecr.ap-southeast-1.amazonaws.com/SOMEPREFIX/blogs/blogserver -Djkube.docker.username=AWS -Djkube.docker.password=$ECR_PASSWORD k8s:push -Pkubernetes -DskipTests
```

- Deploy Application
```
mvn -Djkube.docker.push.registry=?????????????.dkr.ecr.ap-southeast-1.amazonaws.com/SOMEPREFIX/blogs/blogserver -Djkube.docker.username=AWS -Djkube.docker.password=$ECR_PASSWORD k8s:resource k8s:apply -Pkubernetes -DskipTests
```

- Verify **blogserver** pod
  - Pod fails because the **Image URI** is invalid

- Edit **blogserver** deployment
```
kubectl edit deployment/blogserver
```
  - Update **Image URI** to
  ```
  ?????????????.dkr.ecr.ap-southeast-1.amazonaws.com/SOMEPREFIX/blogs/blogserver:latest
  ```
- Verify **blogserver** pod
  - Pod should be in Running state


### Test Application Service
- Get **blogserver** Service Endpoint
```
kubectl get svc blogserver
```
  - Copy the EXTERNAL-IP value

#### Create Blog User
- Request:
```
curl "http://a05abca998a2b46398d28014039ed135-297427706.ap-southeast-1.elb.amazonaws.com:8080/api/blog_users" \
  -X POST \
  -d "{\n  \"userId\": \"mahender.sharma\",\n  \"emailId\": \"mahender.sharma@example.net\"\n}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

- Response:
```
{"id":2,"userId":"mahender.sharma","emailId":"mahender.sharma@example.net"}
```

#### Get all Blog Users
- Request:
```
curl "http://:8080/api/blog_users" \
  -H "Accept: application/json" 
```

- Response:
```
[{"id":1,"userId":"ganesh.sharma","emailId":"ganesh.sharma@example.net"},{"id":2,"userId":"mahender.sharma","emailId":"mahender.sharma@example.net"}]
```
