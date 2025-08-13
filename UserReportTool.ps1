# UserReportTool.ps1 - 1/4/23 - tzs
# Unified tool for generating user report for specified AD groups and removing users from specified group. 


function Get-xxxUsers1 {
    Write-Host "Retreiving xxx list..."
    $date = (Get-Date -Format yyyyMMdd).ToString()
    $Outfile="xxx" +"_" + $date + ".csv" #specify where you want the report to save. 
    $groups=get-adgroup -Filter {name -eq 'xxx'} #specify group to grab
    foreach($group in $groups){
	    $members=Get-ADGroupMember $group 
        Foreach($member in $members){
            get-aduser $member -properties * | select EmailAddress, enabled, samaccountname, DisplayName | export-csv $Outfile -Append
	    }
    }
    Write-Host "Done! List saved in XXX"
}

function Get-xxxUsers2 {
    Write-Host "Retreiving email-SEND list..."
    $date = (Get-Date -Format yyyyMMdd).ToString()
    $Outfile="XXX" +"_" + $date + ".csv"#specify where you want the report to save.
    $groups=get-adgroup -Filter {name -eq 'xxx'} #specify group to grab
    foreach($group in $groups){
	    $members=Get-ADGroupMember $group 
        Foreach($member in $members){
            get-aduser $member -properties * | select EmailAddress, enabled, samaccountname, DisplayName | export-csv $Outfile -Append
	    }
    }
    Write-Host "Done! List saved in xxx"
}

function Get-xxxUsers3 {
    Write-Host "Retreiving email-RECEIVE list..."
    $date = (Get-Date -Format yyyyMMdd).ToString()
    $Outfile="xxx" +"_" + $date + ".csv" #specify where you want the report to save
    $groups=get-adgroup -Filter {name -eq 'xxx'} # group to grab
    foreach($group in $groups){
	    $members=Get-ADGroupMember $group 
        Foreach($member in $members){
            get-aduser $member -properties * | select EmailAddress, enabled, samaccountname, DisplayName | export-csv $Outfile -Append
	    }
    }
    Write-Host "Done! List saved in xxx"
}

#Removes all mimecast block AD Groups for single user
function Remove-MultipleGroups{
    
    #Enter Net ID to remove
    $User = Read-Host "Pleae enter NETID: "

    Remove-ADGroupMember -Identity xxx -Members $user -Confirm:$false
    Remove-ADGroupMember -Identity xxx -Members $user -Confirm:$false
    Remove-ADGroupMember -Identity xxx -Members $user -Confirm:$false

    Write-Host "Done! Please allow a few minutes for the changes to apply."
}

function Show-Menu {
    Write-Host "#xxx#" #Title of program
    Write-Host "1: Get xxxUser1 list"
    Write-Host "2: Get xxxUser2 list"
    Write-Host "3: Get xxxUser3 list"
    Write-Host "r: Remove groups"
    Write-Host "q: Press 'q' to quit."

}

do {
    Clear-Host
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        '1' {
            Get-xxxUsers1
        } '2' {
            Get-xxxUsers2
        } '3' {
            Get-xxxUsers3
        } 'r' {
            Remove-MultipleGroups
        }



    }
    pause
}
until ($selection -eq 'q')
