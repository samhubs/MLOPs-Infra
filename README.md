# This project is based on building an end-to-end MLOPs pipeline using Terraform.
## It includes training and infrastructure based on Kubernetes and AWS.

1. Create a virtual environment
```sh
python3 -m venv my_env
```
2. Install and configure AWS CLI
```sh
pip install awscli

aws configure
```
Make sure you have the AWS access and secret access key for the configuration.

3. Install Terraform
```sh
brew tap hashicorp/tap

brew install hashicorp/tap/terraform
```
Verfiy the installation:
```sh
terraform --help
```
4. Install Terragrunt
```sh
brew install terragrunt
```
5. Configure backend with Terraform - this includes creating a S3 bucket to store its states. Assuming you have created the bucket and also a `main.tf` file, copy the content below to the file:
```sh
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
```
Update the bucket name, key and region appropriately.

6. Verify the setup
```sh
terraform version
terraform init
terraform validate
```
7. Install Kubernetes
```sh 
brew install kubectl
```
Verify the installation:
```kubectl version --client```
8. Install Helm - the package manager for Kubernetes
```sh 
brew install helm
```
9. Install k9s, a terminal-based Kubernetes UI
```sh 
brew install k9s
```
10. Install kubectx and kubens

These tools make it easier to switch between Kubernetes contexts and namespaces.
11. Install container tools: 
```bash
Install Docker Desktop/Engine
Configure resource limits
Set up experimental features
```
Test installation:
```sh 
docker run hello-world
docker compose version
```
12. Install podman
```sh
brew install podman
```
13. Configure local registry
```sh
podman run -d -p 5002:5002 --name registry registry:2
```
14. VSCode Setup
  - Install VSCode Configure Extensions:
    - Python 
    - Terraform
    - Kubernetes
    - YAML
    - Docker
    - GitLens
    - Remote Development

Good job! Now that you have access to all the frameworks we will use, let's start with the infrastructure setup. 

### Basic directory structure
```
mlops-platform/
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   ├── modules/
│   │   ├── eks/
│   │   ├── networking/
│   │   ├── security/
│   │   ├── ecr/                # New module for Docker registry
│   │   └── monitoring/
│   └── main.tf
├── kubernetes/
│   ├── base/
│   │   ├── deployments/
│   │   ├── services/
│   │   ├── configs/
│   │   └── monitoring/
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── scripts/
│   ├── data_preprocessing/
│   ├── training/
│   ├── inference/
│   └── utils/
├── models/
│   └── yolo_skeleton_detection/
│       ├── model_definition.py
│       ├── train.py
│       ├── inference.py
│       └── requirements.txt
└── README.md
```
