# 🚀 Automated Static Website Deployment on AWS with Terraform

This repository contains the Infrastructure as Code (IaC) for deploying a secure, highly available, and cost-effective static website on **Amazon Web Services (AWS)** using **Terraform**.

---

## ✨ Project Overview

This project automates the entire setup for hosting a personal website (like `foysol.cloud`). Instead of manually configuring services in the AWS console, all infrastructure is defined and managed through Terraform. This ensures consistency, reproducibility, and version-controlled infrastructure.

---

## 🌟 Key Features & Technologies

- **Infrastructure as Code (IaC):** Defined using Terraform.
- **Static Website Hosting:** Uses Amazon S3 to store website files.
- **Global CDN:** Amazon CloudFront for fast, cached delivery.
- **HTTPS Security:** Free SSL/TLS via AWS Certificate Manager (ACM).
- **Custom Domain Management:** DNS handled with Amazon Route 53.
- **Secure Access:** IAM + Origin Access Identity (OAI) to restrict S3 access.
- **Cost-Effective:** Fully serverless and low maintenance.

---

## 🌐 Architecture Overview

The flow of a user's request and involved AWS services:

```
+-----------+       +-----------+       +-----------------+       +--------------+
|   User    | ----> | Route 53  | ----> |   CloudFront    | ----> |      S3      |
| (Browser) |       |   (DNS)   |       |      (CDN)      |       | (Website Files)
+-----------+       +-----------+       +-----------------+       +--------------+
                                            ^         |
                                            |         | (HTTPS)
                                            |         v
                                          +---------------------+
                                          |         ACM         |
                                          | (SSL Certificate)   |
                                          +---------------------+
```

**Component Roles:**

- **User:** Requests `https://www.foysol.cloud`.
- **Route 53:** Resolves domain to CloudFront.
- **CloudFront:** Delivers cached content from edge locations. Enforces HTTPS.
- **S3:** Securely stores website assets. Only CloudFront can access it via OAI.
- **ACM:** Supplies SSL certificate.
- **IAM:** Manages permissions between services.

---

## 🚀 Deployment Steps

### 🔧 Prerequisites

- AWS Account
- AWS CLI configured
- Terraform (v1.0+)
- A registered domain (e.g., from GoDaddy)
- Your website files (e.g., `index.html`, `style.css`) inside a `website/` directory

---

### 1. Clone the Repository

```bash
git clone https://github.com/your-github-username/aws-static-website-terraform.git
cd aws-static-website-terraform
```

---

### 2. Prepare Your Website Content

Place your files inside the `website/` directory:

```
aws-static-website-terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── website/
│   ├── index.html
│   ├── css/
│   └── images/
```

---

### 3. Initialize Terraform

```bash
terraform init
```

---

### 4. Review Deployment Plan

``
