PsSchedule
=================
PsSchedule is a dirty little admin library to wrap up deploying PowerShell scripts
as Windows scheduled tasks.

Deployment
===========
The entire contents of this folder is the deployment package.  

To deploy monitors in the package:

1. Copy the entire folder to target server in a temp location
2. CD to the temp location 
3. Execute .\deploy.ps1 from PowerShell console

The contents will be copied to c:\jobs-$context and all
script executions SCHTASKS will be relative to c:\jobs-$context. 


To undeploy jobs in the package:

1. CD to package location
2. Execute .\undeploy.ps1 from PowerShell console



Deployment Metadata
-------------------
The deployment metadata for a job is expected to take
the form of [job_name].deploy.

The deployment metadata schema looks like:

`<deploy>
	<job name="MyApp.EventLogWriter" validContexts="Development | QA |Production">
		<arguments context="Development | QA">my non production arguments</arguments>
		<arguments context="Production">production arguments</arguments>
		<arguments>default</arguments>
		<schedule>/SC MINUTE /MO 5</schedule>
		<identity context="Development | QA" username="nonprod_user" password="m2aoRCVVLtWOs9uEN3wTqA=="/>
		<identity context="Production" username="production_user" password="omibYywROvSgRqBgFn5+KQ=="/>
    <enabled> true | false </enabled>
	</job>
</deploy>`


<deploy>
The root deployment element.  There can be only one.

<job>
The root job element.  There can only be one.  Supports a @context override.  
e.g. if a job only exists in a specific context (data center, environment, etc), then include it here.

If the job exists in multiple context, then or (|) them together:

<job context="DEV|QA|PROD|China_PROD">....</job>

attributes:
	@context - overridable
	@name - this is used when creating the job.  This name will be prefixed with the 
	context name. e.g. DEV-MyApp.EventLogWriter

	
<job/action>
If the custom monitor is NOT A POWERSHELL SCRIPT, e.g. custom executable, 
VBS, .BAT, etc.  Then use the <action> element to define the name of the process
to configuref or the scheduled tasks action.

By default, the assumption is that the majority of custom monitors will be powershell
scripts.

This really hasn't been tested or used for that matter.  YMMV.


<job/arguments>
Any arguments that will be passed to the external process.  This element can 
have an @context override.

		<arguments context="Development | QA">my non production arguments</arguments>
		<arguments context="Production">production arguments</arguments>

By default, each process will have the -context argument passed to it 
on the command line.


Attributes:
	@context - the value will be used if @context contains the context value
	

<job/schedule>
This is the schedule using Windows AT format. For a complete list of supported schedule options, please see
SCHTASKS /CREATE /?

Attributes:
	@context - the value will be used if @context contains the context value

	
<job/identity>
This is the identity that the external process will run under.
The default identity can be set in the .\deploy.ps1 script.

If you need a custom account, then you can configure it here.

Attributes:
	@username - the username to run the process under.
	@password - the password to use for the username.  The
		assumption is that the @password value will be hashed.  
		See encrypt-string in .\modules\crypto.ps1 for more info.
        
<job/enabled>
This indicates whether or not the job is enabled/disabled after its created.  By default, the job is created enabled.

      
Attributes:
	@context - the value will be used if @context contains the context value


