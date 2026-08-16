@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "R4OS_DOCS_INVENTORY_SCRIPT=%~dp0DocsInventory.ps1"
set "R4OS_DOCS_INVENTORY_MODE=%~1"
if not defined R4OS_DOCS_INVENTORY_MODE set "R4OS_DOCS_INVENTORY_MODE=-Update"

if /i "%R4OS_DOCS_INVENTORY_MODE%"=="-Initial" goto run
if /i "%R4OS_DOCS_INVENTORY_MODE%"=="-Update" goto run
if /i "%R4OS_DOCS_INVENTORY_MODE%"=="-Check" goto run
if /i "%R4OS_DOCS_INVENTORY_MODE%"=="-Help" goto usage_ok
if /i "%R4OS_DOCS_INVENTORY_MODE%"=="--Help" goto usage_ok
if /i "%R4OS_DOCS_INVENTORY_MODE%"=="/?" goto usage_ok
goto usage

:run
if not "%~2"=="" goto usage
if not exist "%R4OS_DOCS_INVENTORY_SCRIPT%" (
    echo FEHLER: Docs-Inventarskript fehlt: "%R4OS_DOCS_INVENTORY_SCRIPT%"
    endlocal & exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%R4OS_DOCS_INVENTORY_SCRIPT%" %R4OS_DOCS_INVENTORY_MODE%
set "R4OS_DOCS_INVENTORY_EXIT=%ERRORLEVEL%"
endlocal & exit /b %R4OS_DOCS_INVENTORY_EXIT%

:usage
call :print_usage
endlocal & exit /b 1

:usage_ok
call :print_usage
endlocal & exit /b 0

:print_usage
echo Verwendung:
echo   DocsInventory.bat -Initial
echo   DocsInventory.bat -Update
echo   DocsInventory.bat -Check
echo.
echo -Initial ersetzt die bestehende Liste bewusst und setzt alle Status auf New.
echo -Update ergaenzt und entfernt Dateien, behaelt aber manuelle Felder bei.
echo -Check ist das schreibfreie Dokumentinventar-Gate.
exit /b 0
