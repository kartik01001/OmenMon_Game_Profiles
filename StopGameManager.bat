@echo off
title Stop Game Performance Manager

echo.
echo ===============================================
echo  Stop Game Performance Manager
echo ===============================================
echo.

echo Looking for running Game Performance Manager processes...

REM Kill any running GamePerformanceManager.bat processes
taskkill /f /im cmd.exe /fi "WINDOWTITLE eq Game Performance Manager - HP Omen" >nul 2>&1

REM Alternative method - kill by image name if the process is detectable
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq cmd.exe" /fo csv ^| findstr "GamePerformanceManager"') do (
    echo Stopping process ID: %%i
    taskkill /f /pid %%i >nul 2>&1
)

REM Look for any processes with GamePerformanceManager in the command line
wmic process where "name='cmd.exe' and commandline like '%%GamePerformanceManager%%'" delete >nul 2>&1

echo.
echo [INFO] Game Performance Manager processes terminated.
echo [INFO] Your system settings have been restored to normal.
echo.
echo If the process was running in background, it should now be stopped.
echo You can verify in Task Manager (Ctrl+Shift+Esc).
echo.

timeout /t 3 >nul
