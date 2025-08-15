# _ExternalUserLookup.ps1 by Taehoon - 2025.03.26
# Searches Azure(Entra) for UPNs with specific keywords and AD for vendor accounts. Used for looking up extneral accounts in both active and guest users. 

$keyword = Read-Host "Enter keyword to search"

# Azure search
Connect-AzureAD
Get-AzureADUser -All $true | Where-Object { $_.UserPrincipalName -match $keyword } | Select-Object DisplayName, UserPrincipalName

# AD Search
$EmailDomain = "*" + $keyword + "*"
Get-ADUser -SearchBase 'dc=xxx,dc=xxx,dc=xxx' -Properties * -Filter {Emailaddress -like $EmailDomain} | Select displayname, Enabled, samaccountname, emailaddress # replace XXX with domain controller
