Demo – Terraform + CI/CD to AWS EC2

This demo uses **Terraform** (Infrastructure as Code) and a **GitHub Actions CI/CD pipeline** to deploy an Amazon Linux 2023 EC2 instance that runs Apache and serves a simple "Welcome to WellSpan." page.

When you push to `main` or `master`, the pipeline runs Terraform to provision:

- EC2 instance (Amazon Linux 2023)
- Security group (HTTP 80, SSH 22)
- VPC/subnet association
- Bootstrap script that installs Apache and configures the welcome page

---

## Architecture

```
GitHub (push) → GitHub Actions → Terraform Apply → AWS EC2
                                      ↓
                              User Data (bootstrap)
                                      ↓
                              Apache + index.html
```

---

## Manual Configuration Required

### 1. AWS Console

#### A. Create an EC2 Key Pair

1. Go to **EC2** → **Key Pairs** → **Create key pair**
2. Name: e.g. `demo-key`
3. Type: RSA, Format: `.pem` (or `.ppk` for PuTTY)
4. Download and store the private key securely
5. Note the **key pair name** for later

#### B. Create S3 Bucket for Terraform State

1. Go to **S3** → **Create bucket**
2. Bucket name: e.g. `your-org-terraform-state`
3. Region: same as your deployment (e.g. `us-east-1`)
4. Block public access: keep enabled
5. Versioning: **Enable** (recommended for state recovery)
6. Create bucket

#### C. (Optional) DynamoDB Table for State Locking

1. Go to **DynamoDB** → **Create table**
2. Table name: `terraform-state-lock`
3. Partition key: `LockID` (String)
4. Create table

#### D. IAM User or Role for GitHub Actions

**Option 1: IAM User (simpler)**

1. Go to **IAM** → **Users** → **Create user**
2. Name: e.g. `github-actions`
3. Attach policy (or create custom policy):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

4. Create **Access key** for programmatic access
5. Save **Access Key ID** and **Secret Access Key** for GitHub secrets

**Option 2: OIDC (recommended, no long-lived keys)**

1. Go to **IAM** → **Identity providers** → **Add provider**
2. Provider type: **OpenID Connect**
3. Provider URL: `https://token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Add provider
6. Create IAM role:
   - Trusted entity: **Web identity**
   - Identity provider: `token.actions.githubusercontent.com`
   - Audience: `sts.amazonaws.com`
   - Add condition: `StringEquals` → `token.actions.githubusercontent.com:aud` = `sts.amazonaws.com`
   - Add condition: `StringLike` → `token.actions.githubusercontent.com:sub` = `repo:YOUR_ORG/YOUR_REPO:*`
7. Attach policies: `AmazonEC2FullAccess`, `AmazonS3FullAccess` (or equivalent custom policy)
8. Copy the **Role ARN** for GitHub secrets

---

### 2. GitHub Repository

#### A. Add Secrets

Go to **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:

| Secret Name          | Description                                      |
|----------------------|--------------------------------------------------|
| `AWS_ACCESS_KEY_ID`  | IAM user access key (if using Option 1)          |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key (if using Option 1)       |
| `AWS_ROLE_ARN`       | IAM role ARN for OIDC (if using Option 2)        |
| `TF_STATE_BUCKET`    | S3 bucket name for Terraform state               |
| `AWS_KEY_PAIR_NAME`  | EC2 key pair name (e.g. `wellspan-demo-key`)     |

**Note:** Use either `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` **or** `AWS_ROLE_ARN`, not both.

#### B. Update Workflow for Static Credentials (if not using OIDC)

If using IAM user instead of OIDC, edit `.github/workflows/terraform-deploy.yml`:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ env.TF_VAR_aws_region }}
```

Remove or comment out the `role-to-assume` line.

---

## Local Development

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- AWS CLI configured (`aws configure`)

### Steps

1. **Create backend config** (from example):

   ```bash
   cd terraform
   cp backend.hcl.example backend.hcl
   ```

2. **Edit `backend.hcl`** with your S3 bucket and region:

   ```hcl
   bucket         = "your-terraform-state-bucket"
   key            = "demo/terraform.tfstate"
   region         = "us-east-1"
   dynamodb_table = "terraform-state-lock"  # optional
   ```

3. **Create `terraform.tfvars`**:

   ```hcl
   aws_region   = "us-east-1"
   project_name = "demo"
   instance_type = "t3.micro"
   key_name     = "your-key-pair-name"
   ```

4. **Initialize and apply**:

   ```bash
   terraform init -backend-config=backend.hcl
   terraform plan -var-file=terraform.tfvars
   terraform apply -var-file=terraform.tfvars
   ```

5. **Get the web URL**:

   ```bash
   terraform output web_url
   ```

---

## CI/CD Flow

1. Push to `main` or `master` (or run workflow manually)
2. GitHub Actions:
   - Configures AWS credentials
   - Runs `terraform init` with S3 backend
   - Runs `terraform plan` and `terraform apply`
3. Terraform provisions EC2 with user data
4. EC2 bootstrap installs Apache and serves the welcome page
5. Access the site at `http://<EC2_PUBLIC_IP>`

---

## Outputs

After deployment:

- **web_url**: `http://<public_ip>` – open in a browser
- **public_ip**: EC2 public IP
- **instance_id**: EC2 instance ID

---

## Cleanup

```bash
cd terraform
terraform destroy -var-file=terraform.tfvars
```

Or delete the stack from the AWS Console (EC2 instances, security groups, etc.).

---

## Summary of Manual Steps

| Where      | Action                                                                 |
|-----------|-------------------------------------------------------------------------|
| **AWS**   | Create EC2 key pair                                                     |
| **AWS**   | Create S3 bucket for Terraform state (with versioning)                  |
| **AWS**   | (Optional) Create DynamoDB table for state locking                      |
| **AWS**   | Create IAM user or OIDC role for GitHub Actions                         |
| **GitHub**| Add secrets: `TF_STATE_BUCKET`, `AWS_KEY_PAIR_NAME`, and AWS credentials |
| **GitHub**| Adjust workflow if using static credentials instead of OIDC              |
