$getVMName = $args[0]
$getResourceGroup = $args[1]
$OFS = "`r`n"
$DeploymentScriptOutputs = @{}
try {
    $output = "VM Name={0}, and ResourceGroup={1}" -f $getVMName, $getResourceGroup
    $output = $output + $OFS + "Ganesh Verkala"
}
catch {
    $output = $output + $OFS + "Error Message: $_"
}
Finally {
    Write-Output $output
    $DeploymentScriptOutputs['text'] = $output
}
