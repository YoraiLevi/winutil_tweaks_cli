function Test-RegistryKeyValueType {    
    <#
    .SYNOPSIS
    Tests if a registry key exists and, if provided a registry value, tests the value and type of a registry value matching.
    
    .DESCRIPTION
    The Test-RegistryKeyValueType function tests if a registry key exists. If a registry value is provided, it tests the value and type of a registry value matching.
    
    .PARAMETER Path
    Specifies the path to the registry key.
    
    .PARAMETER Name
    Specifies the name of the registry value.
    
    .PARAMETER Type
    Specifies the type of the registry value.
    
    .PARAMETER Value
    Specifies the value to compare against. Pass integer, string, or PowerShell array.
    
    .EXAMPLE
    Test-RegistryKeyValueType -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ProductName" -Type String -Value "Windows 10 Enterprise"
    
    This example tests if the registry key "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" exists and if the value of the "ProductName" registry value is "Windows 10 Enterprise".
    #>
    [CmdletBinding(DefaultParametersetName = 'None')] 
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(ParameterSetName = 'NameValueType', Mandatory = $true)]
        [string]$Name,
        [Parameter(ParameterSetName = 'NameValueType', Mandatory = $true)]
        [Microsoft.Win32.RegistryValueKind]$Type,
        [Parameter(ParameterSetName = 'NameValueType', Mandatory = $true, HelpMessage = 'The value to compare against, Pass integer, string or powershell array.')]
        $Value
    )
    try {
        $RegistryKey = Get-Item -Path $Path -ErrorAction Stop
        switch ($PsCmdlet.ParameterSetName) {
            'NameValueType' {
                $RegistryKeyValueKind = $RegistryKey.GetValueKind($Name)
                $RegistryKeyValue = $RegistryKey.GetValue($Name)
                if ($RegistryKeyValueKind -eq $Type) {
                    if (!$(Compare-Object $RegistryKeyValue $Value)) {
                        return $true
                    }
                }
            }
            default {
                return $true
            }
        }
    }
    catch {
        if ($PSItem.Exception.Message -like "*Cannot find path*") {
        }
        if ($PSItem.Exception.Message -like '*does not exist*') {
        }
        else {
            throw $PSItem
        }
    }
    return $false
}
function Set-RegistryKey {
    <#
    .SYNOPSIS
    Sets a registry key value.
    
    .DESCRIPTION
    The Set-RegistryKey function sets a registry key value with the specified name, type, and value. If the key does not exist, it is created.
    
    .PARAMETER Path
    The path to the registry key.
    
    .PARAMETER Name
    The name of the registry value.
    
    .PARAMETER Type
    The type of the registry value.
    
    .PARAMETER Value
    The value to set.
    
    .PARAMETER Force
    Forces the command to run without prompting for confirmation.
    
    .EXAMPLE
    Set-RegistryKey -Path "HKLM:\SOFTWARE\MyApp" -Name "MySetting" -Type String -Value "Hello, World!"
    
    This example sets the value of the "MySetting" registry value under the "HKLM:\SOFTWARE\MyApp" key to "Hello, World!".
    
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [Microsoft.Win32.RegistryValueKind]$Type,
        [Parameter(Mandatory = $true)]
        $Value,
        [switch]$Force
    )

    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }

    if ((Test-RegistryKeyValueType -Path $Path -Name $Name -Type $Type -Value $Value -ErrorAction SilentlyContinue)) {
        return
    }

    if ($PSCmdlet.ShouldProcess("$Path", "Set Registry Key Value: '$Name' to value: '$Value'")) {
        if (!(Test-Path 'HKU:\')) { New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS }

        if (!(Test-Path -LiteralPath $Path)) {
            New-Item -LiteralPath $Path -Force -ErrorAction Stop | Out-Null
        }
        Set-ItemProperty -LiteralPath $Path -Name $Name -Type $Type -Value $Value -Force -ErrorAction Stop | Out-Null
    }
}