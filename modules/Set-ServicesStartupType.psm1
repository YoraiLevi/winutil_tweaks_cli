Function Set-ServicesStartupType {
    <#
    .SYNOPSIS
    Sets the startup type of a Windows service.
    
    .DESCRIPTION
    The Set-ServicesStartupType function sets the startup type of a Windows service to Automatic, Manual, or Disabled.
    
    .PARAMETER Name
    Specifies the search name of services to set the startup type for.
    
    .PARAMETER StartupType
    Specifies the startup type to set for the service. Valid values are Automatic, Manual, and Disabled.
    
    .PARAMETER Force
    Forces the command to run without prompting for confirmation.
    
    .EXAMPLE
    Set-ServicesStartupType -Name "Spooler" -StartupType "Disabled"
    Sets the startup type of the Spooler service to Disabled.
    
    .EXAMPLE
    Set-ServicesStartupType -Name "Lan*" -StartupType "Disabled"
    Sets the startup type of all services starting with "Lan" to Disabled.
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        # [WildcardPattern]
        $Name,
        [Parameter(Mandatory = $true)]
        [System.ServiceProcess.ServiceStartMode]$StartupType, #powershell 5.1 compatibility, AutomaticDelayedStart is not supported
        [switch]$Force
    )
    Begin {
        if ($Force -and -not $Confirm) {
            $ConfirmPreference = 'None'
        }
    }
    Process {
        try {
            $services = Get-Service -Name $Name -ErrorAction Stop
            if ($services.Count -eq 0) {
                Write-Error "No services found matching name $Name"
                return
            }
            $Names = ($services -join ", ").trim()
            if ($PSCmdlet.ShouldProcess($Names, "Set Services StartupType to $StartupType")) {
                $services | Set-Service -StartupType $StartupType -ErrorAction Stop
            }
        }
        catch {
            Write-Error $PSItem
        }
    }
}
