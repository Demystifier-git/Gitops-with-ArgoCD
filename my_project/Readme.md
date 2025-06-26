# 📦 Deploying a Containerized Social Media App on Amazon EKS (EKS-cluster setup with terraform(IAAC))

This project demonstrates how to deploy a fully containerized **social media web application (PHP + MySQL)** on **Amazon Elastic Kubernetes Service (EKS)** with persistent storage, secure HTTPS using ACM, and traffic management via AWS ALB Ingress Controller.



The application is live at: **https://www.delightdavid.org.ng**

---

## 🧱 Tech Stack & Components

- **Amazon EKS** for Kubernetes cluster (Created Using Terraform)
- **StatefulSet + AWS EBS CSI Driver** for MySQL persistent storage
- **Deployment + Service** for the PHP app
- **AWS ALB Ingress Controller** for HTTP/HTTPS routing
- **ACM (AWS Certificate Manager)** for SSL/TLS
- **Route 53** for DNS
- **kubectl & AWS CLI** for management

---

## 🚀 Deployment Overview

### Step 1: Provision EKS Cluster

You can use `eksctl` or Terraform to create the cluster. Example using `eksctl`:

RUN terraform init
    terraform apply

Install AWS EBS CSI Driver

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.24"

Apply the storage class

Step 3: Set Up ACM (SSL Certificate)
Go to AWS Certificate Manager
Request a public certificate for your domain: www.delightdavid.org.ng
Validate via DNS (e.g., Route 53)
Save the ACM ARN (you’ll use it in the Ingress)

Step 4: Install AWS ALB Ingress Controller
Create and attach the IAM policy for the ALB controller:
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam-policy.json

Then associate it with a service account using eksctl:

eksctl create iamserviceaccount \
  --cluster=social-app-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::<your-account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
Install the ALB controller with Helm:


helm repo add eks https://aws.github.io/eks-charts
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=social-app-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<your-vpc-id> \
  --set ingressClass=alb  

Next step is to deploy MYSQL using statefulset and EBS
Deploy your PHP APP, Expose with ingress

After deploying the Ingress, get the ALB DNS:
kubectl get ingress php-app-ingress
Then in Route 53 (or your DNS provider), create a CNAME or A record (Alias) for:
www.delightdavid.org.ng -> <ALB DNS name>

✅ Final Validation
Visit https://www.delightdavid.org.ng

Confirm SSL is active (ACM)

App should be accessible

Data should persist across pod restarts (MySQL via EBS)

Load is distributed across PHP app replicas

👨‍💻 Author
Chukwuagoziem Delight David
DevOps Engineer
🔗 www.delightdavid.org.ng