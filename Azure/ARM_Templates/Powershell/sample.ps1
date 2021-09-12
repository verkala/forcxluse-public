$OFS = "`r`n"
try {
    $getVMName = $args[0]
    $getResourceGroup = $args[1]
    $output = $output + $OFS + "VM Name={0}, and ResourceGroup={1}" -f $getVMName, $getResourceGroup
    $output = $output + $OFS + "Ganesh Verkala"
    #Write-Output $output
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs['text'] = $output
}
catch {
    $output = $output + $OFS + "Error Message: $_"
}
