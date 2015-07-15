function Format-ScriptRemoveSuperfluousSpaces {
    <#
    .SYNOPSIS
    Removes superfluous spaces at the end of individual lines of code.
    .DESCRIPTION
    Removes superfluous spaces at the end of individual lines of code.
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
        [parameter(Position=0, ValueFromPipeline=$true, HelpMessage='Lines of code to process.')]
        [string[]]$Code
    )
    process {
        foreach ($codeline in ($Code -split "`r`n")) {
            $codeline.TrimEnd()
        }
    }
}