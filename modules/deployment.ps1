
$default_runas_username = "usa\scs_monitoring"
$default_runas_password = "omibYywROvSgRqBgFn5+KQ=="





<#
.SYNOPSIS
apply_context_override is for applying node specific overrides based on the value of the @context attribute.

Context values can be or'ed ("|") together.

Returns an xmlnode which will have element values returned in .InnerText and any attributes as properties
of the returned object.

.DESCRIPTION
apply_context_override is for applying node specific overrides based on the value of the @context attribute.

.EXAMPLE

Given xml like the following:

<deploy>
	<job name="WMOS.Comlink.OldFileMonitor.SW" validContexts="R0_IDEV2 | R0_ICONFIG2 | R0_PROD">
    <action>WMOS.Comlink.OldFileMonitor.ps1</action>
		<schedule>/SC MINUTE /MO 5</schedule>
    <identity username="usa\scs_monitoring" password="omibYywROvSgRqBgFn5+KQ=="/>
		<identity context="R0_IDEV2" username="usa\scs_monitoring2" password="bob"/>
    <arguments context="R0_IDEV2 | R0_ICONFIG2">my non production arguments</arguments>
		<arguments context="R0_PROD">production arguments</arguments>
		<arguments>default</arguments>
	</job>
</deploy>

This gets the value of the 'arguments' element with an context of "R0_IDEV2":

$node = apply_context_override $xml "arguments" "R0_IDEV2"
$node.InnerText

This gets the value of the 'identity' attribute with an context of "R0_IDEV2", with attributes being
promoted to a property of the node.  Here we are accessing the username and password:

$node = apply_context_override $xml "identity" "R0_IDEV2"
$node.username
$node.password

#>
function apply_context_override($node, $element, $context)
{

	# convert to lower case for comparison in the xpath translate function
	#
	$lowercase_context = $context.ToLower()

	$xpath = "$element[translate(@context, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = '$lowercase_context'] "
		
	$r = $node.deploy.job.SelectSingleNode($xpath)

	if ( $r -eq $null )
	{
		$r = $node.deploy.job.SelectSingleNode("$element[string-length(@context) = 0]")
	}
	
	
	$r
	
}

<#
    helper to filter out deployment files that belong in a particular region/datacenter
    
    e.g. dir *.deploy | filter_datacenter "DDC"
#>
filter filter_datacenter($datacenter)
{
    [xml]$deployment = get-content $_

    # job doesn't specify a region, meaning all
    #
    if ( $deployment.deploy.job.region -eq $null )
    {
        $_
    }
    else
    {
        # job does specify a region, so lets constraint
        # to what is asked.
        if ( $deployment.deploy.job.region.Contains($datacenter) )
        {
            $_
        }
    }

}

<#
    helper to filter out deployment files that belong in a particular environment
    
    e.g. dir *.deploy | filter_environment "IDEV3"
#>
filter filter_environment($environment)
{
    [xml]$deployment = get-content $_

    # job doesn't specify a region, meaning all
    #
    if ( $deployment.deploy.job.environment -ne $null -and  $deployment.deploy.job.environment.Contains($environment) )
    {
        $_
    }
    
}

filter filter_context($deploy_context)
{
    [xml]$deployment = get-content $_

    # job doesn't specify a region, meaning all
    #
    if ( $deployment.deploy.job.validContexts -ne $null -and  $deployment.deploy.job.validContexts.Contains($deploy_context) )
    {
        $_
    }
    
}

function execute_command($cmd)
{
  if ( $debug -eq $false )
	{
		invoke-expression $cmd
  }
	else
	{
		$cmd
	}
}

function deploy($context, $deployment)
{

  write-debug "deploy($context,$deployment)"
  
      
	[xml]$xml = get-content $deployment
	
	$action = $xml.deploy.job.action
	$taskname = "$context-" + $xml.deploy.job.name
	$schedule = $xml.deploy.job.schedule
  
   
	
	if ( $action -eq $null )
	{
		$file_info = new-object system.io.fileinfo($deployment)
	
		$action = [string]::format("%WINDIR%\system32\windowspowershell\v1.0\powershell.exe {0}\{1}.ps1", $destination, $file_info.basename) 
	}
    else 
    {
        
        if ( $action.EndsWith(".ps1") )
        {
            $action = [string]::format("{0}\run.bat \""""{1}\"""" \""""{1}\{2}", $destination, $destination, $action ) 
        }
   
    }

	$arguments = apply_context_override $xml "arguments" $context
	
  write-debug $default_runas_username
  
	$username = $default_runas_username
	$password = decrypt-string $default_runas_password
	
	# if user is providing a username/password other than default
	# lets extract it here w/context overrides.
    #
	if ($xml.deploy.job.identity -ne $null)
	{
    $identity = apply_context_override $xml "identity" $context
    
		$username = $identity.username
		$password = decrypt-string $identity.password
	}
	
	
	$action = [string]::format("{0} -context {1} {2}\""""", $action, $context, $arguments.InnerText)
	
	
	$cmd = "schtasks /create /TN $taskname $schedule /RU ""$username"" /RP ""$password"" /F /TR ""$action""" 
  
  
	
	write-host "installing task $taskname"
  
  execute_command $cmd

  
  
  # default is an enabled task
  # some envirnoments don't need all tasks enabled
  # 
  $state = apply_context_override $xml "enabled" $context
  
  
  if ( ($state -ne $null) -and ($state.InnerText.ToLower() -eq "false") )
  {
    
    write-host "disabling $taskname"
    $cmd = "schtasks /change /TN $taskname /RP ""$password""  /disable" 
    execute_command $cmd
  }
  
		
	
}


function undeploy($context, $deployment)
{
	
	
	[xml]$xml = get-content $deployment
		
	$taskname = "$context-" + $xml.deploy.job.name
	
	$cmd = "schtasks /delete /TN $taskname /F" 
	
  if ($debug)
  {
      write-host "deleting task " + $taskname
  }
	
	
	if ( $debug -eq $false )
	{
		invoke-expression $cmd
	}
	else
	{
		$cmd
	}
	
}