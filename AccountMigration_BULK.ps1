# Highend2iLogin_BULK.ps1 - 05.29.25
# See the README.txt for instructions on how to use. 

# Prompt for CSV file path
$csvPath = "xxx"

# Import CSV
$users = Import-Csv -Path $csvPath

# OU Path and Groups
$ouPath = "XXX"
$groups = 'xxx', 'xxx', 'xxx'
$primaryGroup = Get-ADGroup "XXX" -Properties primaryGroupToken
$primaryGroupID = $primaryGroup.primaryGroupToken
$domainUsers = "xxx"

foreach ($userEntry in $users) {
    $netID = $userEntry.netID
    $tla = $userEntry.tla
    $appendTLA = " ($tla)"

    Write-Host "Processing $netID..."

    # Get the user object
    $user = Get-ADUser -Filter { sAMAccountName -eq $netID } -Properties Name, DistinguishedName, MemberOf

    if ($user) {
        # Rename CN/Name if not already renamed
        if ($user.Name -notlike "*$appendTLA*") {
            $newName = "$($user.Name)$appendTLA"
            Rename-ADObject -Identity $user.DistinguishedName -NewName $newName
            Write-Host "Renamed: $($user.Name) -> $newName"
        } else {
            Write-Host "Skipped rename: Already contains $appendTLA"
        }

        # Remove from all current groups
        Get-ADUser -Identity $netID -Properties MemberOf | ForEach-Object {
            $_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false
        }

        # Add to required groups
        foreach ($group in $groups) {
            Add-ADGroupMember -Identity $group -Members $netID
        }

        # Wait briefly for replication (optional)
        Start-Sleep -Seconds 2

        # Set primary group
        Set-ADUser -Identity $netID -Replace @{primaryGroupID = $primaryGroupID}

        # Remove from Domain Users
        Remove-ADGroupMember -Identity $domainUsers -Members $netID -Confirm:$false

        # Clear attributes
        Set-ADUser -Identity $netID -Clear extensionAttribute10,scriptPath,HomeDirectory,HomeDrive

        # Update mail attribute
        $mail = "xxx@xxx.com"
        Set-ADUser -Identity $netID -EmailAddress $mail

        # Move to iLogin OU
        $aduser = Get-ADUser $netID
        Move-ADObject -Identity $aduser -TargetPath $ouPath

        Write-Host "Account for $netID has been converted to iLogin." -ForegroundColor Green
    } else {
        Write-Host "User not found." -ForegroundColor Red
    }
}
