function Format-ScriptReplaceHereStrings {
    <#
    .SYNOPSIS
    Replace here strings with variable created equivalents.
    .DESCRIPTION
    Replace here strings with variable created equivalents.
    .PARAMETER Code
    Multiple lines of code to analyze

    .EXAMPLE
    TBD

    Description
    -----------
    TBD

    .NOTES
    Author: Zachary Loeber
    Site: http://www.the-little-things.net/

    1.0.0 - 01/25/2015
    - Initial release
    #>
    [CmdletBinding()]
    param(
        [parameter(Position=0, ValueFromPipeline=$true, HelpMessage='Lines of code to look for and condense.')]
        [string[]]$Code
    )
    begin {
        $Codeblock = @()
        $Output = @()
        $LineCount = 0
    }
    process {
        $Codeblock += $Code
    }
    end {
        $FullCodeBlock = ($Codeblock | Out-String).TrimEnd()
        #$ScriptBlock = [Scriptblock]::Create($FullCodeBlock)
        $tokens = @()
        $errors = @()

        $Parser = [System.Management.Automation.Language.Parser]::ParseInput($test, [ref]$tokens, [ref] $errors)
        $Herestrings = $tokens | where {$_.kind -like "HereString*"}
        $IgnoredLines = $Tokens | Where {($_.startline -ne $_.endline) -and (($_.Type -eq 'String') -or ($_.Type -eq 'Comment'))}
        Foreach ($CurLine in ($FullCodeBlock -split "`r`n")) {
            $LineCount++
            $ToProcess = $true
            $IgnoredLines | Foreach {   # Skip any multiline comment or here-string/add-type variables
                if (($LineCount -ge $_.startline) -and ($LineCount -le $_.endline)) {
                    $ToProcess = $false
                }
            }
            if ($ToProcess -eq $true) {
                $CurLine -ireplace $regex,' $2 '
            }
            else {
                $CurLine
            }
        }
    }
}