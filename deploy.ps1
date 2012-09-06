

param($debug = $false, $context="Development", $destination)

import-module .\adminlib.ps1


if ( $destination -eq $null)
{
  $destination = "C:\job-$context"
}


$identity = [string]::format("{0}\{1}", [system.environment]::userdomainname ,  [system.environment]::username)


write-host "Starting Deployment ..."

write-host "Debug        : $debug"
write-host "Context      : $context"
write-host "Machine      : $([system.environment]::machinename)"
write-host "Identity     : $identity"
write-host "Destination  : $destination"
write-host "-----------  :"


if ( $debug -ne $true )
{
    mkdir -p $destination -force  | out-null

    write-host "copying files from $pwd to $destination"

    xcopy *.* /s /Y /R /Q $destination
}

# only deploying those jobs that are in our current context
#
$deployments = dir *.deploy | filter_context $context


if ( $deployments -ne $null )
{
    foreach($deployment in $deployments)
    {
        deploy -context $context -deployment $deployment
        write-host ""
    }
}




write-host "-----------:"
write-host "Deployment COMPLETE"
write-host "Have a nice day! :D "