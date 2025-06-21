🚀 Automated Static Website Deployment on AWS with Terraform

This repository contains the Infrastructure as Code (IaC) for deploying a secure, highly-available, and cost-effective static website on Amazon Web Services (AWS) using Terraform.

✨ Project Overview
This project automates the entire setup for hosting a personal website (like foysol.cloud). Instead of manually configuring services in the AWS console, all infrastructure is defined and managed through Terraform code. This approach ensures consistency, reproducibility, and allows for efficient version control of the cloud environment.

🌟 Key Features & Technologies
Infrastructure as Code (IaC): Defined using Terraform.

Static Website Hosting: Leverages Amazon S3 for durable and scalable storage of website assets.

Global Content Delivery Network (CDN): Utilizes Amazon CloudFront for low-latency content delivery and caching at edge locations worldwide.

Secure HTTPS: Enforced via CloudFront, with a free SSL/TLS certificate managed by AWS Certificate Manager (ACM).

Custom Domain Management: Amazon Route 53 handles DNS resolution for the custom domain (foysol.cloud).

Secure Access Control: AWS Identity and Access Management (IAM) used to establish a secure Origin Access Identity (OAI) for private S3 bucket access by CloudFront.

Cost-Effective: A serverless architecture minimizes operational overhead and costs.

🌐 Architecture Overview
The diagram below illustrates the flow of a user's request and the AWS services involved in serving the static website:

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





User: Initiates a request for https://www.foysol.cloud.

Route 53: Resolves foysol.cloud to the CloudFront distribution's address.

CloudFront: Caches and serves content from the nearest edge location. Forwards requests to S3 if content is not cached. Enforces HTTPS.

S3: Securely stores the website's index.html, CSS, JavaScript, and image files. Only accessible by CloudFront via OAI.

ACM: Provides the SSL/TLS certificate for CloudFront to enable HTTPS encryption.

IAM: Manages the secure connection between CloudFront and S3.

🚀 Deployment Steps
Follow these steps to deploy your own static website using this Terraform configuration.

Prerequisites
An AWS Account.

AWS CLI installed and configured with appropriate credentials.

Terraform installed (version 1.0+ recommended).

A registered domain name (e.g., foysol.cloud from GoDaddy).

Your static website files (e.g., index.html, style.css, images) organized in a directory, for example, named website/.

Setup and Deployment
Clone the Repository:

git clone https://github.com/your-github-username/aws-static-website-terraform.git
cd aws-static-website-terraform





Prepare your Website Content:
Ensure your static website files are located in a subdirectory (e.g., website/) within this project's root directory. For example:

aws-static-website-terraform/
├── main.tf
├── variables.tf
├── outputs.tf
└── website/
    ├── index.html
    ├── css/
    └── images/





Initialize Terraform:
Navigate to the root of your project directory (where main.tf is located) and initialize Terraform. This downloads necessary AWS provider plugins.

terraform init





Review the Deployment Plan:
Generate an execution plan to see exactly what resources Terraform will create, modify, or destroy in your AWS account. This is a crucial safety step.

terraform plan





Expect to see a summary indicating new resources will be added.

Apply the Configuration:
Execute the plan to provision the AWS infrastructure. This step will prompt for confirmation (yes).

terraform apply





Important Note: This step can take 15-40 minutes as CloudFront distributions and ACM certificates require time to deploy and validate globally. It might appear "stuck" on aws_acm_certificate_validation or aws_cloudfront_distribution—this is normal.

Update Your Domain's Name Servers (Manual Step):
After terraform apply completes, it will output the Name Servers managed by AWS Route 53.

Log in to your domain registrar (e.g., GoDaddy).

Navigate to your domain's DNS settings.

Replace your current Name Servers with the four provided by AWS Route 53.

DNS propagation can take up to 48 hours, but often completes within a few hours. Your website won't be live until this step is done.

Upload Website Content to S3:
Once your AWS infrastructure is set up and Name Servers are updated, upload your static website files to the S3 bucket. Ensure you are in the directory containing your website content (e.g., cd website).

Make sure you are in the 'website/' directory or adjust the path.
aws s3 sync . s3://foysol.cloud --delete





(Replace foysol.cloud with your actual domain name if different).

Verify Deployment:
After allowing some time for DNS propagation and CloudFront cache updates, open your web browser and navigate to your domain:
https://www.foysol.cloud
(Ensure it's https:// for secure access).

Cleanup (Optional)
To tear down all the AWS resources created by this project and avoid incurring further charges:

Destroy Terraform Resources:

terraform destroy





This will ask for confirmation (yes). Be absolutely sure you want to delete all associated resources before proceeding.

You may need to manually empty the S3 bucket before terraform destroy can successfully delete it, as Terraform cannot delete a non-empty S3 bucket by default.

📁 Project Structure
.
├── main.tf                 # Main Terraform configuration, defining AWS resources.
├── variables.tf            # Input variables for domain name, AWS region, etc.
├── outputs.tf              # Outputs from Terraform (e.g., CloudFront domain, Route 53 Name Servers).
├── providers.tf            # AWS provider configuration.
├── website/                # Directory for your static website files (index.html, CSS, JS, images).
│   ├── index.html
│   ├── style.css
│   └── ...
├── README.md               # This file.
└── .gitignore              # Specifies files to ignore in Git (e.g., .terraform/, *.tfstate).





🧠 Key Learnings & Interview Highlights
This project provides hands-on experience with fundamental cloud concepts and tools, making it an excellent talking point for technical interviews:

Infrastructure as Code (IaC) with Terraform:

"This project demonstrates IaC using Terraform. Instead of manual clicks, I define my entire cloud infrastructure (S3, CloudFront, DNS, etc.) in code. This ensures consistency, enables version control, and allows for rapid, repeatable deployments."

Security Best Practices:

"A core focus was security. My S3 bucket, where the website files are stored, is private. I use a CloudFront Origin Access Identity (OAI) to allow CloudFront to privately pull content, preventing direct public access to S3. All traffic is forced to HTTPS using a free SSL certificate from AWS Certificate Manager, ensuring data in transit is encrypted."

Scalability & Performance (CDN):

"By using Amazon CloudFront as a CDN, the website content is cached at 'edge locations' globally. This means users access the website from the nearest server, providing extremely low latency and a fast user experience. It also handles high traffic volumes automatically, making the architecture highly scalable."

DNS Management & Cross-Region Awareness:

"I managed custom domain DNS using AWS Route 53, pointing my GoDaddy domain to the AWS infrastructure. I also handled a key AWS nuance: the SSL certificate for CloudFront must be provisional in the us-east-1 region, regardless of where other resources are."

Troubleshooting & Real-World Challenges:

"I gained experience troubleshooting common cloud deployment issues, such as waiting for DNS propagation and CloudFront deployments, and ensuring correct IAM permissions between services."

Cost-Effectiveness (Serverless):

"This is a highly cost-effective, 'serverless' architecture. We're only paying for storage (S3) and data transfer/requests (CloudFront), which is minimal for a static site. Much of it falls within the AWS Free Tier."

🛣️ Future Enhancements
CI/CD Pipeline: Implement a pipeline (e.g., with GitHub Actions, AWS CodePipeline/CodeBuild) to automate code changes, Terraform apply, and S3 content sync upon new code commits.

Custom Error Pages: Configure CloudFront to serve custom 403 or 404 error pages from S3.

Logging and Monitoring: Integrate CloudFront access logs with Amazon CloudWatch or S3 for traffic analysis and monitoring.

Multiple Environments: Extend the Terraform configuration to deploy to different environments (e.g., dev.foysol.cloud, prod.foysol.cloud).

📄 License
This project is open-sourced under the MIT License.