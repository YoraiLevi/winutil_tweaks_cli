function Invoke-WinUtilTweak {
    <#
    .SYNOPSIS
    Applies or undoes Windows utility tweaks.
    
    .DESCRIPTION
    applies or undoes Windows utility tweaks based on the specified tweak name(s).
    
    .PARAMETER TweakName
    Specifies the name(s) of the tweak(s) to apply or undo.
    
    .PARAMETER Undo
    Indicates whether to undo the specified tweak(s).
    
    .PARAMETER Tweaks
    Specifies the tweaks available to apply or undo.
    
    .PARAMETER Force
    Indicates whether to force the operation without prompting for confirmation.
    
    .EXAMPLE
    Invoke-WinUtilTweaks -TweakName "Disable Cortana", "Disable Telemetry" -Tweaks $Tweaks
    
    This example applies the "Disable Cortana" and "Disable Telemetry" tweaks.
    
    .EXAMPLE
    Invoke-WinUtilTweaks -TweakName "Disable Cortana" -Undo -Tweaks $Tweaks
    
    This example undoes the "Disable Cortana" tweak.
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$TweakName,
        [Parameter(Mandatory = $false)]
        [switch]$Undo,
        [Parameter(Mandatory = $true)]
        $Tweaks,
        [switch]$Force
    )
    Begin {
        if ($Force -and -not $Confirm) {
            $ConfirmPreference = 'None'
        }
        if (!$WhatIfPreference -and -Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw "Access denied. Please run as an administrator."
            return
        }
        if ($Undo) {
            $Values = @{
                Registry      = "OriginalValue"
                ScheduledTask = "OriginalState"
                Service       = "OriginalType"
                ScriptType    = "UndoScript"
            }
    
        }    
        Else {
            $Values = @{
                Registry      = "Value"
                ScheduledTask = "State"
                Service       = "StartupType"
                ScriptType    = "InvokeScript"
            }
        }
    }
    Process {
        if ($PSCmdlet.ShouldProcess($TweakName, "$(&{If(!$Undo) {"Apply"} Else {"Undo"}}) Tweak")) {
            if ($Tweaks.$TweakName.ScheduledTask) {
                $Tweaks.$TweakName.ScheduledTask | ForEach-Object {
                    Set-ScheduledTaskState -TaskName $psitem.Name -State $psitem.$($values.ScheduledTask) -Confirm:$false
                }
            }
            if ($Tweaks.$TweakName.service) {
                $Tweaks.$TweakName.service | ForEach-Object {
                    Set-ServicesStartupType -Name $psitem.Name -StartupType $psitem.$($values.Service) -Confirm:$false
                }
            }
            if ($Tweaks.$TweakName.registry) {
                $Tweaks.$TweakName.registry | ForEach-Object {
                    Set-RegistryKey -Name $psitem.Name -Path $psitem.Path -Type $psitem.Type -Value $psitem.$($values.registry) -Confirm:$false
                }
            }
            if ($Tweaks.$TweakName.$($values.ScriptType)) {
                $Tweaks.$TweakName.$($values.ScriptType) | ForEach-Object {
                    $Scriptblock = [scriptblock]::Create($psitem)
                    Invoke-ScriptBlock -ScriptBlock $scriptblock -Confirm:$false
                }
            }
    
            if (!$Undo) {
                if ($Tweaks.$TweakName.appx) {
                    $Tweaks.$TweakName.appx | ForEach-Object {
                        Remove-AppxPackageLike -Name $psitem -Confirm:$false
                    }
                }
    
            }
        }
    }
}