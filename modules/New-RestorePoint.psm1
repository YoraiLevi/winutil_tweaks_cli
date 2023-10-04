function New-RestorePoint {
    <#
    .SYNOPSIS
    Creates a System Restore Point.

    .DESCRIPTION
    creates a System Restore Point on the local computer. A System Restore Point is a snapshot of the computer's system files, registry settings, and installed programs at a specific point in time. If the computer experiences problems, you can use System Restore to restore the system to a previous state.

    .PARAMETER Description
    Specifies a description for the System Restore Point.

    .PARAMETER RestorePointType
    Specifies the type of restore point. The default is MODIFY_SETTINGS.

    .PARAMETER Force
    Forces the command to run without prompting for confirmation.

    .EXAMPLE
    New-RestorePoint -Description "Before installing new software"
    Creates a System Restore Point with the description "Before installing new software".

    .NOTES
    requires administrative privileges to run.
    #>    
    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    param(
        [string]$Description = "System Restore Point",
        [ValidateSet(
            'APPLICATION_INSTALL',
            'APPLICATION_UNINSTALL',
            'DEVICE_DRIVER_INSTALL',
            'MODIFY_SETTINGS',
            'CANCELLED_OPERATION'
        )]
        [string]$RestorePointType = "MODIFY_SETTINGS",
        [switch]$Force
    )

    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }
    
    # Check if the user has administrative privileges
    if (!$WhatIfPreference -and -Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Access denied. Please run as an administrator."
        return
    }
    
    if ($PSCmdlet.ShouldProcess('Creating a system restore point', 'Are you sure you want to create a system restore point?', 'Create a system restore point')) {
        # Check if System Restore is enabled for the main drive
        try {
            # Try getting restore points to check if System Restore is enabled
            Enable-ComputerRestore -Drive "$env:SystemDrive" -ErrorAction Stop -Confirm:$false
        }
        catch {
            Write-Warning "An error occurred while enabling System Restore: $_"
        }
        # Check if the SystemRestorePointCreationFrequency value exists
        $exists = Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -name "SystemRestorePointCreationFrequency" -ErrorAction SilentlyContinue
        if ($null -eq $exists) {
            # write-host 'Changing system to allow multiple restore points per day'
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value "0" -Type DWord -Force -ErrorAction Stop | Out-Null  
        }
        Checkpoint-Computer -Description $description -RestorePointType "MODIFY_SETTINGS"
        # Write-Host -ForegroundColor Green "System Restore Point Created Successfully"
    }
}
# }
