$getVMName = $args[0]
$getResourceGroup = $args[1]
$output = "VM Name={0}, and ResourceGroup={1}" -f $getVMName, $getResourceGroup
Write-Output $output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $output
 
