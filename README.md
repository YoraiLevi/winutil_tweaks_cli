# winutil_tweaks_cli

A CLI script only for the tweaks of Chris Titus's winutil, automatically fetches new tweaks from the repo.

## Getting the script

```ps1
Invoke-WebRequest https://raw.githubusercontent.com/YoraiLevi/winutil_tweaks_cli/master/winutil_cli.ps1 -OutFile winutil_cli.ps1
```

## List of avilaible tweaks

```ps1
.\winutil_cli.ps1
Tweaks:
        WPFBingSearch
        WPFEssTweaksAH
        WPFEssTweaksDeBloat
        WPFEssTweaksDeleteTempFiles
        WPFEssTweaksDiskCleanup
        WPFEssTweaksDVR
        WPFEssTweaksHiber
        WPFEssTweaksHome
        WPFEssTweaksLoc
        WPFEssTweaksOO
        WPFEssTweaksRemoveEdge
        WPFEssTweaksRemoveOnedrive
        WPFEssTweaksServices
        WPFEssTweaksStorage
        WPFEssTweaksTele
        WPFEssTweaksWifi
        WPFMiscTweaksDisableipsix
        WPFMiscTweaksDisableMouseAcceleration
        WPFMiscTweaksDisableNotifications
        WPFMiscTweaksDisableUAC
        WPFMiscTweaksDisplay
        WPFMiscTweaksEnableipsix
        WPFMiscTweaksEnableMouseAcceleration
        WPFMiscTweaksEnableVerboselogon
        WPFMiscTweaksExt
        WPFMiscTweaksLapNum
        WPFMiscTweaksNum
        WPFMiscTweaksRightClickMenu
        WPFMiscTweaksUTC
Feature Bundles:
        WPFFeaturenfs
        WPFFeaturesdotnet
        WPFFeatureshyperv
        WPFFeatureslegacymedia
        WPFFeaturewsl
DNS Providers:
        Cloudflare
        Cloudflare_Malware
        Cloudflare_Malware_Adult
        Google
        Level3
        Open_DNS
        Quad9
```

## Usage

Delete temp files

```ps1
.\winutil_cli.ps1 -TweakNames WPFEssTweaksDeleteTempFiles
```

Supports `WhatIf` flag, which will only show what will be done

```ps1
.\winutil_cli.ps1 -TweakNames WPFEssTweaksRemoveOnedrive -WhatIf
```

Delete temp files and remove onedrive

```ps1
.\winutil_cli.ps1 -TweakNames WPFEssTweaksDeleteTempFiles, WPFEssTweaksRemoveOnedrive
```

Set DNS to Google DNS

```ps1
.\winutil_cli.ps1 -DNSProvider Google -TranscriptPath
```

Use builtin tweaks only

```ps1
 .\winutil_cli.ps1 -ExtraTweaks @() -ExtraDNSProviders @() -ExtraWindowsFeaturesBundles @()
```

Install all tweaks (not recommended)

```ps1
winutil_cli.ps1 -TweakNames WPFBingSearch,WPFEssTweaksAH,WPFEssTweaksDeBloat,WPFEssTweaksDeleteTempFiles,WPFEssTweaksDiskCleanup,WPFEssTweaksDVR,WPFEssTweaksHiber,WPFEssTweaksHome,WPFEssTweaksLoc,WPFEssTweaksOO,WPFEssTweaksRemoveEdge,WPFEssTweaksRemoveOnedrive,WPFEssTweaksServices,WPFEssTweaksStorage,WPFEssTweaksTele,WPFEssTweaksWifi,WPFMiscTweaksDisableipsix,WPFMiscTweaksDisableMouseAcceleration,WPFMiscTweaksDisableNotifications,WPFMiscTweaksDisableUAC,WPFMiscTweaksDisplay,WPFMiscTweaksEnableipsix,WPFMiscTweaksEnableMouseAcceleration,WPFMiscTweaksEnableVerboselogon,WPFMiscTweaksExt,WPFMiscTweaksLapNum,WPFMiscTweaksNum,WPFMiscTweaksRightClickMenu,WPFMiscTweaksUTC -WindowsFeaturesBundles WPFFeaturenfs,WPFFeaturesdotnet,WPFFeatureshyperv,WPFFeatureslegacymedia,WPFFeaturewsl
```
