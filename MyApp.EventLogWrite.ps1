param($context="Development", $message="for those about to ROCK! We salute you!!")

import-module .\adminlib.ps1

# global *bleh*
#
$erroractionpreference = "Stop"


$event_id = 1001
$event_source = "MyApp"


function run
{


    loginfo -id $event_id -source $event_source $message
  
  
  
}

try 
{
  write-debug "MyApp.EventLogWrite.Run START"
  
  run 

  write-debug "MyApp.EventLogWrite.Run END"
}
catch 
{

    $sb = new-object System.Text.StringBuilder
    
    $sb.AppendLine("***ERROR***") | out-null
    $sb.AppendFormat("script: {0}", $myinvocation.mycommand.path) | out-null
    $sb.AppendLine() | out-null
    $sb.AppendFormat("context: {0}", $context) | out-null
    $sb.AppendLine() | out-null
    $sb.AppendFormat("user limit: {0}", $user_limit) | out-null
    $sb.AppendLine() | out-null
    
    $sb.AppendLine() | out-null
    $sb.AppendLine() | out-null
    $sb.AppendLine($_.Exception.ToString()) | out-null

    $message = $sb.ToString()
    $message
    
    logerror -id $event_id -source $event_source -message $message

  # outputting this to output so you can
  # see it when run manually
  #    
    $message

}




