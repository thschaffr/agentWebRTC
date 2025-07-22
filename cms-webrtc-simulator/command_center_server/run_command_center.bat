@echo off
REM This script downloads a portable Node.js and runs the command center server.
TITLE Command Center Launcher
cd /d "%~dp0"
set LOG_FILE=command_center_log.txt
set SCRIPT_TO_RUN=command_center_server.js
set NODE_VERSION=v20.12.2
set NODE_ARCH=win-x64
set NODE_ZIP_FILENAME=node-%NODE_VERSION%-%NODE_ARCH%.zip
set NODE_FOLDER_NAME=node-%NODE_VERSION%-%NODE_ARCH%
set NODE_URL=https://nodejs.org/dist/%NODE_VERSION%/%NODE_ZIP_FILENAME%
echo. > "%LOG_FILE%"
cls
echo #################################################
echo ##  Command Center Setup & Launcher          ##
echo #################################################
echo.
:CHECK_NODE
echo [STEP 1] Checking for Node.js...
IF EXIST "nodejs\node.exe" (
    echo [INFO] Portable Node.js found.
    goto :RUN_SERVER
)
:DOWNLOAD_NODE
echo [SETUP] Portable Node.js not found. Starting setup...
powershell -Command "Invoke-WebRequest -Uri %NODE_URL% -OutFile %NODE_ZIP_FILENAME%" >> "%LOG_FILE%" 2>&1
IF NOT EXIST "%NODE_ZIP_FILENAME%" ( echo [FATAL ERROR] Failed to download Node.js. Check log file. & goto :end_error )
echo [SETUP] Unzipping Node.js...
powershell -Command "Expand-Archive -Path '%NODE_ZIP_FILENAME%' -DestinationPath '.'" >> "%LOG_FILE%" 2>&1
IF NOT EXIST "%NODE_FOLDER_NAME%" ( echo [FATAL ERROR] Failed to unzip archive. Check log file. & goto :end_error )
ren "%NODE_FOLDER_NAME%" "nodejs" >> "%LOG_FILE%" 2>&1
del "%NODE_ZIP_FILENAME%" >> "%LOG_FILE%" 2>&1
echo [SUCCESS] Portable Node.js is set up.

:RUN_SERVER
echo.
echo ========================================================
echo [INFO] Setup complete. Starting the Command Center server...
echo Your IP address is listed below.
ipconfig | findstr /i "ipv4"
echo ========================================================
echo.
.\nodejs\node.exe %SCRIPT_TO_RUN%
goto :end
:end_error
echo. & echo ################################################## & echo ## AN ERROR OCCURRED. The script has stopped.   ## & echo ## Please check the log file for details.       ## & echo ##################################################
:end
echo. & pause
