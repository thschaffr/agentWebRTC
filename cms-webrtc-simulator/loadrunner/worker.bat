@echo off
REM Windows Load Test WORKER (Final Version)
TITLE Load Test Worker - WAITING
SET COMMAND_CENTER_IP=22.6.1.32
cd /d "%~dp0"
set SCRIPT_TO_RUN=final_loadtest.js
set NODE_EXE_PATH=.\nodejs\node.exe
cls
echo #################################################
echo ##  WebRTC Load Test Worker                  ##
echo #################################################
echo.
:CHECK_SETUP
IF NOT EXIST "nodejs\node.exe" ( echo [ERROR] Node.js is not set up. Run setup first. & pause & exit )
IF NOT EXIST "node_modules" ( echo [ERROR] Dependencies are not installed. Run setup first. & pause & exit )
:WAIT_FOR_SIGNAL
echo [INFO] Connecting to Command Center at http://%COMMAND_CENTER_IP%:8080
echo [INFO] Waiting for the "GO!" signal...
echo.
:LOOP
REM --- MODIFIED to check for plain text 'GO!' ---
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $content = (Invoke-WebRequest -Uri http://%COMMAND_CENTER_IP%:8080 -TimeoutSec 5).Content; if ($content.Trim() -eq 'GO!') { exit 0 } else { exit 1 } } catch { exit 1 }"
IF %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] "GO!" signal received!
    goto :LAUNCH_TEST
)
timeout /t 1 /nobreak > nul
goto :LOOP
:LAUNCH_TEST
TITLE Load Test Worker - RUNNING
echo. & echo ======================================================== & echo [INFO] Launching the load test NOW in a new window... & echo ======================================================== & echo.
start "WebRTC Load Test (Press Ctrl+C to exit)" %NODE_EXE_PATH% %SCRIPT_TO_RUN%
echo [INFO] Test has been launched. This worker will now exit.
timeout /t 3 > nul
exit
