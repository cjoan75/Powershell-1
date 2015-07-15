function Format-ScriptFormatTypeNames {
    [CmdletBinding()]
    param(
        [parameter(Position=0, ValueFromPipeline=$true, HelpMessage='Lines of code to format type names within.')]
        [string[]]$Code
    )
    begin {
        $Codeblock = @()
        $CurrentLevel = 0
        $ParseError = $null
        $Tokens = $null
        $Indent = (' ' * $Depth)
    }
    process {
        $Codeblock += $Code
    }
    end {
        $ScriptText = $Codeblock | Out-String

        $AST = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$Tokens, [ref]$ParseError) 
 
        if($ParseError) { 
            $ParseError | Write-Error
            throw 'Format-TypeNames: Will not work properly with errors in the script, please modify based on the above errors and retry.'
        }

        $types = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.TypeExpressionAst] -or $args[0] -is [System.Management.Automation.Language.TypeConstraintAst]}, $true)

        for($t = $types.Count - 1; $t -ge 0; $t--) {
            $type = $types[$t]
            
            $typeName = $type.TypeName.Name
            $extent = $type.TypeName.Extent
    		$FullTypeName = Invoke-Expression "$type"
            if ($typeName -eq $FullTypeName.Name) {
                $NameCompare = ($typeName -cne $FullTypeName.Name)
                $Replacement = $FullTypeName.Name
            } 
            else {
                $NameCompare = ($typeName -cne $FullTypeName.FullName)
                $Replacement = $FullTypeName.FullName
            }
            if (($FullTypeName -ne $null) -and ($NameCompare)) {
                $RemoveStart = $extent.StartOffset
                $RemoveEnd = $extent.EndOffset - $RemoveStart
                $ScriptText = $ScriptText.Remove($RemoveStart,$RemoveEnd).Insert($RemoveStart,$Replacement)
            }
        }
        $ScriptText
    }
}