@echo off
setlocal enabledelayedexpansion

REM ==============================================================================
REM  Game Performance Manager for OmenMon (Silent Background Version)
REM ==============================================================================

title Game Performance Manager - HP Omen

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

REM Load configuration from file
call :LoadConfiguration >nul 2>&1

REM Validate OmenMon path is configured
if "%OMENMON_EXE%"=="" (
    call :LogMessage "ERROR: OMENMON_PATH not configured in GameConfig.txt"
    exit /b 1
)

REM Check if OmenMon is available
where "%OMENMON_EXE%" >nul 2>&1
if errorlevel 1 (
    call :LogMessage "ERROR: OmenMon.exe not found"
    exit /b 1
)

REM Get current settings for restoration
call :GetCurrentSettings

REM Main monitoring loop
:MonitorLoop
call :CheckGames
if "!GAME_RUNNING!"=="true" (
    if "!GAMING_MODE_ACTIVE!"=="false" (
        call :ApplyGamingProfile
        set "FAN_REFRESH_COUNTER=0"
    ) else (
        REM Handle fan refresh to prevent 130-second timeout
        set /a FAN_REFRESH_COUNTER+=1
        if !FAN_REFRESH_COUNTER! GEQ !FAN_REFRESH_INTERVAL! (
            call :RefreshFanSettings
            set "FAN_REFRESH_COUNTER=0"
        )
    )
) else (
    if "!GAMING_MODE_ACTIVE!"=="true" (
        call :RestoreOriginalProfile
        set "FAN_REFRESH_COUNTER=0"
    )
)

REM Wait before next check
timeout /t %CHECK_INTERVAL% >nul 2>&1
goto MonitorLoop

REM ==============================================================================
REM Functions
REM ==============================================================================

:LoadConfiguration
if not exist "%CONFIG_FILE%" (
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
            ) else if "!LINE:~0,1!"=="[" (
                set "IN_GAMES_SECTION=false"
            ) else (
                if "!IN_GAMES_SECTION!"=="true" (
                    set /a GAME_COUNT+=1
                    if "!GAME_LIST!"=="" (
                        set "GAME_LIST=!LINE!"
                    ) else (
                        set "GAME_LIST=!GAME_LIST! !LINE!"
                    )
                ) else (
                    echo !LINE! | findstr "=" >nul
                    if not errorlevel 1 (
                        for /f "tokens=1,2 delims==" %%B in ("!LINE!") do (
                            set "KEY=%%B"
                            set "VALUE=%%C"
                            if "!KEY!"=="OMENMON_PATH" (
                                set "OMENMON_EXE=!VALUE!"
                            )
                            if "!KEY!"=="CHECK_INTERVAL" set "CHECK_INTERVAL=!VALUE!"
                            if "!KEY!"=="LOG_FILE" set "LOG_FILE=!VALUE!"
                            if "!KEY!"=="GPU_MODE" set "GPU_PERFORMANCE_MODE=!VALUE!"
                            if "!KEY!"=="FAN_MODE" set "FAN_MODE=!VALUE!"
                            if "!KEY!"=="GPU_RESTORE" set "GPU_RESTORE=!VALUE!"
                            if "!KEY!"=="FAN_RESTORE" set "FAN_RESTORE=!VALUE!"
                        )
                    )
                )
            )
        )
    )
)

if !GAME_COUNT! EQU 0 (
    set "GAME_LIST=cyberpunk2077.exe witcher3.exe valorant.exe csgo.exe"
    set "GAME_COUNT=4"
)

call :LogMessage "Configuration loaded: !GAME_COUNT! games to monitor"
goto :eof

:CreateDefaultConfig
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
call :LogMessage "System initialized, waiting for games..."
goto :eof

:ApplyGamingProfile
call :LogMessage "Gaming mode activated - Game: !CURRENT_GAME!"

REM Set fans to maximum speed
"%OMENMON_EXE%" -Bios FanMax=true >nul 2>&1
if errorlevel 1 (
    call :LogMessage "WARNING: Failed to set fans to maximum"
) else (
    call :LogMessage "Fans set to maximum speed"
)

"%OMENMON_EXE%" -Bios FanMode=Performance >nul 2>&1
if errorlevel 1 (
    call :LogMessage "WARNING: Failed to set fan mode to Performance"
) else (
    call :LogMessage "Fan mode set to Performance"
)

"%OMENMON_EXE%" -Bios Gpu=Maximum >nul 2>&1
if errorlevel 1 (
    call :LogMessage "WARNING: Failed to set GPU to maximum performance"
) else (
    call :LogMessage "GPU set to maximum performance"
)

set "GAMING_MODE_ACTIVE=true"
call :LogMessage "Gaming profile applied successfully"
goto :eof

:RestoreOriginalProfile
call :LogMessage "Gaming mode deactivated - Restoring original settings"

REM Disable maximum fan speed
"%OMENMON_EXE%" -Bios FanMax=false >nul 2>&1
if errorlevel 1 (
    call :LogMessage "WARNING: Failed to disable maximum fan speed"
) else (
    call :LogMessage "Maximum fan speed disabled"
)

"%OMENMON_EXE%" -Bios FanMode=Default >nul 2>&1
if errorlevel 1 (
    call :LogMessage "WARNING: Failed to restore default fan mode"
) else (
    call :LogMessage "Fan mode restored to Default"
)

"%OMENMON_EXE%" -Bios Gpu=Minimum >nul 2>&1
if errorlevel 1 (
    call :LogMessage "WARNING: Failed to restore GPU settings"
) else (
    call :LogMessage "GPU settings restored"
)

set "GAMING_MODE_ACTIVE=false"
call :LogMessage "Original profile restored"
goto :eof

:RefreshFanSettings
"%OMENMON_EXE%" -Bios FanMax=true >nul 2>&1
if errorlevel 1 (
    call :LogMessage "WARNING: Failed to refresh fan maximum setting"
) else (
    call :LogMessage "Fan settings refreshed to prevent timeout"
)
goto :eof

:LogMessage
set "MSG=%~1"
set "LOGTIME=%date% %time%"
echo [%LOGTIME%] %MSG% >> "%LOG_FILE%"
goto :eof

:Cleanup
call :LogMessage "Game Performance Manager stopped"
if "!GAMING_MODE_ACTIVE!"=="true" (
    call :RestoreOriginalProfile
)
exit /b 0
