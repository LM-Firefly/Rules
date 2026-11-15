@echo off
setlocal

set SCRIPT_DIR=%~dp0
pwsh -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%convert-list-to-classical-yaml.ps1" %*

endlocal