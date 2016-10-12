#This cmdlet reaches out and collects the ULS logs from all servers in the farm using your Correlation ID error.
#open the log file with ULS Viewer

Merge-splogfile -path ".\error.log" -correlation "<corrid>"



