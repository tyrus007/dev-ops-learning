# Terraform + Minikube + Kubernetes — Learning Project

## Step 0 — Install Prerequisites

Before writing any Terraform code, you need four tools installed on your machine. We install them in this order because each one builds on the previous.

---

### 1. Install Docker

Docker is the foundation. Minikube will use Docker as its driver, meaning the Kubernetes nodes will run as Docker containers on your machine instead of full virtual machines. This is the simplest setup for local learning.

**Install:**

```bash
# Remove any old versions
sudo apt remove -y docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker's repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

**Allow your user to run Docker without `sudo`** (important — Minikube needs this):

```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Verify:**

```bash
docker version
docker run hello-world
```

You should see `Hello from Docker!` in the output. If you do, Docker is working correctly.

---

### 2. Install Minikube

Minikube runs a real Kubernetes cluster locally. It spins up one or more Docker containers that act as Kubernetes nodes.

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
```

**Verify:**

```bash
minikube version
```

Expected output: `minikube version: v1.x.x`

---

### 3. Install kubectl

`kubectl` is the command-line tool for talking to a Kubernetes cluster. Terraform manages infrastructure through code, but `kubectl` is what you use manually to inspect pods, nodes, and deployments.

```bash
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
```

**Verify:**

```bash
kubectl version --client
```

Expected output: client version info (no server connection needed yet).

---

### 4. Install Terraform

Terraform is the infrastructure-as-code tool we will use to create the Minikube cluster and deploy resources to it.

```bash
# Add HashiCorp's GPG key
wget -O- https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp's repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
sudo apt update && sudo apt install -y terraform
```

**Verify:**

```bash
terraform version
```

Expected output: `Terraform v1.x.x`

---

### Final Check

Run all four checks together to confirm everything is ready before moving to Step 1:

```bash
docker version --format "Docker {{.Client.Version}}"
minikube version
kubectl version --client --short
terraform version
```

All four should print version numbers without errors. Once they do, you are ready to write your first Terraform file.
