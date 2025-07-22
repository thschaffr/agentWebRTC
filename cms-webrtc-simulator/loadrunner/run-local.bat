@echo off
REM =========================================================================
REM ==  The Definitive All-in-One Windows Launcher (Two-Phase Operation)   ==
REM =========================================================================
REM On first run, this script is a SETUP tool.
REM On subsequent runs, it is a LAUNCH tool.

TITLE All-in-One Load Test Tool
cd /d "%~dp0"
set LOG_FILE=load_test_log.txt
set SCRIPT_TO_RUN=final_loadtest.js
set NODE_VERSION=v20.12.2
set NODE_ARCH=win-x64
set NODE_ZIP_FILENAME=node-%NODE_VERSION%-%NODE_ARCH%.zip
set NODE_FOLDER_NAME=node-%NODE_VERSION%-%NODE_ARCH%
set NODE_URL=https://nodejs.org/dist/%NODE_VERSION%/%NODE_ZIP_FILENAME%
echo. > "%LOG_FILE%"
cls
echo #################################################
echo ##  All-in-One WebRTC Load Test Tool           ##
echo #################################################
echo. & echo Logging all actions to: %LOG_FILE% & echo.

:CHECK_NODE
echo [STEP 1] Checking for Node.js...
IF EXIST "nodejs\node.exe" (
    echo [INFO] Portable Node.js found.
    goto :SET_PATH
)
:DOWNLOAD_NODE
echo [SETUP] Portable Node.js not found. Starting setup...
powershell -Command "Invoke-WebRequest -Uri %NODE_URL% -OutFile %NODE_ZIP_FILENAME%" >> "%LOG_FILE%" 2>&1
IF NOT EXIST "%NODE_ZIP_FILENAME%" ( echo [FATAL ERROR] Failed to download Node.js. & goto :end_error )
echo [SETUP] Unzipping Node.js...
powershell -Command "Expand-Archive -Path '%NODE_ZIP_FILENAME%' -DestinationPath '.'" >> "%LOG_FILE%" 2>&1
IF NOT EXIST "%NODE_FOLDER_NAME%" ( echo [FATAL ERROR] Failed to unzip archive. & goto :end_error )
ren "%NODE_FOLDER_NAME%" "nodejs" >> "%LOG_FILE%" 2>&1
del "%NODE_ZIP_FILENAME%" >> "%LOG_FILE%" 2>&1
echo [SUCCESS] Portable Node.js is set up.

:SET_PATH
echo.
echo [STEP 2] Configuring environment...
set "PATH=%CD%\nodejs;%PATH%"
echo [INFO] Portable Node.js has been added to the PATH for this session.

:CHECK_MODULES
echo.
echo [STEP 3] Checking for dependencies...
IF EXIST "node_modules" (
    echo [INFO] Project dependencies found.
    goto :LAUNCH_TEST
)
:INSTALL_MODULES
echo [SETUP] 'node_modules' not found. Running 'npm install'...
npm install >> "%LOG_FILE%" 2>&1
IF %ERRORLEVEL% NEQ 0 ( echo [FATAL ERROR] 'npm install' failed. Check %LOG_FILE%. & goto :end_error )
echo.
echo ##################################################################
echo ##  [SUCCESS] Dependencies installed. Setup is now complete.    ##
echo ##                                                              ##
echo ##  Please double-click 'run.bat' again to launch the test.     ##
echo ##################################################################
goto :end

:LAUNCH_TEST
echo.
echo ========================================================
echo [INFO] Setup is complete. Starting the load test in a NEW window...
echo ========================================================
echo.

REM 'start' launches the process in a new, separate window for a clean experience.
start "WebRTC Load Test (Press Ctrl+C in THIS window to exit)" .\nodejs\node.exe %SCRIPT_TO_RUN%

echo [SUCCESS] Test is now running in a new window.
echo This launcher window will close in 5 seconds.
timeout /t 5 >nul
goto :end

:end_error
echo. & echo ################################################## & echo ## AN ERROR OCCURRED. The script has stopped.   ## & echo ## Please check the log file for details:       ## & echo ## %~dp0%LOG_FILE% & echo ##################################################
:end
echo. & pause
