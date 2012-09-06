
$fi = new-object system.io.fileinfo $myinvocation.mycommand.path
$modules = [system.io.path]::Combine($fi.DirectoryName, "modules")
#$modules

$env:ADMIN_HOME = $fi.DirectoryName

write-debug $env:ADMIN_HOME

# import all  .\modules\*.ps1 
#
dir $env:ADMIN_HOME\modules\*.ps1 | foreach-object { import-module $_.FullName }
