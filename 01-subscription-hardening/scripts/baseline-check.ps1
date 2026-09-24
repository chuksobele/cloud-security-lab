<#
.SYNOPSIS
    Read-only baseline checks against an Azure subscription.
.DESCRIPTION
    Collects evidence for the hardening checklist in README.md. Makes no changes.
    Requires the Az PowerShell module and an authenticated session (Connect-AzAccount).
.EXAMPLE
    ./baseline-check.ps1 -SubscriptionId "<id>" | Tee-Object baseline.txt
#>
param(
    [Parameter(Mandatory = $true)][string]$SubscriptionId
)

$ErrorActionPreference = 'Stop'
Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

function Section($t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }

Section "Subscription"
Get-AzContext | Select-Object -ExpandProperty Subscription | Format-List Name, Id, TenantId

Section "Owner role assignments at subscription scope"
Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" |
    Where-Object { $_.RoleDefinitionName -in @('Owner', 'User Access Administrator') } |
    Select-Object DisplayName, SignInName, RoleDefinitionName, Scope |
    Format-Table -AutoSize

Section "Storage accounts - public access and secure transfer"
Get-AzStorageAccount | Select-Object `
    StorageAccountName,
    @{n = 'ResourceGroup'; e = { $_.ResourceGroupName } },
    @{n = 'HttpsOnly'; e = { $_.EnableHttpsTrafficOnly } },
    @{n = 'AllowsPublicBlob'; e = { $_.AllowBlobPublicAccess } },
    @{n = 'MinTls'; e = { $_.MinimumTlsVersion } },
    @{n = 'PublicNetworkAccess'; e = { $_.PublicNetworkAccess } } |
    Format-Table -AutoSize

Section "Network security groups - rules open to the internet"
Get-AzNetworkSecurityGroup | ForEach-Object {
    $nsg = $_
    $nsg.SecurityRules | Where-Object {
        $_.Direction -eq 'Inbound' -and $_.Access -eq 'Allow' -and
        ($_.SourceAddressPrefix -in @('*', '0.0.0.0/0', 'Internet'))
    } | Select-Object `
        @{n = 'NSG'; e = { $nsg.Name } },
        Name, Priority, DestinationPortRange, Protocol, SourceAddressPrefix
} | Format-Table -AutoSize

Section "Disks - encryption"
Get-AzDisk | Select-Object Name, @{n='Encryption';e={$_.Encryption.Type}} | Format-Table -AutoSize

Section "Key vaults - purge and soft delete protection"
Get-AzKeyVault | ForEach-Object { Get-AzKeyVault -VaultName $_.VaultName } |
    Select-Object VaultName, EnableSoftDelete, EnablePurgeProtection, PublicNetworkAccess |
    Format-Table -AutoSize

Section "Activity Log diagnostic settings (subscription scope)"
Get-AzDiagnosticSetting -ResourceId "/subscriptions/$SubscriptionId" -ErrorAction SilentlyContinue |
    Select-Object Name, WorkspaceId | Format-Table -AutoSize

Section "Azure Policy - non-compliant resources (top 20)"
Get-AzPolicyState -Filter "ComplianceState eq 'NonCompliant'" -Top 20 |
    Select-Object PolicyDefinitionName, ResourceId | Format-Table -AutoSize

Write-Host "`nComplete. Save this output to evidence/." -ForegroundColor Green
