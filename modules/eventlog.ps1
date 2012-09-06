

<#
Process needs to be running under an identity in the local Administrators
group on the machine if the $source does not already exist.
#>
function logevent($event_type, $id, $source, $message)
{
	$event_log = new-object system.diagnostics.eventlog("Application")
	$event_log.Source = $source
	$event_log.WriteEntry($message, $event_type, $id)
}

function logerror($id, $source, $message)
{
    logevent ([System.Diagnostics.EventLogEntryType]::Error) $id $source $message
}

function logwarn($id, $source, $message)
{
    logevent ([System.Diagnostics.EventLogEntryType]::Warning) $id $source $message
}

function loginfo($id, $source, $message)
{
    logevent ([System.Diagnostics.EventLogEntryType]::Information) $id $source $message
}