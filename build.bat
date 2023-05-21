@echo off

@REM Define the name of the project
for /f "tokens=1,2 delims=:{} " %%A in (default.project.json) do (
    If "%%~A"=="name" set Name=%%~B
)

set Name=%Name:",=%

@REM Create the Sourcemap.json
@REM Downloaded jq from https://stedolan.github.io/jq/
echo Building sourcemap.json
rojo sourcemap | jq . > sourcemap.json
echo Built sourcemap.json

:restart
echo What would you like to do?
echo 1 - Build %Name%.rbxlx
echo 2 - Build %Name%.rbxmx

choice /c 12 /n /m "Choose a option: "

if %errorlevel% == 1 (
    BuildPlace.bat
) else if %errorlevel% == 2 (
    BuildModel.bat
) else (
    goto restart
)