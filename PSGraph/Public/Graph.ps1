function Graph  
{
    <#
        .Description
        Defines a graph. The base collection that holds all other graph elements

        .Example
        graph g {
            node top,left,right @{shape='rectangle'}
            rank left,right
            edge top left,right
        }

        .Example

        $dot = graph {
            edge hello world
        }

        .Notes
        The output is a string so it can be saved to a variable or piped to other commands
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidDefaultValueForMandatoryParameter", "")]
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('DiGraph')]
    [OutputType([string])]
    param(

        # Name or ID of the graph
        [Parameter(
            Mandatory = $true, 
            Position = 0
        )]
        [string]
        $Name,

        # The commands to execute inside the graph
        [Parameter(
            Mandatory = $true, 
            Position = 1,
            ParameterSetName = 'Default'
        )]
        [Parameter(
            Mandatory = $true, 
            Position = 2,
            ParameterSetName = 'Attributes'
        )]
        [scriptblock]
        $ScriptBlock,

        # Hashtable that gets translated to graph attributes
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(             
            Mandatory = $true, 
            Position = 1,
            ParameterSetName = 'Attributes'
        )]
        [hashtable]
        $Attributes = @{},

        # Keyword that initiates the graph
        [string]
        $Type = 'digraph'
    )
    
    begin
    {
        try
        {
            
            Write-Verbose "Begin Graph $type $Name"
            if ($Type -eq 'digraph')
            {
                $script:indent = 0
            }

            "" # Blank line
            "{0}{1} {2} {{" -f (Get-Indent), $Type, $name
            $script:indent++

            if ($Attributes -ne $null)
            {
                ConvertTo-GraphVizAttribute -Attributes $Attributes -UseGraphStyle
            }

            "" # Blank line      
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSitem)
        }
    }

    process
    {
        try
        {
            Write-Verbose "Process Graph $type $name"
            & $ScriptBlock
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSitem)
        }
    }

    end
    {       
        try
        {
            $script:indent--
            if ($script:indent -lt 0)
            {
                $script:indent = 0
            }
            "$(Get-Indent)}" # Close braces
            "" #Blank line
            Write-Verbose "End Graph $type $name"            
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSitem)
        } 
    }
}
