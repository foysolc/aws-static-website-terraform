# 🚀 Automated Static Website Deployment on AWS with Terraform

This repository contains the Infrastructure as Code (IaC) for deploying a secure, highly-available, and cost-effective static website on Amazon Web Services (AWS) using Terraform.

---

## ✨ Project Overview

This project automates the entire setup for hosting a personal website (like `foysol.cloud`). Instead of manually configuring services in the AWS console, all infrastructure is defined and managed through Terraform code. This approach ensures consistency, reproducibility, and allows for efficient version control of the cloud environment.

---

## 🌟 Key Features & Technologies

- **Infrastructure as Code (IaC):** Defined using Terraform.
- **Static Website Hosting:** Leverages Amazon S3 for durable and scalable storage of website assets.
- **Global Content Delivery Network (CDN):** Utilizes Amazon CloudFront for low-latency content delivery and caching at edge locations worldwide.
- **Secure HTTPS:** Enforced via CloudFront, with a free SSL/TLS certificate managed by AWS Certificate Manager (ACM).
- **Custom Domain Management:** Amazon Route 53 handles DNS resolution for the custom domain (`foysol.cloud`).
- **Secure Access Control:** AWS Identity and Access Management (IAM) used to establish a secure Origin Access Identity (OAI) for private S3 bucket access by CloudFront.
- **Cost-Effective:** A serverless architecture minimizes operational overhead and costs.

---

## 🌐 Architecture Overview

The diagram below illustrates the flow of a user's request and the AWS services involved in serving the static website:

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

- **User:** Initiates a request for `https://www.foysol.cloud`.
- **Route 53:** Resolves `foysol.cloud` to the CloudFront distribution's address.
- **CloudFront:** Caches and serves content from the nearest edge location. Forwards requests to S3 if content is not cached. Enforces HTTPS.
- **S3:** Securely stores the website's `index.html`, CSS, JavaScript, and image files. Only accessible by CloudFront via OAI.
- **ACM:** Provides the SSL/TLS certificate for CloudFront to enable HTTPS encryption.
- **IAM:** Manages the secure connection between CloudFront and S3.

---

## 🚀 Deployment Steps

### 🔧 Prerequisites

- An AWS Account.
- AWS CLI installed and configured with appropriate credentials.
- Terraform installed (version 1.0+ recommended).
- A registered domain name (e.g., `foysol.cloud` from GoDaddy).
- Your static website files (e.g., `index.html`, `style.css`, images) organized in a directory (e.g., `website/`).

---

### ⚙️ Setup and Deployment

#### 1. Clone the Repository

```bash
git clone https://github.com/your-github-username/aws-static-website-terraform.git
cd aws-static-website-terraform
```

#### 2. Prepare your Website Content

Ensure your static website files are located in a subdirectory (e.g., `website/`) within this project's root directory.

```
aws-static-website-terraform/
├── main.tf
├── variables.tf
├── outputs.tf
└── website/
    ├── index.html
    ├── css/
    └── images/
```

#### 3. Initialize Terraform

```bash
terraform init
```

This downloads necessary AWS provider plugins.

#### 4. Review the Deployment Plan

```bash
terraform plan
```

Expect to see a summary indicating new resources will be added.

#### 5. Apply the Configuration

```bash
terraform apply
```

> **Important:** This step can take 15–40 minutes as CloudFront and ACM resources require global deployment and validation. It may appear “stuck” at `aws_acm_certificate_validation` or `aws_cloudfront_distribution`—this is normal.

---

### 🌐 Update Your Domain's Name Servers (Manual Step)

After `terraform apply` completes, it will output the name servers managed by AWS Route 53.

1. Log in to your domain registrar (e.g., GoDaddy).
2. Navigate to your domain’s DNS settings.
3. Replace your current name servers with the four provided by Route 53.

> DNS propagation can take up to 48 hours, but typically completes within a few hours.

---

### 📤 Upload Website Content to S3

Once the infrastructure is ready and DNS is updated:

```bash
cd website
aws s3 sync . s3://foysol.cloud --delete
```

> Replace `foysol.cloud` with your actual bucket name/domain if different.

---

### ✅ Verify Deployment

Navigate to your domain:

```text
https://www.foysol.cloud
```

Make sure it loads securely via `https://`.

---

### 🧹 Cleanup (Optional)

To tear down all AWS resources:

```bash
terraform destroy
```

> Be sure to confirm when prompted. You may need to **manually empty the S3 bucket** before Terraform can delete it, as Terraform cannot remove non-empty buckets by default.

---

## 📁 Project Structure

```
.
├── main.tf               # Main Terraform configuration, defining AWS resources.
├── variables.tf          # Input variables for domain name, AWS region, etc.
├── outputs.tf            # Outputs from Terraform (e.g., CloudFront domain, Route 53 Name Servers).
├── providers.tf          # AWS provider configuration.
├── website/              # Directory for your static website files (index.html, CSS, JS, images).
│   ├── index.html
│   ├── style.css
│   └── ...
├── README.md             # This file.
└── .gitignore            # Specifies files to ignore in Git (e.g., .terraform/, *.tfstate).
```

---

## 🛣️ Future Enhancements

- Implement CI/CD pipeline (e.g., GitHub Actions, CodePipeline/CodeBuild) for automatic deployment.
- Serve custom 403/404 error pages via CloudFront.
- Enable access logging via CloudFront to CloudWatch or S3.
- Extend Terraform to support dev/prod environments (e.g., `dev.foysol.cloud`, `prod.foysol.cloud`).

---

## 📄 License

This project is open-sourced under the **MIT License**.