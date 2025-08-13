#HighendUserCreationTemplate_2025.07.21.ps1 by Taehoon Song
#Used for new account creations. Will search by ID; if user exists, it'll move the account to specified OU and add the appropriate groups. If user doesn't exist, then it'll start the account creation. 
#If you'd like to change the script for another location, please update lines 14,17 , 20-24, and 27-28. Thank you! 
### See README.txt. for additional information! ###

#Ask for basic info
$firstname = Read-Host "First name?"
$prefName = Read-Host "Preferred name?"
$lastname = Read-Host "Last name? "
$netID = Read-Host "Please enter ID:"
$aduser = Get-ADUser $netID

####Enter TLA###
$tla = "" 
###Enter ###
$hub = '' #do not use this line if TLA = hub.


###Address information###
$Address1 = ""
$City1 = ""
$State = ""
$Zip = ""
$office = ""
$POBox = ""

###OU path###
$ouPath = "OU=" + $tla + ",OU=" + $hub + ",OU=xxx,DC=xxx,DC=xxx,DC=xxx" ###Use this line if TLA != HUB 
$ouPath = "OU=" + $tla + ",OU=xxx,DC=xxx,DC=xxx,DC=xxx" ###Use this line if TLA = HUB. 

#Set display name
$displayName = $lastname + ", " + $prefName

#user information
$highendUser = $tla + "_HighendUsers"
$homedirectory = "xxx" 
$groups = #specify groups
$groups2 = #specify groups 

#H:drive Path
$HDrive = #home drive path
$FullQualName = #enter Full Qualified Name

#Set folder permission
function Set-folderPerm{
    $acl = Get-Acl $homedirectory

    #Set permission to Modify
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($FullQualName,"Modify","ContainerInherit,ObjectInherit", "None","Allow")
    $acl.SetAccessRule($AccessRule)
    $acl | Set-Acl $homedirectory
}


#Moves existing account to the target OU. 
function Move-aduser{
    
    #Set profil
    Set-ADUser -Identity $netID -PasswordNeverExpires $false -CannotChangePassword $false -ChangePasswordAtLogon $false -ScriptPath xxx -Company "xxx" -HomeDirectory $homedirectory -HomeDrive H -DisplayName $displayName
    
    #Remove all current AD groups
    Get-ADUser -Identity $netID -Properties MemberOf | ForEach-Object {
        $_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false
    }

    #Add AD groups
    foreach($group in $groups){
        Add-ADGroupMember -Identity $group -Members $netID
    }
    
    #Internet?
    $Internet = Read-Host "Internet? [Y/N]"
    if ($Internet -eq "y" -or $Internet -eq "Y"){
        Add-ADGroupMember -Identity xxx -Members $netID
        Add-ADGroupMember -Identity xxx -Members $netID
    }  
    
    #Update Primary group membership
    $primarygroup = get-adgroup "xxx" -properties @("primaryGroupToken")
    Get-ADuser $netID | set-aduser -replace @{primaryGroupID=$primarygroup.primaryGroupToken}
    
    #Set attribute 1, 10, and 11.
    Set-ADUser -Identity $netID -Replace @{extensionAttribute1="$prefName"} 
    Set-ADUser -Identity $netID -Add @{extensionAttribute10="xxx"}
    Set-ADUser -Identity $netID -Add @{extensionAttribute11="xxx"}
        
    #Set PW
    $complexPW = Read-Host "Enter complex PW:"
    Set-ADAccountPassword -Identity $netID -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $complexPW -Force)
    
    #Remove AD group(s)
    Remove-ADGroupMember -Identity xxx -Members $netID -Confirm:$false
    
    #Set Employment Status
    $employmentStatus =  Read-Host "Hourly (H), or Salaried (S)? "

    #Hourly
    if ($employmentStatus -eq "H" -or $employmentStatus -eq "h"){
        Set-ADUser -Identity $netID -Replace @{employeeType="xxx"}  
        Add-ADGroupMember -Identity "xxx" -Members $netID
    }

    #Salaried
    else{
        Set-ADUser -Identity $netID -Replace @{employeeType="xxx"}
        Add-ADGroupMember -Identity "xxx" -Members $netID
    }

    #Move account to OU. 
    Move-ADObject -Identity $aduser -TargetPath $ouPath

    
}

function New-User{
    $department = Read-Host "Department?"
    $jobTitle = Read-Host "Job Title?"
   
    $employmentStatus =  Read-Host "Contractor (C), Hourly (H), or Salaried (S)?"

    #If user is a contractor:
    if ($employmentStatus -eq "C" -or $employmentStatus -eq "c"){
        New-ADUser -Name $netID -Path $ouPath -Surname $lastname -GivenName $firstname -DisplayName $displayName -Title $jobTitle -PasswordNeverExpires $false -CannotChangePassword $false  -Department $department -UserPrincipalName "xxx" -StreetAddress $Address1 -POBox $POBox -City $City1 -State $State -PostalCode $Zip -ScriptPath xxx -HomeDirectory $homedirectory -HomeDrive H -Company "Contractor" -Office $office
        Start-Sleep -Seconds 30
        #Set ExtensionType.
        Set-ADUser -Identity $netID -Add @{employeeType="xxx"}
        Add-ADGroupMember -Identity "xxx" -Members $netID
        
    }
    #If Employee
    else{
        New-ADUser -Name $netID -Path $ouPath -Surname $lastname -GivenName $firstname -DisplayName $displayName -Title $jobTitle -PasswordNeverExpires $false -CannotChangePassword $false  -Department $department -UserPrincipalName "xxx" -StreetAddress $Address1 -POBox $POBox -City $City1 -State $State -PostalCode $Zip -ScriptPath xxx -HomeDirectory $homedirectory -HomeDrive H -Company "xxx" -Office $office
        Start-Sleep -Seconds 30
        #Hourly
        if ($employmentStatus -eq "H" -or $employmentStatus -eq "h"){
        Set-ADUser -Identity $netID -Add @{employeeType="HOURLY"}  
        Add-ADGroupMember -Identity "xxx" -Members $netID
        }
        #Salaried
        else{
            Set-ADUser -Identity $netID -Add @{employeeType="xxx"}
            Add-ADGroupMember -Identity "xxx" -Members $netID
        }
    }
    #Add AD groups
    foreach($group in $groups2){
        Add-ADGroupMember -Identity $group -Members $netID 
    }
    
    #set Primary group
    $primarygroup = get-adgroup "xxx" -properties @("primaryGroupToken")
    Get-ADuser $netID | set-aduser -replace @{primaryGroupID=$primarygroup.primaryGroupToken}

    #Internet?
    $Internet = Read-Host "Internet? [Y/N]"
    if ($Internet -eq "y" -or $Internet -eq "Y"){
        Add-ADGroupMember -Identity xxx -Members $netID
        Add-ADGroupMember -Identity xxx -Members $netID
    }

    
    #Set PW
    $complexPW = Read-Host "Enter complex PW"
    Set-ADAccountPassword -Identity $netID -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $complexPW -Force)
    Set-AdUser -Identity $netID -ChangePasswordAtLogon $true

    Enable-ADAccount -Identity $netID

    #Set attribute 1, 10, and 11.
    Set-ADUser -Identity $netID -Add @{extensionAttribute1="$prefName"}
    Set-ADUser -Identity $netID -Add @{extensionAttribute10="xxx"}
    Set-ADUser -Identity $netID -Add @{extensionAttribute11="xxx"

}
}


#If user already exists...
Try{
    Get-ADuser $netID -ErrorAction Stop
    Write-Host "user exists"
    $continue = Read-Host "Continue? [Y/N]"
    if ($continue -eq "Y" -or $continue -eq "y"){
        Move-aduser
        Start-Sleep -Seconds 30
    }       
}

#Brand new user

#Continue if user doesn't exist already
Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
    Write-Host "user doesn't exist"
    $continue = Read-Host "Continue? [Y/N]"
    if ($continue -eq "Y" -or $continue -eq "y"){      
        New-user
        Start-Sleep -Seconds 30
    }
}
#Make H:drive
New-Item -Path $HDrive -Name $netID -ItemType "directory"

#Set H:drive permissions
Set-folderPerm

#Update CN (added 8/9/24)
$userCNUpdate = Get-ADUser -Identity $netID -Properties DistinguishedName
Rename-ADObject -Identity $userCNUpdate.DistinguishedName -NewName $displayName


#Completion Message
Write-Host "done"
Write-Host "Please double check the account for errors and make the appropriate changes. (Don't forget to sign into the portal with the ID if the account already existed)!" 