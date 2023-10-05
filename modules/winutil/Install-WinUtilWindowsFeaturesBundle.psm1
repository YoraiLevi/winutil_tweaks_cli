function Install-WinUtilWindowsFeaturesBundle {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $WindowsFeaturesBundle,
        [Parameter(Mandatory = $true)]
        $bundles
    )
    Begin {
        if ($Force -and -not $Confirm) {
            $ConfirmPreference = 'None'
        }
        if (!$WhatIfPreference -and -Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "Access denied. Please run as an administrator."
            return
        }
    }
    Process {
        if ($PSCmdlet.ShouldProcess($WindowsFeaturesBundle, 'Install Windows Feature Bundle')) {
            $WindowsFeaturesBundle | ForEach-Object {
                if ($bundles.$psitem.feature) {
                    Foreach ($feature in $bundles.$psitem.feature ) {
                        Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
                    } 
                }
                if ($bundles.$psitem.InvokeScript) {
                    Foreach ( $script in $bundles.$psitem.InvokeScript ) {
                        $Scriptblock = [scriptblock]::Create($script)
                        Invoke-ScriptBlock $scriptblock -ErrorAction stop -Confirm:$false
                    } 
                } 
            }
        }
    }
}
