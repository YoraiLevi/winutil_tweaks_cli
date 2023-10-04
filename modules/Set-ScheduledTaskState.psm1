function Set-ScheduledTaskState {
    <#
    .SYNOPSIS
    Enables or disables the provided Scheduled Task.

    .DESCRIPTION
    The Set-WinUtilScheduledTask function enables or disables the provided Scheduled Task. takes two parameters: the name of the Scheduled Task and the desired state (either "Enabled" or "Disabled").

    .PARAMETER TaskName
    The name of the Scheduled Task to enable or disable.

    .PARAMETER State
    The desired state of the Scheduled Task. Valid values are "Enabled" and "Disabled".
    
    .PARAMETER Force
    Forces the command to run without prompting for confirmation.
    
    .EXAMPLE
    Set-WinUtilScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" -State "Disabled"
    Disables the "Microsoft Compatibility Appraiser" Scheduled Task.

    .NOTES
    Could require administrative privileges to run.

    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$TaskName,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Enabled", "Disabled")]
        $State,
        [switch]$Force
    )
    Begin {
        if ($Force -and -not $Confirm) {
            $ConfirmPreference = 'None'
        }
    }
    Process {
        if ($PSCmdlet.ShouldProcess($TaskName, "$($State.Substring(0,$State.length-1)) ScheduledTask")) {
            Try {
                if ($State -eq "Disabled") {
                    # Write-Host "Disabling Scheduled Task $TaskName"
                    Disable-ScheduledTask -TaskName $TaskName -ErrorAction Stop
                }
                if ($State -eq "Enabled") {
                    # Write-Host "Enabling Scheduled Task $TaskName"
                    Enable-ScheduledTask -TaskName $TaskName -ErrorAction Stop
                }
            }
            Catch [System.Exception] {
                if ($psitem.Exception.Message -like "*The system cannot find the file specified*") {
                    Write-Error "Scheduled Task $TaskName was not Found"
                    return
                }
                Else {
                    throw $psitem
                }
            }
        }
    }
}