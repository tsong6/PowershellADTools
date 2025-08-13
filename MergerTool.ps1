# Created by Taehoon Song 1/10/25
# This tool will merge all .xls files into a master file spreadsheet. 

# Set the folder path containing the Excel files
$folderPath = "xxx"

# Set the folder path where the master file will save. 
$masterPath = "xxx"

# Generate a new master file name with timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$masterFile = "$masterPath\MasterSheet_$timestamp.xlsx"

# Create an Excel application object
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false
$Excel.DisplayAlerts = $false

# Create a new workbook for the master sheet
$MasterWorkbook = $Excel.Workbooks.Add()
$MasterSheet = $MasterWorkbook.Sheets.Item(1)
$CurrentRow = 1

# Loop through each file in the folder
Get-ChildItem -Path $folderPath -Filter "*.xls*" | ForEach-Object {
    $filePath = $_.FullName
    Write-Host "Processing file: $filePath"
    
    # Open the current workbook
    $CurrentWorkbook = $Excel.Workbooks.Open($filePath)
    $CurrentSheet = $CurrentWorkbook.Sheets.Item(1)  # Assuming data is in the first sheet
    
    # Get the used range of the current sheet
    $UsedRange = $CurrentSheet.UsedRange
    $RowCount = $UsedRange.Rows.Count
    $ColCount = $UsedRange.Columns.Count

    # Copy data from the current sheet to the master sheet
    $SourceRange = $CurrentSheet.Range("A1").Resize($RowCount, $ColCount)
    $TargetRange = $MasterSheet.Cells.Item($CurrentRow, 1)
    $SourceRange.Copy($TargetRange)
    
    # Update the current row in the master sheet
    $CurrentRow += $RowCount

    # Close the current workbook
    $CurrentWorkbook.Close($false)
}

# Save the master workbook
$MasterWorkbook.SaveAs($masterFile)
$MasterWorkbook.Close()

# Open the newly created master workbook
$NewMasterWorkbook = $Excel.Workbooks.Open($masterFile)
$Excel.Visible = $true  # Make Excel visible for the user to see the workbook

Write-Host "Master sheet created and opened: $masterFile"