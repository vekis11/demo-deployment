# Step-by-Step Deployment Guide

## Deploying a Web App to EC2 with AWS CodePipeline, CloudFormation, and CodeDeploy

This guide walks you through achieving a **fully automated path from code to a running EC2 workload**: a single code commit triggers AWS CodePipeline, which builds the app, relies on a CloudFormation-provisioned EC2 instance, and deploys the application using CodeDeploy. No manual server setup is required.

---

## Architecture Overview

```
[Code Commit] → [CodePipeline] → [CodeBuild] → [CodeDeploy] → [EC2]
                     ↑
              [CloudFormation]
              (provisions EC2 + CodeDeploy app/group)
```

1. **Source**: Code commit (CodeCommit or GitHub) triggers the pipeline.
2. **Build**: CodeBuild runs `buildspec.yml`, installs dependencies, and produces a deployment zip.
3. **Deploy**: CodeDeploy deploys the zip to EC2 instances that are tagged and managed by the deployment group.
4. **Infrastructure**: CloudFormation creates the EC2 instance, security group, IAM roles, CodeDeploy application, and deployment group.

---

## Prerequisites

- **AWS Account** with permissions for EC2, IAM, CodePipeline, CodeBuild, CodeDeploy, CloudFormation, S3, and (if using CodeCommit) CodeCommit.
- **AWS CLI** installed and configured (`aws configure`).
- **Git** installed.
- **EC2 Key Pair** in your region (for SSH access to the instance). Create one in EC2 → Key Pairs if needed.
- **Node.js 18+** (optional; only if you want to run the app locally before deploying).

---

## Step 1: Create the Code Repository

### Option A: AWS CodeCommit

1. In the AWS Console, go to **CodeCommit** → **Repositories** → **Create repository**.
2. Name it `demo-deployment` (or match the name you will use in the pipeline template).
3. Clone the repo locally (use HTTPS or SSH and install the credential helper if needed):
   ```bash
   git clone https://git-codecommit.<region>.amazonaws.com/v1/repos/demo-deployment demo-deployment-repo
   cd demo-deployment-repo
   ```
4. Copy all project files (app, `buildspec.yml`, `appspec.yml`, `scripts/`, `infrastructure/`) into this repo, then:
   ```bash
   git add .
   git commit -m "Initial commit: app and CI/CD config"
   git push -u origin main
   ```
   Use the branch name you will use in the pipeline (e.g. `main`).

### Option B: GitHub

1. Create a new GitHub repository (e.g. `demo-deployment`).
2. Clone it, copy in all project files, commit, and push to `main` (or your chosen branch).
3. You will use a **CodeStar Connection** in CodePipeline instead of CodeCommit (see Step 5).

---

## Step 2: Deploy Infrastructure (EC2 + CodeDeploy) with CloudFormation

This stack creates the EC2 instance, security group, IAM roles, CodeDeploy application, and deployment group. The EC2 instance has the CodeDeploy agent and Node.js installed via UserData.

1. Open **CloudFormation** in the AWS Console → **Create stack** → **With new resources**.
2. **Template**: Upload `infrastructure/cfn-ec2-codedeploy.yaml` (or provide its S3 URL if you upload it to S3).
3. **Stack name**: e.g. `demo-deployment-infra`.
4. **Parameters**:
   - **KeyName**: Select your existing EC2 key pair (required for SSH).
   - **InstanceType**: e.g. `t3.micro` (default).
5. **Create stack** and wait until status is **CREATE_COMPLETE**.
6. Note the **Outputs**:
   - `CodeDeployApplicationName` (e.g. `demo-deployment-app`)
   - `CodeDeployDeploymentGroupName` (e.g. `demo-deployment-dg`)
   - `InstanceId` (your EC2 instance)

Using AWS CLI:

```bash
aws cloudformation create-stack \
  --stack-name demo-deployment-infra \
  --template-body file://infrastructure/cfn-ec2-codedeploy.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=YOUR_KEY_PAIR_NAME \
  --capabilities CAPABILITY_NAMED_IAM
```

Wait for the stack to complete:

```bash
aws cloudformation wait stack-create-complete --stack-name demo-deployment-infra
```

---

## Step 3: Create the Pipeline with CloudFormation (CodeCommit)

If you use **CodeCommit**, deploy the pipeline stack so that a commit to the repo triggers the pipeline.

1. **CodeCommit repo** must already exist and contain the code (see Step 1 Option A).
2. In **CloudFormation** → **Create stack** → Upload `infrastructure/cfn-pipeline.yaml`.
3. **Stack name**: e.g. `demo-deployment-pipeline`.
4. **Parameters**:
   - **RepositoryName**: Your CodeCommit repo name (e.g. `demo-deployment`).
   - **BranchName**: Branch to deploy (e.g. `main`).
   - **InfrastructureStackName**: The name of the stack from Step 2 (e.g. `demo-deployment-infra`).
5. **Create stack** and wait for **CREATE_COMPLETE**.

Using AWS CLI:

```bash
aws cloudformation create-stack \
  --stack-name demo-deployment-pipeline \
  --template-body file://infrastructure/cfn-pipeline.yaml \
  --parameters \
    ParameterKey=RepositoryName,ParameterValue=demo-deployment \
    ParameterKey=BranchName,ParameterValue=main \
    ParameterKey=InfrastructureStackName,ParameterValue=demo-deployment-infra \
  --capabilities CAPABILITY_NAMED_IAM
```

---

## Step 4: Run the Pipeline (First Deployment)

1. Go to **CodePipeline** → open the pipeline **demo-deployment-pipeline**.
2. Click **Release change** to run the pipeline with the current commit.
3. Watch the stages: **Source** → **Build** → **Deploy**.
4. When **Deploy** succeeds, CodeDeploy has deployed the app to the EC2 instance.

If the pipeline is connected to CodeCommit, you can also trigger it by pushing a new commit:

```bash
git add .
git commit -m "Trigger deployment"
git push origin main
```

---

## Step 5: Using GitHub Instead of CodeCommit

The provided pipeline template uses CodeCommit. To use **GitHub**:

1. In **CodePipeline**, create a **new pipeline** (or edit the existing one).
2. **Source stage**:
   - Source provider: **GitHub (Version 2)**.
   - Connect to GitHub via **CodeStar Connections** (create a connection and authorize your GitHub account/repo).
   - Select repository and branch (e.g. `main`).
3. **Build stage**: Use the same CodeBuild project (e.g. `demo-deployment-build`) with input artifact from Source.
4. **Deploy stage**: Use **CodeDeploy**:
   - Application name: output `CodeDeployApplicationName` from your infra stack (e.g. `demo-deployment-app`).
   - Deployment group: output `CodeDeployDeploymentGroupName` (e.g. `demo-deployment-dg`).
   - Input artifact: output of the Build stage.

Alternatively, you can duplicate `cfn-pipeline.yaml` and replace the Source action with a GitHub (Version 2) action and CodeStar Connection ARN (parameterized). The rest of the flow (Build → CodeDeploy) stays the same.

---

## Step 6: Access the Application

1. In **EC2** → **Instances**, select the instance created by the infra stack.
2. Copy its **Public IPv4 address** (or use Public DNS).
3. Open in a browser: `http://<public-ip>:3000`
4. You should see the **Demo Deployment** page and a healthy status (the page calls `/health`).

If you don’t see the app:

- Ensure the security group allows **inbound TCP 3000** from your IP or `0.0.0.0/0` (as in the template).
- Wait 1–2 minutes after the first deployment for the CodeDeploy agent and UserData (Node.js install) to finish.
- Check CodeDeploy **Deployments** for the deployment status and any failure reasons.
- SSH into the instance (using your key pair) and check:
  - `sudo systemctl status codedeploy-agent`
  - `ls /home/ec2-user/demo-deployment`
  - `cat /var/log/demo-deployment.log`

---

## Step 7: End-to-End Flow (What Happens on Each Commit)

1. You push to the configured branch (e.g. `main`).
2. **CodePipeline** detects the change and starts a new execution.
3. **Source**: Pipeline pulls the latest code from CodeCommit (or GitHub).
4. **Build**: CodeBuild runs `buildspec.yml`:
   - `npm ci`
   - Creates `deploy-archive.zip` (app files, no `node_modules`) and publishes it as the pipeline artifact.
5. **Deploy**: CodeDeploy:
   - Uses the build artifact as the new revision.
   - Targets instances in the deployment group (tagged `CodeDeploy: demo-deployment`).
   - Runs lifecycle hooks: ApplicationStop → BeforeInstall → AfterInstall (e.g. `npm install --omit=dev`) → ApplicationStart → ValidateService (e.g. `/health` check).
6. The app runs on EC2 at `http://<instance-ip>:3000`.

No manual server configuration is required after the initial CloudFormation and pipeline setup.

---

## File Reference

| File / Folder        | Purpose |
|----------------------|--------|
| `server.js`          | Express app and `/health`, `/api/info` |
| `public/`            | Static front-end (HTML, CSS, JS) |
| `buildspec.yml`      | CodeBuild: install deps, create deployment zip |
| `appspec.yml`        | CodeDeploy: file mapping and lifecycle hooks |
| `scripts/*.sh`       | CodeDeploy hooks: stop, install, start, validate |
| `infrastructure/cfn-ec2-codedeploy.yaml` | CloudFormation: EC2, SG, IAM, CodeDeploy app/group |
| `infrastructure/cfn-pipeline.yaml`        | CloudFormation: CodePipeline + CodeBuild (CodeCommit source) |

---

## Troubleshooting

- **Pipeline fails at Source**: Check repo name, branch, and (for GitHub) CodeStar Connection status.
- **Build fails**: Check CodeBuild logs; ensure `buildspec.yml` and `package.json` are in the repo and valid.
- **Deploy fails**: In CodeDeploy, open the failed deployment and check the lifecycle event logs (e.g. AfterInstall, ApplicationStart, ValidateService). On the instance, check `/var/log/codedeploy-agent/` and `/var/log/demo-deployment.log`.
- **Instance not in deployment group**: EC2 must have tag `CodeDeploy` = `demo-deployment`; the template adds this. Ensure the infra stack completed and the instance is running.
- **App not responding on 3000**: Confirm security group allows port 3000; confirm Node is installed and the app was started (see logs and `ps aux \| grep node`).

---

## Summary

You now have:

- A **small web application** (Node.js + Express) with a simple UI and health check.
- **CloudFormation** to provision the EC2 instance and CodeDeploy application/group.
- **CodePipeline** to build and deploy on each commit.
- **CodeDeploy** to install and run the app on EC2 with no manual server setup.

A single code commit triggers the pipeline and, within minutes, results in a running EC2 workload.
