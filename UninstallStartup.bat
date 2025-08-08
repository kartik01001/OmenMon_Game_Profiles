@echo off
setlocal enabledelayedexpansion

REM ==============================================================================
REM  Uninstall Game Performance Manager from Windows Startup
REM  Removes VBS script from shell:startup folder
REM ==============================================================================

title Uninstall Game Performance Manager Startup

echo.
echo ========================================
echo  Uninstall Game Performance Manager
echo       from Windows Startup
echo ========================================
echo.

REM Get Windows startup folder path
for /f "usebackq tokens=3*" %%A in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v Startup 2^>nul`) do (
    set "STARTUP_FOLDER=%%A %%B"
)

REM Fallback if registry lookup fails
if not defined STARTUP_FOLDER (
    set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
)

echo [INFO] Windows startup folder: %STARTUP_FOLDER%
echo.

REM Define VBS script name and path
set "VBS_NAME=GamePerformanceManager_Startup.vbs"
set "VBS_PATH=%STARTUP_FOLDER%\%VBS_NAME%"

echo [INFO] Looking for startup script: %VBS_NAME%
echo [PATH] %VBS_PATH%
echo.

REM Check if the VBS script exists
if not exist "%VBS_PATH%" (
    echo [INFO] Game Performance Manager startup script not found
    echo The script may have already been removed or was never installed
    echo.
    echo Checked location: %VBS_PATH%
    echo.
    pause
    exit /b 0
)

echo [FOUND] Game Performance Manager startup script found
echo.

REM Confirm removal
set /p CONFIRM=Are you sure you want to remove Game Performance Manager from startup? (Y/N): 
if /i not "%CONFIRM%"=="Y" (
    echo [CANCELLED] Uninstallation cancelled by user
    echo.
    pause
    exit /b 0
)

echo.
echo [ACTION] Removing startup script...

REM Delete the VBS script
del "%VBS_PATH%" 2>nul
if errorlevel 1 (
    echo [ERROR] Failed to remove startup script
    echo You may need to run this as Administrator or manually delete:
    echo %VBS_PATH%
    echo.
    pause
    exit /b 1
)

echo [SUCCESS] Startup script removed successfully!
echo.
echo ========================================
echo         UNINSTALLATION COMPLETE
echo ========================================
echo.
echo Game Performance Manager has been removed from Windows startup.
echo.
echo What was removed:
echo - File: %VBS_NAME%
echo - From: %STARTUP_FOLDER%
echo.
echo The Game Performance Manager will no longer start automatically when Windows boots.
echo You can still run it manually using:
echo - GamePerformanceManagerVerbose.bat (with output)
echo - GamePerformanceManagerSilent.bat (background)
echo.
echo To reinstall to startup: run InstallStartup.bat
echo.
pause
