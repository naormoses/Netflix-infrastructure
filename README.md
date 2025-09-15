🎬 Netflix Clone on EKS with Terraform and Helm
🚀 Project Overview

This project demonstrates deploying a containerized Netflix-like application on Amazon EKS (Elastic Kubernetes Service) using modern DevOps practices.
It covers the full lifecycle of:

Infrastructure as Code (IaC) with Terraform

Containerization with Docker

Deployment automation with Helm

Scalable & reliable infrastructure using Kubernetes

This setup simulates a production-ready environment with a cloud-native architecture.

🛠️ Tech Stack

Cloud: AWS (EKS, VPC, IAM, S3, ECR)

IaC: Terraform

Orchestration: Kubernetes on EKS

Packaging & Deployment: Helm charts

Containers: Docker

Monitoring (optional add-on): Prometheus + Grafana

📂 Repository Structure
.
├── terraform/          # Infrastructure code for AWS EKS + networking
├── helm/               # Helm chart for the Netflix app
├── app/                # Dockerized Netflix application
└── README.md           # Project documentation

⚙️ Workflow
1. Provision Infrastructure (Terraform)

Creates:

VPC, subnets, and networking

EKS cluster + worker nodes

IAM roles and security groups

Commands:

terraform init
terraform apply -auto-approve

2. Build & Push Docker Image

Dockerfile located in /app

Build and push to AWS ECR:

docker build -t netflix-app .
docker tag netflix-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.<region>.amazonaws.com/netflix-app:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.<region>.amazonaws.com/netflix-app:latest

3. Deploy with Helm

Deploy application to EKS:

helm install netflix-app ./helm


Includes:

Deployment + Service

ConfigMaps/Secrets

Autoscaling config (HPA)

🔍 Key Features

Automated EKS provisioning via Terraform

Immutable deployments with Docker + Helm

Scalable architecture (HPA ready)

Cloud-native design simulating production

📊 Future Enhancements

Add CI/CD pipeline (Jenkins or GitHub Actions)

Add Prometheus & Grafana for monitoring

Implement Blue/Green or Canary deployments with Helm hooks

Introduce Service Mesh (Istio/Linkerd) for traffic management

🧑‍💻 Author

Naor Jonathan Moses — Aspiring DevOps Engineer
Focused on building scalable, automated, and cloud-native systems.
