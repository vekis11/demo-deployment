# Demo Deployment – Code to EC2 in Minutes

A small Node.js web application and AWS CI/CD setup that takes you **from a single code commit to a running EC2 workload** with no manual server configuration.

## What This Does

- **Code commit** → **AWS CodePipeline** → **CodeBuild** (builds app) → **CodeDeploy** (deploys to EC2)
- **CloudFormation** provisions the EC2 instance (with Node.js and CodeDeploy agent) and the CodeDeploy application and deployment group.
- No hardware setup, no manual server setup—just push code and get a live app in minutes.

## Simple Deployment (Cordea-Weespan Welcome Page)

For a **minimal one-stack deployment** that shows "Welcome to Cordea-Weespan Mentorship Program" on a web link:

1. Deploy: `infrastructure/cfn-simple-web.yaml` via CloudFormation
2. Use the stack **Outputs** → **WebURL** in your browser

See **[docs/SIMPLE-DEPLOYMENT.md](docs/SIMPLE-DEPLOYMENT.md)** for step-by-step instructions.

---

## Quick Start (Local)

```bash
npm install
npm start
```

Open [http://localhost:3000](http://localhost:3000).

## Deploying to AWS

See **[docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md)** for the full step-by-step guide. In short:

1. Create a CodeCommit (or GitHub) repo and push this code.
2. Deploy the infrastructure stack: `infrastructure/cfn-ec2-codedeploy.yaml` (EC2 + CodeDeploy).
3. Deploy the pipeline stack: `infrastructure/cfn-pipeline.yaml` (CodePipeline + CodeBuild), pointing at your repo and infra stack.
4. Run the pipeline (or push a commit); CodeDeploy deploys the app to EC2.
5. Open `http://<ec2-public-ip>:3000`.

## Repo Layout

- `server.js`, `public/` – Web app (Express + static UI)
- `buildspec.yml` – CodeBuild build and artifact
- `appspec.yml`, `scripts/` – CodeDeploy lifecycle hooks
- `infrastructure/` – CloudFormation templates (EC2 + pipeline)
- `docs/DEPLOYMENT-GUIDE.md` – Step-by-step deployment guide

## Tech Stack

- **App**: Node.js, Express
- **AWS**: CodePipeline, CodeBuild, CodeDeploy, CloudFormation, EC2
