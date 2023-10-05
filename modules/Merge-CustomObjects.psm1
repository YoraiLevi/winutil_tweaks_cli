Function Merge-Hashtables([ScriptBlock]$Operator) {
    # https://stackoverflow.com/a/32890418/12603110
    $Output = @{}
    ForEach ($Hashtable in $Input) {
        If ($Hashtable -is [Hashtable]) {
            ForEach ($Key in $Hashtable.Keys) { $Output.$Key = If ($Output.ContainsKey($Key)) { @($Output.$Key) + $Hashtable.$Key } Else { $Hashtable.$Key } }
        }
    }
    If ($Operator) { ForEach ($Key in @($Output.Keys)) { $_ = @($Output.$Key); $Output.$Key = Invoke-Command $Operator } }
    $Output
}

Function Merge-CustomObjects([ScriptBlock]$Operator) {
    $Output = [PSCustomObject]@{}
    ForEach ($Hashtable in $Input) {
        If ($Hashtable -is [PSCustomObject]) {
            ForEach ($Key in (Get-Member -InputObject $Hashtable -MemberType NoteProperty).Name) {
                Add-Member -Force -InputObject $Output -MemberType NoteProperty -Name $Key -Value $(if ($Output.psobject.properties.match($Key).Count) { @($Output.$Key) + $Hashtable.$Key } Else { $Hashtable.$Key })
            }
        }
    }
    If ($Operator) { ForEach ($Key in @(Get-Member -InputObject $Output -MemberType NoteProperty).Name) { $_ = @($Output.$Key); $Output.$Key = Invoke-Command $Operator } }
    $Output
}
