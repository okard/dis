

$files=get-childitem src/ -include *.d -rec | ? { !$_.FullName.Contains("llvm") } | Foreach-Object { $_.FullName}

dmd -w -debug -gc -Isrc -unittest "-od.obj" -ofbin\disc $files
    