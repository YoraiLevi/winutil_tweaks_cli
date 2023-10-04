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
