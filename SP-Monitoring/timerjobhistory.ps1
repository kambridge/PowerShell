# Initial settings

$Wa = Get-SPWebApplication "<webappurl>"    # Supply the web app url here

$From= "6/12/2016 7:30:00 PM"  # mm/dd/yyyy hh:mm:ss

$To = "6/12/2016 10:00:00 PM"

# Retrieve all jobs in the time range

Write-Host "Listing all timer jobs that have run between $From to $To and storing it in CSV format" -ForeGroundColor Blue

$Wa.JobHistoryEntries | Where-Object {($_.StartTime -gt $From) -and ($_.StartTime -lt $To)} | Export-Csv TimerJobHistory.csv –NoType

Write-Host "Done.." -ForeGroundColor Green

# Retrieve all failed jobs in the time range

Write-Host "Listing all timer jobs that have failed to run between $From to $To and storing it in CSV format" -ForeGroundColor Red

$Wa.JobHistoryEntries | Where-Object {($_.StartTime -gt $From) -and ($_.To -lt $To) -and ($_.Status -ne ‘Succeeded‘)} | Export-Csv FailedTimerJobHistory.csv –NoType

Write-Host "Done.." -ForeGroundColor Green
