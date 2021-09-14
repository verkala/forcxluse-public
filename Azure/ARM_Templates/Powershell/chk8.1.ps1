# Global variables
$getVMName = $args[0]
$getResourceGroup = $args[1]
$OFS = "`r`n"

# Local variables
$ReservationOrderID = "/providers/Microsoft.Capacity/ReservationOrders/2a06f343-e0db-4a96-b6f6-ff42422e3e0b"
$getVMSAMIID = "7d46243d-33d4-4e15-be7b-13f47b513966"
$DeploymentScriptOutputs = @{}
try {
    $assignReservationIDReaderRole = New-AzRoleAssignment -Scope $ReservationOrderID -ObjectId $getVMSAMIID -RoleDefinitionName "Reader"
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
