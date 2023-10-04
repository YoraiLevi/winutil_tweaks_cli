# Compiled at #{replaceme_datetime}

[CmdletBinding(
    SupportsShouldProcess = $true,
    ConfirmImpact = 'High',
    DefaultParametersetName = 'ListCommand'
)]
Param(
    [Parameter(ParameterSetName = 'Tweaks')]
    [string[]]$TweakNames,
    [Parameter(ParameterSetName = 'Tweaks')]
    [string]$DNSProvider,
    [Parameter(ParameterSetName = 'Tweaks')]
    [string[]]$WindowsFeaturesBundles,
    [Parameter(ParameterSetName = 'Tweaks')]
    [switch]$Undo,
    [Parameter(ParameterSetName = 'ListCommand')]
    [switch]$ListTweaks,
    [Parameter(ParameterSetName = 'ListCommand')]
    [switch]$ListFeatureBundles,
    [Parameter(ParameterSetName = 'ListCommand')]
    [switch]$ListDNSProviders,
    [switch]$Force
)
if ($Force -and -not $Confirm) {
    $ConfirmPreference = 'None'
}