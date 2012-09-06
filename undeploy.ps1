



param($debug = $false, $context, $destination)

import-module .\adminlib.ps1

if ( $datacenter -eq $null )
{
  $datacenter = get-mkist-property -name "datacenter"
}

if ($environment -eq $null )
{
  $environment = get-mkist-property -name "environment"
}

if ( $context -eq $null)
{
  $context = "$($datacenter)_$environment"
}


if ( $destination -eq $null)
{
  $destination = "C:\monitoring-$context"
}


"Starting Undeployment ..."

"Debug        : " + $debug
"Data Center  : " + $datacenter
"Environment  : " + $environment
"Context      : " + $context
"Machine      : " + [system.environment]::machinename
"Identity     : " + [string]::format("{0}\{1}", [system.environment]::userdomainname ,  [system.environment]::username)
"Destination  : " + $destination
"-----------  :"


$options = @{}
$options["datacenter"] = $datacenter
$options["environment"] = $environment
$options["context"] = $context

$deployments = dir *.deploy | filter_context $context

if ( $deployments -ne $null )
{
    foreach($deployment in $deployments)
    {
        undeploy $options $deployment
    }
}




"Undeployment COMPLETE"
"Don't worry, be happy"