
$files=get-childitem ../runtime/rt/ -include *.dis -rec | Foreach-Object { $_.FullName}

.\bin\disc.exe --no-runtime -sharedlib -o bin/disrt.dll $files