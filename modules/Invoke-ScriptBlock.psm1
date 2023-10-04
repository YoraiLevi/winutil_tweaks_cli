function Invoke-ScriptBlock {
    <#
    .SYNOPSIS
    Invokes a script block with the option to confirm before running.

    .DESCRIPTION
    invokes a script block with the option to confirm before running. It supports the WhatIf and Confirm parameters.

    .PARAMETER ScriptBlock
    The script block to be invoked.

    .PARAMETER Force
    Forces the command to run without prompting for confirmation.

    .INPUTS
    ScriptBlock

    .OUTPUTS
    ScriptBlock output

    .EXAMPLE
    Invoke-ScriptBlock -ScriptBlock { Get-ChildItem } -Confirm

    This example invokes the Get-ChildItem cmdlet script block with a confirmation prompt.

    #>
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [scriptblock]$ScriptBlock,
        [switch]$Force
    )
    Begin {
        if ($Force -and -not $Confirm) {
            $ConfirmPreference = 'None'
        }
    }
    Process {
        if ($PSCmdlet.ShouldProcess($ScriptBlock.ToString(), "Run the script block")) {
            return Invoke-Command $scriptblock -ErrorAction Stop
        }
    }
}