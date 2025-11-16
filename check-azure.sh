#!/usr/bin/env bash
set -euo pipefail

SUBSCRIPTION="9ae423ba-c159-4d2e-a1df-7bcf79314e40"
RESOURCE_GROUP="rg-jewels-eastus"
APP_NAME="jewels-webhook-func"

echo; echo ">>> START: login (SP if CLIENT_* env vars present, otherwise interactive)"; echo

if [[ -n "${CLIENT_ID:-}" && -n "${CLIENT_SECRET:-}" && -n "${TENANT_ID:-}" ]]; then
  echo "Using service principal login (CLIENT_ID present)"
  az login --service-principal -u "$CLIENT_ID" -p "$CLIENT_SECRET" --tenant "$TENANT_ID" || true
else
  echo "No CLIENT_* env vars detected — performing interactive az login (opens browser)"
  az login || true
fi

echo; echo ">>> az account show"; echo
az account show --query "{id:id,name:name,tenantId:tenantId}" -o json || true

echo; echo ">>> az resource show (app)"; echo
az resource show \
  --subscription "$SUBSCRIPTION" \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_NAME" \
  --resource-type "Microsoft.Web/sites" -o json || true

echo; echo ">>> az functionapp / webapp show (detailed)"; echo
az functionapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" -o json || az webapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" -o json || true

echo; echo ">>> app settings (may timeout if control plane is unavailable)"; echo
az functionapp config appsettings list --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" -o json || az webapp config appsettings list --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" -o json || true

echo; echo ">>> restarting the app (best-effort)"; echo
az functionapp restart --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION" || az webapp restart --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION" || true

echo; echo ">>> waiting 8s then checking app state"; echo
sleep 8
az functionapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION" --query "{state:state,usage:usage}" -o json || az webapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION" --query "{state:state}" -o json || true

echo; echo ">>> attempting a small test zip deploy (will create /tmp/jewels-test-deploy.zip)"; echo
TMPZIP="/tmp/jewels-test-deploy.zip"
rm -f "$TMPZIP"
mkdir -p /tmp/jewels-test-deploy && printf "test" > /tmp/jewels-test-deploy/index.html
( cd /tmp/jewels-test-deploy && zip -r "$TMPZIP" . >/dev/null )
echo "-> zip size: $(stat -f%z "$TMPZIP" 2>/dev/null || stat -c%s "$TMPZIP") bytes"

echo; echo ">>> running zip deploy (this will reproduce zip-deploy errors)"; echo
az webapp deployment source config-zip \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_NAME" \
  --src "$TMPZIP" \
  --subscription "$SUBSCRIPTION" -o json || true

echo; echo ">>> attempt fetching deployment logs (best-effort)"; echo
az webapp log deployment show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION" || true

echo; echo ">>> cleanup local tmp zip"; echo
rm -rf /tmp/jewels-test-deploy /tmp/jewels-test-deploy.zip || true

echo; echo ">>> END"
