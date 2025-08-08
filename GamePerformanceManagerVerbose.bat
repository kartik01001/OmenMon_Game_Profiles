@echo off
setlocal enabledelayedexpansion

REM ==============================================================================
REM  Game Performance Manager for OmenMon (VERBOSE VERSION)
REM  This version shows all actions and status updates in real-time
REM ==============================================================================

title Game Performance Manager - HP Omen (VERBOSE)

REM Get script directory and set config file path
set "SCRIPT_DIR=%~dp0"
set "CONFIG_FILE=%SCRIPT_DIR%GameConfig.txt"

REM Default Configuration Variables (will be overridden by config file)
set "OMENMON_EXE="
set "CHECK_INTERVAL=5"
set "LOG_FILE=%SCRIPT_DIR%GamePerformanceManager.log"
set "GPU_PERFORMANCE_MODE=Maximum"
set "FAN_MODE=Performance"
set "FAN_MAX=true"
set "GPU_RESTORE=Minimum"
set "FAN_RESTORE=Default"

REM State tracking variables
set "GAMING_MODE_ACTIVE=false"
set "GAME_COUNT=0"
set "FAN_REFRESH_COUNTER=0"
set "FAN_REFRESH_INTERVAL=24"

echo.
echo ========================================
echo  Game Performance Manager for OmenMon
echo           VERBOSE DEBUG MODE
echo ========================================
echo.

REM Load configuration from file
echo [INFO] Loading configuration...
call :LoadConfiguration

echo.
echo Configuration Summary:
echo ----------------------
echo Config File: %CONFIG_FILE%
echo OmenMon Path: %OMENMON_EXE%
echo Check Interval: %CHECK_INTERVAL% seconds
echo Games to Monitor: !GAME_COUNT!
echo GPU Mode: %GPU_PERFORMANCE_MODE%
echo Fan Mode: %FAN_MODE%
echo Log File: %LOG_FILE%
echo.

REM Validate OmenMon path is configured
if "%OMENMON_EXE%"=="" (
    echo [ERROR] OMENMON_PATH not configured in GameConfig.txt
    echo Please edit GameConfig.txt and set the correct path to OmenMon.exe
    pause
    exit /b 1
)

REM Check if OmenMon is available
echo [INFO] Checking if OmenMon is accessible...
where "%OMENMON_EXE%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] OmenMon.exe not found at: %OMENMON_EXE%
    echo Please ensure OmenMon is installed and the path is correct
    pause
    exit /b 1
) else (
    echo [SUCCESS] OmenMon found and accessible
)

echo.
echo [INFO] Monitored Games List:
echo -------------------------
for %%G in (!GAME_LIST!) do (
    echo   - %%G
)

echo.
echo Press Ctrl+C to stop monitoring
echo ========================================
echo Starting monitoring loop...
echo.

REM Get current settings for restoration
call :GetCurrentSettings

REM Main monitoring loop
:MonitorLoop
call :CheckGames
if "!GAME_RUNNING!"=="true" (
    if "!GAMING_MODE_ACTIVE!"=="false" (
        echo.
        echo ^>^>^> GAME DETECTED ^<^<^<
        call :ApplyGamingProfile
        set "FAN_REFRESH_COUNTER=0"
    ) else (
        REM Handle fan refresh to prevent 130-second timeout
        set /a FAN_REFRESH_COUNTER+=1
        if !FAN_REFRESH_COUNTER! GEQ !FAN_REFRESH_INTERVAL! (
            echo [REFRESH] Refreshing fan settings to prevent timeout...
            call :RefreshFanSettings
            set "FAN_REFRESH_COUNTER=0"
        )
    )
) else (
    if "!GAMING_MODE_ACTIVE!"=="true" (
        echo.
        echo ^>^>^> GAME CLOSED ^<^<^<
        call :RestoreOriginalProfile
        set "FAN_REFRESH_COUNTER=0"
    )
)

REM Display status
call :DisplayStatus

REM Wait before next check
timeout /t %CHECK_INTERVAL% >nul 2>&1
goto MonitorLoop

REM ==============================================================================
REM Functions
REM ==============================================================================

:LoadConfiguration
echo [CONFIG] Loading configuration from %CONFIG_FILE%...
if not exist "%CONFIG_FILE%" (
    echo [WARNING] Configuration file not found, creating default...
    call :CreateDefaultConfig
)

set "IN_GAMES_SECTION=false"
set "GAME_COUNT=0"
set "GAME_LIST="

for /f "usebackq delims=" %%A in ("%CONFIG_FILE%") do (
    set "LINE=%%A"
    if not "!LINE!"=="" (
        if not "!LINE:~0,1!"=="#" (
            if "!LINE!"=="[GAMES]" (
                set "IN_GAMES_SECTION=true"
                echo [CONFIG] Entering GAMES section
            ) else if "!LINE:~0,1!"=="[" (
                set "IN_GAMES_SECTION=false"
                echo [CONFIG] Entering !LINE! section
            ) else (
                if "!IN_GAMES_SECTION!"=="true" (
                    set /a GAME_COUNT+=1
                    if "!GAME_LIST!"=="" (
                        set "GAME_LIST=!LINE!"
                    ) else (
                        set "GAME_LIST=!GAME_LIST! !LINE!"
                    )
                    echo [CONFIG] Added game: !LINE!
                ) else (
                    echo !LINE! | findstr "=" >nul
                    if not errorlevel 1 (
                        for /f "tokens=1,2 delims==" %%B in ("!LINE!") do (
                            set "KEY=%%B"
                            set "VALUE=%%C"
                            if "!KEY!"=="OMENMON_PATH" (
                                set "OMENMON_EXE=!VALUE!"
                                echo [CONFIG] Set OmenMon path: !VALUE!
                            )
                            if "!KEY!"=="CHECK_INTERVAL" (
                                set "CHECK_INTERVAL=!VALUE!"
                                echo [CONFIG] Set check interval: !VALUE! seconds
                            )
                            if "!KEY!"=="LOG_FILE" (
                                set "LOG_FILE=!VALUE!"
                                echo [CONFIG] Set log file: !VALUE!
                            )
                            if "!KEY!"=="GPU_MODE" (
                                set "GPU_PERFORMANCE_MODE=!VALUE!"
                                echo [CONFIG] Set GPU mode: !VALUE!
                            )
                            if "!KEY!"=="FAN_MODE" (
                                set "FAN_MODE=!VALUE!"
                                echo [CONFIG] Set fan mode: !VALUE!
                            )
                            if "!KEY!"=="GPU_RESTORE" (
                                set "GPU_RESTORE=!VALUE!"
                                echo [CONFIG] Set GPU restore: !VALUE!
                            )
                            if "!KEY!"=="FAN_RESTORE" (
                                set "FAN_RESTORE=!VALUE!"
                                echo [CONFIG] Set fan restore: !VALUE!
                            )
                        )
                    )
                )
            )
        )
    )
)

if !GAME_COUNT! EQU 0 (
    echo [WARNING] No games found in configuration, using defaults
    set "GAME_LIST=cyberpunk2077.exe witcher3.exe valorant.exe csgo.exe"
    set "GAME_COUNT=4"
)

echo [CONFIG] Configuration loaded: !GAME_COUNT! games to monitor
call :LogMessage "Configuration loaded: !GAME_COUNT! games to monitor"
goto :eof

:CreateDefaultConfig
echo [CONFIG] Creating default configuration file...
(
echo # Game Performance Manager Configuration
echo # Add your game executables below under [GAMES] section
echo.
echo [GENERAL]
echo OMENMON_PATH=OmenMon.exe
echo CHECK_INTERVAL=5
echo LOG_FILE=GamePerformanceManager.log
echo.
echo [GAMES]
echo cyberpunk2077.exe
echo witcher3.exe
echo valorant.exe
echo csgo.exe
echo dota2.exe
echo.
echo [PERFORMANCE]
echo GPU_MODE=Maximum
echo FAN_MODE=Performance
echo GPU_RESTORE=Minimum
echo FAN_RESTORE=Default
) > "%CONFIG_FILE%"
echo [CONFIG] Default configuration created
call :LogMessage "Default configuration file created"
goto :eof

:CheckGames
set "GAME_RUNNING=false"
for %%G in (!GAME_LIST!) do (
    tasklist /fi "imagename eq %%G" | findstr /i "%%G" >nul 2>&1
    if not errorlevel 1 (
        set "GAME_RUNNING=true"
        set "CURRENT_GAME=%%G"
        goto :eof
    )
)
goto :eof

:GetCurrentSettings
echo [INIT] Capturing current system settings...
echo [INIT] System initialized, waiting for games...
call :LogMessage "System initialized, waiting for games..."
goto :eof

:ApplyGamingProfile
echo.
echo ===============================
echo   ACTIVATING GAMING PROFILE
echo ===============================
echo [GAMING MODE] Game detected: !CURRENT_GAME!
echo [GAMING MODE] Applying high-performance settings...
call :LogMessage "Gaming mode activated - Game: !CURRENT_GAME!"

echo.
echo [STEP 1] Setting fans to maximum speed...
echo [ACTION] Enabling maximum fan speed...
"%OMENMON_EXE%" -Bios FanMax=true
if errorlevel 1 (
    echo [WARNING] Failed to set fans to maximum
    call :LogMessage "WARNING: Failed to set fans to maximum"
) else (
    echo [SUCCESS] Fans set to maximum speed
    call :LogMessage "Fans set to maximum speed"
)

echo.
echo [STEP 2] Setting fan mode to Performance...
echo [ACTION] Applying Performance fan profile...
"%OMENMON_EXE%" -Bios FanMode=Performance
if errorlevel 1 (
    echo [WARNING] Failed to set fan mode to Performance
    call :LogMessage "WARNING: Failed to set fan mode to Performance"
) else (
    echo [SUCCESS] Fan mode set to Performance
    call :LogMessage "Fan mode set to Performance"
)

echo.
echo [STEP 4] Setting GPU to maximum performance...
echo [ACTION] Applying maximum GPU performance mode...
"%OMENMON_EXE%" -Bios Gpu=Maximum
if errorlevel 1 (
    echo [WARNING] Failed to set GPU to maximum performance
    call :LogMessage "WARNING: Failed to set GPU to maximum performance"
) else (
    echo [SUCCESS] GPU set to maximum performance
    call :LogMessage "GPU set to maximum performance"
)

set "GAMING_MODE_ACTIVE=true"
echo.
echo [SUCCESS] Gaming profile applied successfully!
echo [SUCCESS] System optimized for: !CURRENT_GAME!
echo ===============================
call :LogMessage "Gaming profile applied successfully for !CURRENT_GAME!"
goto :eof

:RestoreOriginalProfile
echo.
echo ================================
echo   RESTORING ORIGINAL PROFILE
echo ================================
echo [RESTORE] Game closed: !CURRENT_GAME!
echo [RESTORE] Restoring normal system settings...
call :LogMessage "Gaming mode deactivated - Restoring original settings"

echo.
echo [STEP 1] Disabling maximum fan speed...
echo [ACTION] Turning off maximum fan speed...
"%OMENMON_EXE%" -Bios FanMax=false
if errorlevel 1 (
    echo [WARNING] Failed to disable maximum fan speed
    call :LogMessage "WARNING: Failed to disable maximum fan speed"
) else (
    echo [SUCCESS] Maximum fan speed disabled
    call :LogMessage "Maximum fan speed disabled"
)

echo.
echo [STEP 2] Setting fan mode to default...
echo [ACTION] Restoring default fan profile...
"%OMENMON_EXE%" -Bios FanMode=Default
if errorlevel 1 (
    echo [WARNING] Failed to set default fan mode
    call :LogMessage "WARNING: Failed to set default fan mode"
) else (
    echo [SUCCESS] Fan mode restored to Default
    call :LogMessage "Fan mode restored to Default"
)

echo.
echo [STEP 3] Restoring GPU settings...
echo [ACTION] Setting GPU to minimum performance mode...
"%OMENMON_EXE%" -Bios Gpu=Minimum
if errorlevel 1 (
    echo [WARNING] Failed to restore GPU settings
    call :LogMessage "WARNING: Failed to restore GPU settings"
) else (
    echo [SUCCESS] GPU settings restored to minimum
    call :LogMessage "GPU settings restored to minimum"
)

set "GAMING_MODE_ACTIVE=false"
echo.
echo [SUCCESS] Original profile restored!
echo [SUCCESS] System returned to normal operation
echo ================================
call :LogMessage "Original profile restored successfully"
goto :eof

:RefreshFanSettings
echo [REFRESH] Refreshing fan settings (preventing 130s timeout)...
echo [ACTION] Re-applying maximum fan speed...
"%OMENMON_EXE%" -Bios FanMax=true
if errorlevel 1 (
    echo [WARNING] Failed to refresh fan maximum setting
    call :LogMessage "WARNING: Failed to refresh fan maximum setting"
) else (
    echo [SUCCESS] Fan maximum setting refreshed
    call :LogMessage "Fan settings refreshed to prevent timeout"
)
goto :eof

:DisplayStatus
set "STATUS_MODE=Normal Profile"
set "STATUS_COLOR=37"
set "FAN_STATUS=Automatic"
set "GPU_STATUS=Minimum"

if "!GAMING_MODE_ACTIVE!"=="true" (
    set "STATUS_MODE=GAMING PROFILE ACTIVE"
    set "STATUS_COLOR=92"
    set "FAN_STATUS=100% Constant"
    set "GPU_STATUS=Maximum"
)

REM Get current time
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list 2^>nul') do (
    if not "%%I"=="" set "DATETIME=%%I"
)
set "CURRENT_TIME=%DATETIME:~8,2%:%DATETIME:~10,2%:%DATETIME:~12,2%"

REM Display comprehensive status
echo.
echo ----------------------------------------
echo [%CURRENT_TIME%] System Status: !STATUS_MODE!
echo                   Fans: !FAN_STATUS!
echo                   GPU:  !GPU_STATUS!
if "!GAMING_MODE_ACTIVE!"=="true" (
    echo                   Game: !CURRENT_GAME!
)
echo ----------------------------------------
goto :eof

:LogMessage
set "MSG=%~1"
set "LOGTIME=%date% %time%"
echo [%LOGTIME%] %MSG% >> "%LOG_FILE%"
goto :eof

:Cleanup
echo.
echo ========================================
echo           SHUTTING DOWN
echo ========================================
echo [CLEANUP] Cleaning up and restoring settings...
call :LogMessage "Game Performance Manager stopping - cleanup initiated"
if "!GAMING_MODE_ACTIVE!"=="true" (
    echo [CLEANUP] Gaming mode is active, restoring normal settings...
    call :RestoreOriginalProfile
)
echo [CLEANUP] Cleanup completed
call :LogMessage "Game Performance Manager stopped"
echo.
echo Game Performance Manager stopped.
pause
exit /b 0

REM Handle Ctrl+C
:CtrlC
call :Cleanup
