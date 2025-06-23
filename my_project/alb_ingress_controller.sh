#!/bin/bash

# === Set Environment Variables ===
export CLUSTER_NAME="vpro-eks"           # <-- Change this to your actual cluster name
export REGION="us-east-1"                      # <-- Change this to your actual AWS region
export POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"

# === Download IAM Policy ===
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

# === Create IAM Policy ===
echo "Creating IAM policy $POLICY_NAME..."
aws iam create-policy \
  --policy-name $POLICY_NAME \
  --policy-document file://iam-policy.json || echo "Policy may already exist. Continuing..."

# === Create IAM Service Account with IRSA ===
eksctl create iamserviceaccount \
  --cluster $CLUSTER_NAME \
  --region $REGION \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/$POLICY_NAME \
  --approve \
  --override-existing-serviceaccounts

# === Add Helm Repo ===
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# === Install AWS Load Balancer Controller ===
VPC_ID=$(aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text)

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set region=$REGION \
  --set vpcId=$VPC_ID \
  --set serviceAccount.name=aws-load-balancer-controller

# === Confirm Installation ===
echo "\nChecking controller deployment..."
kubectl get deployment -n kube-system aws-load-balancer-controller
