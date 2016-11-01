#Save Solution
#Description:
#Notes:

$solution = Get-SPSolution -Identity <solutioname.wsp>
$solution.SolutionFile.SaveAs("<path>")
