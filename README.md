[![Deploy ▶](https://img.shields.io/badge/Deploy-%E2%96%B6%EF%B8%8F-blue?style=flat-square)](https://github.com/colin-coates/Jewels/actions/workflows/autodeploy.yml)
# Jewels AutoDeploy

Containerized auto-deploy agent that can push files/configs to Azure File Share, Cloudflare, GitHub, Shopify, etc.

This scaffold is preconfigured for:
- naming prefix = "jewels"
- environment token = "staging"
- resource group name = "TeraJewels" (Terraform will use this explicit RG)

Quick start
1. Ensure scaffold files are in this directory.
2. Make the helper script executable:
   chmod +x create_and_push.sh
3. Ensure you have the GitHub CLI (gh) and Azure CLI (az) installed and authenticated.
4. To push this scaffold in a branch and open a PR:
   git checkout -b init/scaffold
   git add .
   git commit -m "chore(scaffold): initial auto-deploy agent scaffold"
   git remote add origin git@github.com:colin-coates/Jewels.git   # if not already added
   git push --set-upstream origin init/scaffold
   gh pr create --base main --head init/scaffold --title "Init scaffold" --body "Initial scaffold for Jewels AutoDeploy"

Secrets to add to the repo (Settings → Secrets → Actions)
- AZURE_CREDENTIALS  (output from: az ad sp create-for-rbac --sdk-auth)
- AZURE_SUBSCRIPTION_ID
- GHCR_PAT (or configure repo Actions permissions for package write)
- (Optional) CLOUDFLARE_API_TOKEN
- (Optional) SHOPIFY_ADMIN_API_TOKEN

Security note
- Use AZURE_CREDENTIALS with least privilege (scoped to the RG if you create it).
- Avoid storing account keys in repo files. Use secrets or SAS tokens.
