switch ($PsCmdlet.ParameterSetName) {   
    'Tweaks' {
        Start-Transcript $ENV:TEMP\Winutil.log -Append
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