# web-app
This is an simple application which displays the name after submitting the form. 

This project automates the CI/CD process for a Flask web application using Jenkins. The application is containerized using Docker, pushed to Docker Hub, and deployed to a Kubernetes cluster in a specific namespace using kubectl.

## Technologies Used

1. Jenkins 
2. Terraform
3. Docker
4.Docker Hub
5. Kubernetes
6. kubectl
7. Git & GitHub


Steps includes:
1. Provision infrastructure with Terraform (AWS EC2)
2. Install Docker, Jenkins, and k3s on EC2
3. create an application and dockerize it and create adeployment with nginx and cert-manager
4. Configure the jenkins add the plugins
5.Create and push Docker images to Docker Hub via Jenkins and Update Kubernetes deployment using Jenkins post-push

### 1. Provision infrastructure with Terraform (AWS EC2)  
Checkout to the branch feat/terraform and there will be main.tf, as per the need that file is beong configured  
now do ```terraform plan``` and then ```terraform apply```  
 This will create 2 EC2 instances  
One we will use for the deployment using kuberentes, so basically we will add one cluster in the first EC2  
Secound we will use for running the jenkins and for the CI/CD  

### 2. Install following in instances 
#### 2.1 Install Docker, Jenkins, and k3s on first EC2 
insrall docker 
```
sudo apt install -y docker.io
sudo usermod -aG docker jenkins
sudo systemctl restart docker
```
Install kubectl 
```
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```
Install k3s 
```
curl -sfL https://get.k3s.io | sh -
```
#### 2.2 Install jenkins and configure it in the another instace
```
sudo apt update
sudo apt install -y openjdk-11-jdk
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
```

### 3. create an application and dockerize it and create adeployment with nginx and cert-manager
#### 3.1 Create the application and push it in github with dockerfile
```
git add <web-app>
git commit -m "<message>"
git push origin main
```

#### 3.2 Dockerize the application and push the dokcerfile
#### 3.2 add the Jenkinsfile for the build and push pipeline
#### 3.3 Add the webhook in the github repo in Setttings>>>Wevhooks>>>add webhook>>>http://<jenkins-ip>:8080/guthub-webhook/

#### 3.4 Kuberentes deployment 
Access the cluster using kube config
checkout in feat/k8s branch
WE WILL BE USING HELM FOR THE TEMPLATING 
##### 3.4.1---> Deploy web app in kuberentes 
see the values file ```polymorphic-app-values.yaml```
do FOllowing command
``` 
helm repo add improwised https://improwised.github.io/charts/
helm repo add cert-manager https://charts.jetstack.io
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
now install web-app, ingress-nginx and cert-mananger one by one 
```
kubectl create namespace web-app
helm install web-app -n web-app improwised/polymorphic-app --values ~/web-app/k8s/values-polymorphic.yaml
```
```
helm install cert-manager jetstack/cert-manager \                                            
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```
```
elm install nginx ingress-nginx/ingress-nginx -n ingress-nginx --values nginx-values.yaml
```

After everything is up and running add this to /etc/hosts file to check wheather the application is up and runing or not 
``` <public-ip-of-instance> <dns>```
If the app shows like this 
That means the application is up and running
![image](https://github.com/user-attachments/assets/dd2fbd22-989d-4839-8434-97691257916f)

### 4. Configure the jenkins add the plugins
Now part comes of configuring jenkins to make the CI to build and push the image to dockerhub and then changig that image into deployemt for the CD
#### 4.1 Visit: http://<EC2_PUBLIC_IP>:8080
then do 
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
#### 4.2 Install suggested plugins
Create admin user

#### 4.3 Add DockerHub Credentials to Jenkins
Go to: Manage Jenkins → Credentials  
Type: Username/Password  
ID: dockerhub  
And add Your DockerHub username and password  

#### 4.4 also add github credentials  
🔍 Step 1: Check Existing Credentials  
Go to Jenkins Dashboard.  
Click "Manage Jenkins".  
Click "Credentials".  
Click the (global) domain (or the one your pipeline/job is using).  
Look for the credentials list:  
Add your GitHub username/token entry  
Check the ID column — this is the credentialsId you should use in your Jenkinsfile which is there in github.  

### 5.Create and push Docker images to Docker Hub via Jenkins and Update Kubernetes deployment using Jenkins post-push  
Create New Pipeline Job:  
Name: web-app  
Type: Pipeline  
Choose under “Pipeline script from SCM”:  
SCM: Git  
Repo URL: https://github.com/yourname/your-repo.git  
Script Path: Jenkinsfile  
Add your GitHub repo URL in Pipeline definition (or use a Jenkinsfile in the repo)  

Done!!!
Now build the pipeline and the new image will be pushed in dockerhub and that image will be added in the deplyment of the web-app in kuberentes cluster.

