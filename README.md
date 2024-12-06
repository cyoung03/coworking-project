# Coworking Space Service Extension
The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

For this project, you are a DevOps engineer who will be collaborating with a team that is building an API for business analysts. The API provides business analysts basic analytics data on user activity in the service. The application they provide you functions as expected locally and you are expected to help build a pipeline to deploy it in Kubernetes.

## How the deployment process works
This is a guide on how the current process to build the Coworking Space Service Extension works and how you can make some changes.

#### Git setup
Ensure you have git cloned the repository to your local machine

#### Setup cluster (skip if one is already running)
Using the following commands we can setup a kubernetes cluster easily
1. ```eksctl create cluster --name coworking-cluster --region us-east-1 --nodegroup-name coworking-node --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2```
2.  ```aws eks --region us-east-1 update-kubeconfig --name coworking-cluster```
Please take note of the parameters in command 1, as you can set the cluster name, cluster node group name and instance sizes, you must then call the cluster name in the second command to correctly set up the kube config file

#### Build postgres (skip if already been setup)
Using the yaml files that have been created in the db_config folder we can use the kubectl apply command to apply the yaml files to the cluster
1. ```kubectl apply -f /workspace/db_config/pvc.yaml``` setup the persistant volume chain
2. ```kubectl apply -f /workspace/db_config/pv.yaml``` setup the persistant volume
3.  ```kubectl apply -f /workspace/db_config/postgresql-deployment.yaml``` setup postgres deployment this is also where we setup the postgres user, database, password and port
4.  ```kubectl apply -f /workspace/db_config/postgresql-service.yaml``` setup postgres service

##### Next we can seed the database, by forwarding a port so we can connect locally.
1. ```kubectl get svc``` check postgres service has been created and get service name
2. ```kubectl port-forward service/postgresql-service 5433:5432 &``` forward the port
3. ```apt update```
4. ```apt install postgresql postgresql-contrib -y``` install psql
5. ```export DB_PASSWORD=<password>``` export your password to a variable
6. run the psql commands to process sql files in the db directory ```PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < /workspace/db/1_create_tables.sql ``` ```PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < /workspace/db/2_seed_users.sql``` ```PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < /workspace/db/3_seed_tokens.sql```


#### Making a change to your image (skip if you don't need to)
1. If you need to make a change to the any of the files used in the coworking-app image then you will need to save and push your changes to git.
2. Then create a pull request to be merged into the main branch, this will trigger the webhook for codebuild and will initiate the buildspec.yml to create a new image
3. This will then push the image to the coworking-project elastic container registry and increment the immutable image tag by 1
4. you will then need to go back to your local and update the coworking-api.yml file in the deployment folder and change the image tag to the version you wish to use ```image: 619836274583.dkr.ecr.us-east-1.amazonaws.com/coworking-project:19```
   
#### Deploy coworking service
Now we can deploy the coworking api service using the kubectl apply functions again. If this is a new cluster you will need to run the first two commands
1. ```kubectl apply -f /workspace/deployment/configmap.yml``` setup config-map
2. ```kubectl apply -f /workspace/deployment/secrets.yml``` setup secret with postgres password
3. ```kubectl apply -f /workspace/deployment/coworking-api.yml``` -- setup load balancer and deployment

#### Check services are working
There are serveral ways to check that your microservice is working correctly
1. ```kubectl get pods``` This is a nice way to see if your containers are ready, if a container is 0/1 in status column then you will need to diagnose the issue, you can use the kubectl describe pod <pod-name> for this.
2. ```kubectl get svc``` Check your services are running and that your coworking service has an external-ip that we can use in a curl command
3. ```curl <external-ip>.elb.amazonaws.com:5153/api/reports/daily_usage``` using the external-ip from the coworking service we can test the api and get a response.
4. We can also monitor the logs being collected on Cloudwatch at this location /aws/containerinsights/coworking-cluster/application



