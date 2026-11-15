@echo off
setlocal

set SCRIPT_DIR=%~dp0
pwsh -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%convert-classical-to-mrs.ps1" -Clean %*

endlocal
