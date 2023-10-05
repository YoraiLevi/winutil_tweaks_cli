function Get-Config {
    <#
    .SYNOPSIS
        This function retrieves configuration data from either a local file or a remote URL and merges it into a single object.
    
    .DESCRIPTION
        The Get-Config function takes an input object and attempts to retrieve configuration data from it. If the input object is a string, it is treated as a file path or URL and the corresponding data is retrieved. If the input object is a custom object, it is added to the output object as is. The retrieved data is then merged into a single object and returned.
    
    .PARAMETER InputObject
        The input object from which to retrieve configuration data.
    
    .EXAMPLE
        PS C:\> Get-Config -InputObject "C:\config.json"
        Retrieves configuration data from the local file "C:\config.json" and returns it as a single object.
    
    .EXAMPLE
        PS C:\> Get-Config -InputObject "https://example.com/config.json"
        Retrieves configuration data from the remote URL "https://example.com/config.json" and returns it as a single object.
    
    .EXAMPLE
        PS C:\> Get-Config -InputObject @{ "key1" = "value1"; "key2" = "value2" }
        Adds the custom object @{ "key1" = "value1"; "key2" = "value2" } to the output object and returns it.
    
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'None')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [psobject]$InputObject,
        [string]$JsonSchema
    )
    begin {
        $InputObjects = @()
        $TestJsonCommand = (get-command Test-Json -ErrorAction SilentlyContinue)
        if ($null -eq $TestJsonCommand) {
            $TestJsonCommand = { $true }
        }
    }
    process {
        try {
            if ($InputObject -is [string]) {
                if (Test-Path $InputObject) {
                    # Local File
                    if ($PsCmdlet.ShouldProcess($InputObject, 'Loading extras from file')) {
                        $JsonString = Get-Content $InputObject -Raw
                    }
                }
                elseif ([System.Uri]::IsWellFormedUriString($InputObject, [System.UriKind]::Absolute)) {
                    # Remote File
                    if ($PsCmdlet.ShouldProcess($InputObject, 'Fetching extras from url')) {
                        $JsonString = Invoke-WebRequest $InputObject
                    }
                }
                else {
                    # Json String
                    $JsonString = $InputObject
                }
                if (&$TestJsonCommand -Json $JsonString -Schema $JsonSchema) {
                    $InputObjects += $jsonString | ConvertFrom-Json
                }
            }
            elseif ($InputObject -is [pscustomobject]) {
                $InputObjects += $InputObject
            }
        }
        catch {
            Write-Error "Failed to parse $InputObject"
            Write-Error $PSItem
            exit 1 
        }
    }
    end {
        $InputObjects | Merge-CustomObjects { $_ | Select-Object -Last 1 }
    }
}
# Test-Json -SchemaFile .\json\feature.schema.json -Json $(Get-Content '.\json\feature.json' -Raw)
$tweaks = @($tweaks) + $ExtraTweaks | Get-Config -Whatif:$WhatIfPreference -JsonSchema $tweaksschema
$dns = @($dns) + $ExtraDNSProviders | Get-Config -Whatif:$WhatIfPreference -JsonSchema $dnsschema
$feature = @($feature) + $ExtraWindowsFeaturesBundles | Get-Config -Whatif:$WhatIfPreference -JsonSchema $featureschema
switch ($PsCmdlet.ParameterSetName) {   
    'Tweaks' {
        Start-Transcript $TranscriptPath -Append
        Invoke-WinUtil -TweakNames $TweakNames -DNSProvider $DNSProvider -WindowsFeaturesBundles $WindowsFeaturesBundles -dns $dns -tweaks $tweaks -feature $feature -Undo:$Undo
        Stop-Transcript
    }
    'ListCommand' {
        if (!$ListTweaks -and !$ListFeatureBundles -and !$ListDNSProviders) {
            $ListTweaks = $true; $ListFeatureBundles = $true; $ListDNSProviders = $true
        }
        if ($ListTweaks) {
            Write-Host "Tweaks:" -ForegroundColor Yellow
            $tweaks | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name | Sort-Object | ForEach-Object {
                Write-Host `t$_
            }
        }
        if ($ListFeatureBundles) {
            Write-Host "Feature Bundles:" -ForegroundColor Yellow
            $feature | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name | Sort-Object | ForEach-Object {
                Write-Host `t$_
            }
        }
        if ($ListDNSProviders) {
            Write-Host "DNS Providers:" -ForegroundColor Yellow
            $dns | Get-Member -MemberType NoteProperty -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name | Sort-Object | ForEach-Object {
                Write-Host `t$_
            }
        }
    }
}