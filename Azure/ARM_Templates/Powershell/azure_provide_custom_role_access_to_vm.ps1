# main block
try {
	# Checking for input arguments
	if ($args.Count -ne 2) {
		$output = $output + $OFS + "ERROR: Invalid arguments, rerun sccript with right arguments"
		$output = $output + $OFS + "       Usage: <script> VM-Name VM-Resource-Group"
		Exit
	}
	$getVMName = $args[0]
	$getResourceGroup = $args[1]

	# Global variables
	$OFS = "`r`n"
	$DeploymentScriptOutputs = @{}

	# Get VM details and check for its System assigned managed identity
	try {
		$ErrorActionPreference = "Stop"
		#$getVMName = Read-Host "Enter lauched VM Name"
		#$getResourceGroup = Read-Host "Enter VM Resource Group name"
		$checkVMExistance = Get-AzVM -ResourceGroupName $getResourceGroup -Name $getVMName -ErrorVariable notPresent -ErrorAction SilentlyContinue
		if ($notPresent) {
			$output = $output + $OFS + "ERROR: VM $getVMName and/or Resource Group $getResourceGroup does not exists. Re-run script with correct details"
			Exit
		} else {
			if (Get-AzADServicePrincipal -DisplayName $getVMName) {
				$output = $output + $OFS + ""
			} else {
				$output = $output + $OFS + "ERROR: System Assigned Managed Identity is not enabled for '$getVMName' VM. Enable VM's System Assigned Managed Identity and re-run the script"
				Exit
			}
		}
	}
	catch {
		$output = $output + $OFS + "Error Message: $_"
	}

	# Get list of all accessible Subscriptions
	try {
		$ErrorActionPreference = "Stop"
		$scope = @()
		foreach ($subscription in (Get-AzSubscription).Id) {
			$scope += '/subscriptions/' + $subscription
		}
	}
	catch {
		$output = $output + $OFS + "Error Message: $_"
	}

	# Creating the Custom Role at all Subscriptions
	try {
		$ErrorActionPreference = "Stop"
		$roleName = "CloudAccel Custom Role"
		if (Get-AzRoleDefinition -Name $roleName -WarningAction Ignore) {
			$output = $output + $OFS + "Custom Role '$roleName' already exists."
		} else {
			$allReadPermissions = "Microsoft.Compute/disks/read","Microsoft.Network/networkInterfaces/read","Microsoft.Network/publicIPAddresses/read","Microsoft.Compute/virtualMachines/read","Microsoft.Network/networkInterfaces/join/action","Microsoft.ChangeAnalysis/resourceChanges/*","Microsoft.Insights/Metrics/Read","Microsoft.Subscription/aliases/read","Microsoft.Resources/subscriptions/resourceGroups/read"
			$customRole = [Microsoft.Azure.Commands.Resources.Models.Authorization.PSRoleDefinition]::new()
			$customRole.Name = $roleName
			$customRole.Description = 'Custom Role for CloudAccel Application'
			$customRole.IsCustom = $true
			$customRole.Actions = $allReadPermissions
			$customRole.AssignableScopes = $scope
			$roles_assignment  = Get-AzRoleAssignment
			$role_count = 0

			foreach ($role_assign in $roles_assignment) {
				if ($customRole.Name -eq $role_assign.RoleDefinitionName -and $scope -eq $role_assign.Scope) {
					$role_count = 1
				}
			}
			
			if ($role_count -eq 0) {
				$roleVar = Get-AzRoleDefinition -Name $customRole.Name -WarningAction Ignore
				if ([string]::IsNullOrEmpty($roleVar)) {
					$roleVar = New-AzRoleDefinition -Role $customRole
					$output = $output + $OFS + "Custom Role '$roleName' created successfully"
				}
			}
		}
	}
	catch {
		$output = $output + $OFS + "Error Message: $_ "
	}

	# Assign custom role to given VM at all Subscriptions. Refer to https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for build in roles
	try {
		$ErrorActionPreference = "Stop"
		if (Get-AzRoleDefinition -Name $roleName -WarningAction Ignore) {
			#Write-Host "'$roleName' exists"
			$getVMSAMIID = (Get-AzADServicePrincipal -DisplayName $getVMName).Id
			foreach ($subscription in $scope) {
				$assignCustomRole = New-AzRoleAssignment -Scope $subscription -ObjectId $getVMSAMIID -RoleDefinitionName $roleName
				$output = $output + $OFS + "'$roleName' Role access assigned to $getVMName VM at $subscription level"
				#Write-Host "Sub - $subscription; RoleID - $getVMSAMIID; RoleName - $roleName"
				# Monitoring Reader Role
				$assignMonitorRole = New-AzRoleAssignment -Scope $subscription -ObjectId $getVMSAMIID -RoleDefinitionId "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
				$output = $output + $OFS + "'Monitoring Reader' Role access assigned to $getVMName VM at $subscription level"
			}
		} else {
			$output = $output + $OFS + "'$roleName' Role does not exists"
		}
	}
	catch {
		$output = $output + $OFS + "Error Message: $_"
	}

	# Attach Reader Role to VM at each Reservation Order ID
	try {
		$ErrorActionPreference = "Stop"
		Install-Module -Name Az.Reservations -RequiredVersion 0.7.1
		$getVMSAMIID = (Get-AzADServicePrincipal -DisplayName $getVMName).Id
		$Reservation_Order = Get-AzReservationOrder
		$res_count = 0
		$output = $output + $OFS + ""
		foreach ($Reservation in $Reservation_Order) {
			if ($Reservation.ProvisioningState -eq 'Succeeded') {
				++$res_count
				$ReservationOrderID = $Reservation.Id
				$reservationStatus = $Reservation.ProvisioningState
				#$assignReservationIDReaderRole = New-AzRoleAssignment -Scope $ReservationOrderID -ObjectId $getVMSAMIID -RoleDefinitionName "Reader"
				$output = $output + $OFS + "$res_count. Reader Role access assigned to $getVMName VM at $ReservationOrderID level"
			}
		}
	}
	catch {
		$output = $output + $OFS + "Current logged in user do not have privileges to provide ""Reserved pricing orders"" read access to azuretenants@cloudaccel.io. Please login to Azure portal using user having tenant owner privileges and rerun steps mentioned ""Steps in details""."
		#Write-Host "Error Message:  $_ "
	}
}
catch {
	$output = $output + $OFS + "Error Message:  $_ "
}
Finally {
	Write-Output $output
	$DeploymentScriptOutputs['text'] = $output
}
