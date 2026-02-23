# Simple Web Deployment – Cordea-Weespan Mentorship Program

Deploy a single-page welcome message to EC2 using **one CloudFormation template**. No CodePipeline, no CodeBuild, no CodeDeploy—just EC2 + Apache serving static HTML.

---

## What You Get

- **EC2 instance** (t3.micro) with Apache httpd
- **Static HTML page** showing: *"Welcome to Cordea-Weespan Mentorship Program"*
- **Public URL**: `http://<ec2-public-ip>` (port 80)

---

## Prerequisites

1. **AWS Account** with permissions for EC2, CloudFormation
2. **AWS CLI** installed and configured (`aws configure`)
3. **EC2 Key Pair** in your region (for SSH; required by the template)

### Create a Key Pair (if needed)

1. Go to **EC2** → **Key Pairs** → **Create key pair**
2. Name it (e.g. `my-key`) and download the `.pem` file
3. Note the exact name—you’ll use it when deploying the stack

---

## Deployment Steps

### Step 1: Deploy the CloudFormation Stack

**Option A: AWS Console**

1. Open **CloudFormation** → **Create stack** → **With new resources**
2. **Template**: Upload `infrastructure/cfn-simple-web.yaml`
3. **Stack name**: e.g. `cordea-weespan-web`
4. **Parameters**:
   - **KeyName**: Select your EC2 key pair
5. Click **Create stack**
6. Wait until status is **CREATE_COMPLETE** (about 2–3 minutes)

**Option B: AWS CLI**

```bash
aws cloudformation create-stack \
  --stack-name cordea-weespan-web \
  --template-body file://infrastructure/cfn-simple-web.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=YOUR_KEY_PAIR_NAME
```

Replace `YOUR_KEY_PAIR_NAME` with your key pair name (e.g. `my-key`).

Wait for the stack to finish:

```bash
aws cloudformation wait stack-create-complete --stack-name cordea-weespan-web
```

---

### Step 2: Get the Web URL

**Option A: AWS Console**

1. Open the stack **cordea-weespan-web**
2. Go to the **Outputs** tab
3. Copy the **WebURL** value (e.g. `http://54.123.45.67`)

**Option B: AWS CLI**

```bash
aws cloudformation describe-stacks \
  --stack-name cordea-weespan-web \
  --query "Stacks[0].Outputs[?OutputKey=='WebURL'].OutputValue" \
  --output text
```

---

### Step 3: Open the Page

Paste the **WebURL** into your browser. You should see:

**Welcome to Cordea-Weespan Mentorship Program**

---

## Summary of Files

| File | Purpose |
|------|---------|
| `infrastructure/cfn-simple-web.yaml` | CloudFormation template (EC2 + Apache + HTML) |
| `public/welcome.html` | Same HTML content (for reference/local use) |

---

## Cleanup

To remove the stack and stop charges:

```bash
aws cloudformation delete-stack --stack-name cordea-weespan-web
```

---

## Troubleshooting

- **Can’t connect**: Wait 2–3 minutes after stack creation for Apache to start.
- **Wrong key pair**: Ensure the key pair exists in the same region as the stack.
- **404 or connection refused**: Check EC2 → Instances → your instance → Security group allows inbound TCP port 80.
