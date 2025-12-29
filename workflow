# =====================================================
# AZURE AUTOMATION BOOTSTRAP
# Run ONCE as Global Admin
# =====================================================

param (
    [string]$SubscriptionId = "<YOUR_SUBSCRIPTION_ID>",
    [string]$ResourceGroup  = "rg-project-os",
    [string]$Location       = "eastus",
    [string]$AutomationName = "aa-project-os"
)

# -----------------------------
# LOGIN
# -----------------------------
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId

# -----------------------------
# RESOURCE GROUP
# -----------------------------
if (-not (Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $ResourceGroup -Location $Location
}

# -----------------------------
# AUTOMATION ACCOUNT
# -----------------------------
$automation = New-AzAutomationAccount `
    -Name $AutomationName `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -AssignSystemIdentity `
    -Plan Basic

# -----------------------------
# ENABLE POWERSHELL 7.2
# -----------------------------
Register-AzAutomationRuntimeEnvironment `
    -ResourceGroupName $ResourceGroup `
    -AutomationAccountName $AutomationName `
    -Name "PowerShell72" `
    -Language PowerShell `
    -Version "7.2"

# -----------------------------
# RBAC ASSIGNMENTS
# -----------------------------
$identity = $automation.Identity.PrincipalId

# Contributor (for provisioning)
New-AzRoleAssignment `
    -ObjectId $identity `
    -RoleDefinitionName "Contributor" `
    -Scope "/subscriptions/$SubscriptionId"

# -----------------------------
# OUTPUT
# -----------------------------
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host " Azure Automation READY" -ForegroundColor Green
Write-Host " Account: $AutomationName"
Write-Host " Identity: $identity"
Write-Host "====================================="
