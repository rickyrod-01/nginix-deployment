###LAB 1 Deploying Applications with Helm and Amazon S3

##not everything is here but with creativity & effort
##this could be made to made to work....
##this was a lab at AWS re:Invent 2022 but it's free to complete now.
## Be sure to check the links at the bottom of the page
##as they lead to the origin of much of what is here (hint - esp the 3rd link)

##This lab demonstrates the process of downloading and installing
## Helm v3, the creation of a private Helm chart repository in Amazon
## Simple Storage Service (Amazon S3), download, package, and push
## the chart to Amazon S3.  You then install the application as a Helm
##chart in AWS S3 into your EKS cluster, and view and validate then##
##application installed successfully...
##
##Install Helm and create an Amazon S3 bucket as a HELM repository
##Helm is a package manager for Kubernetes like yum in Linux
##Helm helps you install and manage applications on a Kubernetes 
##cluster
##TASK 1 Install Helm and and Create anAmazon S3 buckert as a helm 
##repository
## search on in ec2 in the AWS console
##install helm using the command below, Use the ssh terminal under 
##session manager.  1/ select bastion host. 2/click on connect under 
##session manager 3/then click on the orange "connect" button
##The amazon lab automatically installs a bastion host and 3 linux 
##instances. It is not known at this point how exactly to replicate 
##this.But it seems acheivable. There are 4 ec2 instances
##1 Bastion Host - t3.micro and 3 named dev-cluster-devnodes-Node 
## of the t3.medium variety. The Bastion host has an elastic IP
##address. The Bastion host has the BastionHostIamRole.  The nodes
## have the EksNodeRole Iam role.
##
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
##verify version of Helm installed in terminal using the following
## command
helm version --short
# should return something like v3.10.2+g50f003e
#install helm s3 plugin
helm plugin install https://github.com/hypnoglow/helm-s3.git
#should return
#Downloading and installing helm-s3 v0.14.0 ...
#Checksum is valid.
#Installed plugin: s3
#
#enter the following name to initialize the helm repository
helm s3 init s3://$S3_BUCKET_NAME
#output should look similar to this
Initialized empty repository at s3://qls-187675-0110ad3c60a17165-s3workshop-w7eubi27daes
#enter the following command to see if an index.yaml file has been created
aws s3 ls $S3_BUCKET_NAME
#output should look similar to this
2022-04-29 17:40:37         71 index.yaml
#enter the following command to add the s3 repository to helm on the client machine
helm repo add productcatalog s3://$S3_BUCKET_NAME
#the output should look similar to this
"productcatalog" has been added to your repositories
##//You have installed Helm, Helm-S3 plugin and initialized a S3
##bucket as a helm repository.
##
##//TASK #2 Package product catalog chart and push to Amazon s3
#In the bastion host session enter the following command to see the repository list
helm repo list
#output should look like
NAME            URL
productcatalog  s3://workshop-046223204357
#Enter the following command to clone the application helm chart
git clone https://github.com/aws-containers/eks-app-mesh-polyglot-demo.git
#enter the following commands to understand the Helm Chart
#directory structure and the files in the directory.
cd eks-app-mesh-polyglot-demo/workshop
tree helm-chart/
# the output should be a "tree" directory.
helm-chart/
├── Chart.yaml
├── productcatalog_workshop-1.0.0.tgz
├── templates
│   ├── catalog_deployment.yaml
│   ├── catalog_service.yaml
│   ├── detail_deployment.yaml
│   ├── detail_service.yaml
│   ├── frontend_deployment.yaml
│   ├── frontend_service.yaml
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── namespace.yaml
│   ├── NOTES.txt
│   └── tests
│       └── test-connection.yaml
├── values-aurora.yaml
├── values-ebs.yaml
├── values-efs.yaml
├── values-old.yaml
└── values.yaml

#Chart.yaml: A YAML file containing information about the chart
#LICENSE: OPTIONAL: A plaintext file containing the license for the ##chart
#README.md: OPTIONAL human readable readme file
#values.yaml: The default configuration values for this chart
#values.schema.json: OPTIONAL: A JSON Schema for imposing the ##structure on the values.yaml file
#charts/: A directory containing any charts upon which this chart
##depends.
#templates/: A directory of templates that, when combined with values,
##will generate valid Kubernetes manifest files.
#templates/NOTES.txt OPTIONAL: A plain text file containing short 
##usage notes.
#
#A helm chart is comprised of a series of files within a directory
#refer to https://helm.sh/docs/topics/charts/ for more info
#refer to the https://helm.sh/docs/chart_template_guide/values_files/ 
#for more info on the values file
#refer to https://helm.sh/docs/chart_best_practices/templates/ for 
#more info on the templates directory.
#use the following command to package the application helm chart
helm package helm-chart/
#use the following command to verify if the application helm chart was packaged
ls -ltr
#you should see something similar to the following
total 72
-rw-r--r-- 1 ssm-user ssm-user   620 Dec  7 22:37 efs-pvc.yaml
-rw-r--r-- 1 ssm-user ssm-user  4555 Dec  7 22:37 cluster-autoscaler.yaml
drwxr-xr-x 2 ssm-user ssm-user    33 Dec  7 22:37 cloudformation
drwxr-xr-x 6 ssm-user ssm-user    83 Dec  7 22:37 apps
drwxr-xr-x 2 ssm-user ssm-user    61 Dec  7 22:37 spinnaker
drwxr-xr-x 2 ssm-user ssm-user    22 Dec  7 22:37 script
-rw-r--r-- 1 ssm-user ssm-user 18775 Dec  7 22:37 prometheus-eks.yaml
-rw-r--r-- 1 ssm-user ssm-user 11963 Dec  7 22:37 otel-collector-config.yaml
-rw-r--r-- 1 ssm-user ssm-user  5571 Dec  7 22:37 mysql-statefulset.yaml
-rw-r--r-- 1 ssm-user ssm-user  6227 Dec  7 22:37 mysql-statefulset-with-secret.yaml
drwxr-xr-x 2 ssm-user ssm-user    91 Dec  7 22:37 images
drwxr-xr-x 3 ssm-user ssm-user   257 Dec  7 22:37 helm-chart
-rw-r--r-- 1 ssm-user ssm-user 10801 Dec  7 22:54 productcatalog_workshop-1.0.0.tgz
#enter the following command to push the packaged helm application to the s3 helm repo
helm s3 push ./productcatalog_workshop-1.0.0.tgz productcatalog
#you should see output similar to the following....
Successfully uploaded the chart to the repository.
#enter the following command to see if the file exists in s3 repo
aws s3 ls $S3_BUCKET_NAME
# you should get output similar to the following
2022-12-07 23:05:11        446 index.yaml
2022-12-07 23:05:11      10801 productcatalog_workshop-1.0.0.tgz
##You have successfully packaged application Helm
##and pushed it to s3 bucket Helm repository.
##
##TASK3: Search an install Helm chart from Amazon s3 Repository
##learn to use --dry-run and --debug
#enter the following command to search for helm chart
helm search repo
#output should look similar to this
NAME                                    CHART VERSION   APP VERSION         DESCRIPTION
productcatalog/productcatalog_workshop      1.0.0           1.0             helm Chart for Product Catalog Workshop
#enter the following command to install helm chart to the bastion host #from the s3 repository using the --dry-run and --debug flags so that
#you can test the installation without ever installing anything.
helm install productcatalog s3://$S3_BUCKET_NAME/productcatalog_workshop-1.0.0.tgz --version 1.0.0 --dry-run --debug
# remove the --dry-run and --debug flags to actually install helm chart
helm install productcatalog s3://$S3_BUCKET_NAME/productcatalog_workshop-1.0.0.tgz --version 1.0.0
#the output should look similar to this ...
NAME: productcatalog
LAST DEPLOYED: Tue May 10 20:18:18 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
     NOTE: It may take a few minutes for the LoadBalancer to be available.
           You can watch the status of by running 'kubectl get --namespace workshop svc -w frontend'
  export LB_NAME=$(kubectl get svc --namespace workshop frontend -o jsonpath="{.status.loadBalancer.ingress[*].hostname}")
  echo http://$LB_NAME:80

#enter the following command to get the details of the fronend service
#and copy the external IP address to access the web page. Make sure to #add http:// in front of it.
kubectl get pod,svc -n workshop -o wide
#the output should look similar to this ...
NAME                               READY   STATUS    RESTARTS   AGE   IP             NODE                                          NOMINATED NODE   READINESS GATES
pod/frontend-54884b8c67-j8sz7      1/1     Running   0          93s   10.10.70.124   ip-10-10-78-193.us-west-2.compute.internal    <none>           <none>
pod/prodcatalog-6b45bcfd4f-bz72v   1/1     Running   0          93s   10.10.72.114   ip-10-10-78-193.us-west-2.compute.internal    <none>           <none>
pod/proddetail-7cdffcb79-9xs74     1/1     Running   0          93s   10.10.97.15    ip-10-10-100-133.us-west-2.compute.internal   <none>           <none>

NAME                  TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE   SELECTOR
service/frontend      LoadBalancer   172.20.27.16     a5dfb2f232088455fa7f4eed31e10d27-1022379156.us-west-2.elb.amazonaws.com   80:32158/TCP   94s   app=frontend
service/prodcatalog   ClusterIP      172.20.5.194     <none>                                                                    5000/TCP       94s   app=prodcatalog
service/proddetail    ClusterIP      172.20.254.204   <none>                                                                    3000/TCP       94s   app=proddetail
#Copy the external IP from the output and paste it into a web browser 
#tab. Make sure to add http:// to the beginning of the load balancer #URL. The value should look similar to this...
a5dfb2f232088455fa7f4eed31e10d27-1022379156.us-west-2.elb.amazonaws.com
##
##SUCCESS You have successfully installed application Helm chart.
##
##
#TASK4 Edit and re-deploy application Helm Chart
##
##
#in the bastion host session enter the following commands to edit the #values.yaml file
cd /home/ssm-user/eks-app-mesh-polyglot-demo/workshop/helm-chart
sed -i "s/replicaCount:.*/replicaCount: 3/g" values.yaml
#the previous command replaces all the "replicacount" values in the 
#file with 3 in some of the fields
#the following command upgrades the helm chart application to a new 
#version and re-deploys the application with the latest changes that 
#were made to the values.yaml file in the previous step.
helm upgrade productcatalog /home/ssm-user/eks-app-mesh-polyglot-demo/workshop/helm-chart/
##The output should look similar to this
Release "productcatalog" has been upgraded. Happy Helming!
NAME: productcatalog
LAST DEPLOYED: Fri Apr 29 17:58:35 2022
NAMESPACE: default
STATUS: deployed
REVISION: 2
NOTES:
1. Get the application URL by running these commands:
     NOTE: It may take a few minutes for the LoadBalancer to be available.
           You can watch the status of by running 'kubectl get --namespace workshop svc -w frontend'
  export LB_NAME=$(kubectl get svc --namespace workshop frontend -o jsonpath="{.status.loadBalancer.ingress[*].hostname}")
  echo http://$LB_NAME:80

#enter the following command to observe how the new pods are started
kubectl get pod,svc -n workshop
#the output should look similar to this
NAME                               READY   STATUS              RESTARTS   AGE
pod/frontend-54884b8c67-g2jk2      0/1     ContainerCreating   0          29s
pod/frontend-54884b8c67-j8sz7      1/1     Running             0          6m20s
pod/prodcatalog-6b45bcfd4f-bz72v   1/1     Running             0          6m20s
pod/prodcatalog-6b45bcfd4f-djvsf   0/1     Running             0          29s
pod/proddetail-7cdffcb79-4h46v     0/1     ContainerCreating   0          29s
pod/proddetail-7cdffcb79-9xs74     1/1     Running             0          6m20s

NAME                  TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
service/frontend      LoadBalancer   172.20.27.16     a5dfb2f232088455fa7f4eed31e10d27-1022379156.us-west-2.elb.amazonaws.com   80:32158/TCP   6m21s
service/prodcatalog   ClusterIP      172.20.5.194     <none>                                                                    5000/TCP       6m21s
service/proddetail    ClusterIP      172.20.254.204   <none>                                                                    3000/TCP       6m21s

##Rollback the Helm chart to the previous version 1. Enter the 
##following command to perform a rollback
helm rollback productcatalog 1
#output should look like this...
Rollback was a success! Happy Helming!
#to observe how the pods are terminating enter the following command
kubectl get pod,svc -n workshop
#output should look similar to this
NAME                               READY   STATUS        RESTARTS   AGE
pod/frontend-54884b8c67-g2jk2      1/1     Terminating   0          102s
pod/frontend-54884b8c67-j8sz7      1/1     Running       0          7m33s
pod/prodcatalog-6b45bcfd4f-bz72v   1/1     Running       0          7m33s
pod/prodcatalog-6b45bcfd4f-djvsf   1/1     Terminating   0          102s
pod/proddetail-7cdffcb79-4h46v     1/1     Terminating   0          102s
pod/proddetail-7cdffcb79-9xs74     1/1     Running       0          7m33s

NAME                  TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)        AGE
service/frontend      LoadBalancer   172.20.27.16     a5dfb2f232088455fa7f4eed31e10d27-1022379156.us-west-2.elb.amazonaws.com   80:32158/TCP   7m34s
service/prodcatalog   ClusterIP      172.20.5.194     <none>                                                                    5000/TCP       7m34s
service/proddetail    ClusterIP      172.20.254.204   <none>                                                                    3000/TCP       7m34s
##You have successfully edited and wre-deployed application Helm 
##chart
##
##
#You have 1/set up an s3 bucket to use as a Helm repository
#2/Created and uploaded a chart to the s3 repository
#3/packaged and installed a Helm chart from an s3 repository
# more information below

https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/set-up-a-helm-v3-chart-repository-in-amazon-s3.html

https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html

https://catalog.us-east-1.prod.workshops.aws/workshops/76a5dd80-3249-4101-8726-9be3eeee09b2/en-US/helm/deploy

https://helm.sh/docs/helm/




