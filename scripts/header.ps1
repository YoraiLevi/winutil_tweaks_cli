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
    [psobject[]]$ExtraTweaks = @('https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/tweaks.json'),
    [psobject[]]$ExtraDNSProviders = @('https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/dns.json'),
    [psobject[]]$ExtraWindowsFeaturesBundles = @('https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/feature.json'),
    [string]$TranscriptPath = "$ENV:TEMP\Winutil.log",
    [switch]$Force
)
if ($Force -and -not $Confirm) {
    $ConfirmPreference = 'None'
}