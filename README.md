```markdown
# Jewels AutoDeploy

Containerized auto-deploy agent that can push files/configs to Azure File Share, Cloudflare, GitHub, Shopify, etc.

This scaffold is preconfigured for:
- naming prefix = "jewels"
- environment token = "staging"
- resource group name = "TeraJewels" (Terraform will use this explicit RG)

What to do next (quick)

1. Save these files into a local directory.
2. Make the helper script executable:
   chmod +x create_and_push.sh
3. Ensure you have the GitHub CLI (gh) and Azure CLI (az) installed and authenticated.
4. Run:
   ./create_and_push.sh

This will:
- create the private repo `colin-coates/jewels-auto-deploy` (using gh),
- push branch `init/scaffold`,
- open a PR into `main`.

Secrets to add to the repo (Settings → Secrets → Actions)
- AZURE_CREDENTIALS  (output from: az ad sp create-for-rbac --sdk-auth)
- AZURE_SUBSCRIPTION_ID
- GHCR_PAT (or configure repo Actions permissions for package write)
- (Optional) CLOUDFLARE_API_TOKEN
- (Optional) SHOPIFY_ADMIN_API_TOKEN

Security note
- Use AZURE_CREDENTIALS with least privilege (scoped to the RG if you create it).
- Avoid storing account keys in repo files. Use secrets or SAS tokens.
```
