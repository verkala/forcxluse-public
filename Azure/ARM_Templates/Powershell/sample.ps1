param([string] $getVMName, [string] $getResourceGroup)
#param([string] $getResourceGroup)
$output = "VM Name={0}, and ResourceGroup={1}" -f $getVMName, $getResourceGroup
Write-Output $output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $output
