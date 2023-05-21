@echo off

@REM Build the roblox place for testing
rojo build place.project.json -o %Name%.rbxlx

:restart
choice /c yn /n /m "Would you like to open the place (Y/N)? "

if %errorlevel% == 1 (
    start %Name%.rbxlx
) else if %errorlevel% == 2 (
    exit
) else (
    goto restart
)
