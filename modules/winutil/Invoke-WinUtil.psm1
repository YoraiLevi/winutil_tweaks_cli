function Invoke-WinUtil {
  # TODO: add support for confrim and whatif
  Param(
    [Parameter(Mandatory = $false)]
    [string[]]$TweakNames,
    [Parameter(Mandatory = $false)]
    [string]$DNSProvider,
    [Parameter(Mandatory = $false)]
    [string[]]$WindowsFeaturesBundles,
    [Parameter(Mandatory = $false)]
    $dns,
    $tweaks,
    $feature,
    [switch]$Undo
  )
  $DNSProvider = $DNSProvider.trim()
  if ($TweakNames.count -eq 0 -and $WindowsFeaturesBundles.count -eq 0 -and !$DNSProvider) {
    throw "You must specify at least one tweak, feature bundle, or DNS provider."
    return
  }
  
  if ($TweakNames -or $WindowsFeaturesBundles) {
    New-RestorePoint
  }
  if ($DNSProvider) {
    Set-WinUtilDNSProvider -DNSProvider $DNSProvider -dns $dns
  }
  if ($TweakNames) {
    $TweakNames | Invoke-WinUtilTweak -Tweaks $tweaks -Undo:$undo
  }
  if ($WindowsFeaturesBundles) {
    $WindowsFeaturesBundles | Install-WinUtilWindowsFeaturesBundle -bundles $feature
  }
}