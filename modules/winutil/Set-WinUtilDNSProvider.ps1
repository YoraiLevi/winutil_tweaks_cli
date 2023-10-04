function Set-WinUtilDNSProvider {
    <#
    
        .DESCRIPTION
        will set the DNS of all interfaces that are in the "Up" state. It will lookup the values from the DNS.Json file

        .EXAMPLE

        Set-WinUtilDNS -DNSProvider "google"
    
    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DNSProvider,
        $dns,
        [switch]$Force
    )

    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }
    if (!$dns.$DNSProvider.Primary) {
        Write-Error "DNSProvider $DNSProvider not found"
        return
    }
    if ($PSCmdlet.ShouldProcess($DNSProvider, 'Set DNS provider')) {
        Try {
            $Adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
            # Write-Host "Ensuring DNS is set to $DNSProvider on the following interfaces"
            # Write-Host $($Adapters | Out-String)

            Foreach ($Adapter in $Adapters) {
                if ($DNSProvider -eq "DHCP") {
                    Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ResetServerAddresses
                }
                Else {
                    Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses ("$($dns.$DNSProvider.Primary)", "$($dns.$DNSProvider.Secondary)")
                }
            }
        }
        Catch {
            Write-Error $PSItem
        }
    }
}
