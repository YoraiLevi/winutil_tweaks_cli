function Remove-AppxPackageLike {
    <#
    .SYNOPSIS
    removes any APPX packages containing 'Name'.
    
    .DESCRIPTION
    The Remove-AppxPackageLike function removes any APPX packages containing 'Name'. It removes both the installed package and the provisioned package.
    
    .PARAMETER Name
    Specifies the name of the APPX package to remove.
    
    .PARAMETER Force
    Forces the command to run without prompting for confirmation.
    
    .EXAMPLE
    Remove-AppxPackageLike -Name "Microsoft.Microsoft3DViewer"
    This example removes the "Microsoft.Microsoft3DViewer" APPX package.
    
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        # [WildcardPattern]
        [string]$Name,
        [switch]$Force
    )
    Begin {
        if ($Force -and -not $Confirm) {
            $ConfirmPreference = 'None'
        }
        if (!$WhatIfPreference -and -Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "The requested operation requires elevation. Please run as an administrator." # Get-AppxProvisionedPackage requires elevation
            return
        }
    }
    Process {
        $Name = "*$Name*"
    
        try {
            $appxPackages = Get-AppxPackage $Name
            $appxProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Name
        }
        Catch [System.Exception] {
            # We shouldn't be able to get to here
            if ($psitem.Exception.Message -like "*The requested operation requires elevation*") {
                Write-Warning "Unable to uninstall $name due to a Security Exception"
            }
            Else {
                Write-Warning "Unable to uninstall $name due to unhandled exception"
                Write-Warning $psitem.Exception.StackTrace 
            }
        }
        Catch {
            Write-Warning "Unable to uninstall $name due to unhandled exception"
            Write-Warning $psitem.Exception.StackTrace 
        }
        
        $packages = $($appxPackages | ForEach-Object { $_.Name } ; $appxProvisionedPackages | ForEach-Object { $_.DisplayName }) | Sort-Object | Get-Unique
        if ($packages.Count -eq 0) {
            Write-Error "No packages found matching pattern $Name"
            return
        }
        $packages = ($packages -join ", ").trim()
        Try {
            if ($PSCmdlet.ShouldProcess($packages)) {
                $appxPackages | Remove-AppxPackage -ErrorAction Continue
                $appxProvisionedPackages | Remove-AppxProvisionedPackage -Online -ErrorAction Continue
            }
        }
        Catch [System.Exception] {
            if ($psitem.Exception.Message -like "*The requested operation requires elevation*") {
                Write-Warning "Unable to uninstall $name due to a Security Exception"
            }
            Else {
                Write-Warning "Unable to uninstall $name due to unhandled exception"
                Write-Warning $psitem.Exception.StackTrace 
            }
        }
        Catch {
            Write-Warning "Unable to uninstall $name due to unhandled exception"
            Write-Warning $psitem.Exception.StackTrace 
        }
    }
}