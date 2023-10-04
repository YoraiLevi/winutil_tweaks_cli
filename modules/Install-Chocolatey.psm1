function Install-Chocolatey {
    <#
    .SYNOPSIS
    Ensures that Chocolatey package manager is installed.
    
    .DESCRIPTION
    The Install-Chocolatey function checks if Chocolatey package manager is installed on the system. If it is not installed, the function installs Chocolatey by downloading and executing the installation script from the official Chocolatey website. The function also enables the 'allowGlobalConfirmation' feature of Chocolatey to suppress confirmation prompts during package installations.
    
    .PARAMETER Force
    Forces the command to run without prompting for confirmation.
    
    .EXAMPLE
    Install-Chocolatey
    Checks if Chocolatey is installed and installs it if it is not.
    
    .EXAMPLE
    Install-Chocolatey -Force
    Installs Chocolatey without prompting for confirmation.
    #>

    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    Param(
        [switch]$Force
    )

    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }

    try {
        # Write-Host "Checking if Chocolatey is Installed..."
        $chocoVersion = (Get-Item "$env:ChocolateyInstall\choco.exe" -ErrorAction Ignore).VersionInfo.ProductVersion
        if ((Get-Command -Name choco -ErrorAction Ignore) -and $chocoVersion) {
            # Write-Host "Chocolatey Already Installed"
            return
        }
        if ($PSCmdlet.ShouldProcess("Installing Chocolatey", "Would you like to install Chocolatey?", "Chocolatey is not installed")) {
            Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -ErrorAction Stop
            powershell choco feature enable -n allowGlobalConfirmation
        }
    }
    Catch {
        Write-Error -Message "Couldn't install Chocolatey" -ErrorAction Stop
    }
}