

$files=get-childitem src/ -include *.d -rec | ? { !$_.FullName.Contains("llvm") } | Foreach-Object { $_.FullName}

dmd -w -debug -gc -unittest -Isrc "-Jsrc\dlf\gen\c\" "-od.obj" "-ofbin\disc" $files
    