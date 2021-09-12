$getVMName = $args[0]
$getResourceGroup = $args[1]
$OFS = "`r`n"
$DeploymentScriptOutputs = @{}
try {
    $output = "VM Name={0}, and ResourceGroup={1}" -f $getVMName, $getResourceGroup
    $output = $output + $OFS + "Ganesh Verkala"
    #Write-Output $output
}
catch {
    $output = $output + $OFS + "Error Message: $_"
}
Finally {
    $DeploymentScriptOutputs['text'] = $output
}
