@echo off
title Binuxx CLI
color 0a

:: Current Binuxx version
set BINUX_VERSION=1.0.2

:: Hidden user database and update info
set "USER_DB=%~dp0.users.dat"
set "UPDATE_FILE=%~dp0.new_update.bat"

:: Ensure user database exists
if not exist "%USER_DB%" (
    echo No user database found. Launching first-time setup wizard...
    goto :first_time_setup
)

:: Check if the user database is empty
for /f %%A in ('type "%USER_DB%" ^| find /c ":"') do (
    if %%A==0 goto :first_time_setup
)

:: Begin Login Process
call :login

:main_menu
cls
echo ===================================================
echo Welcome to Binuxx, %USERNAME%! You are logged in as %USERTYPE%.
echo Type 'help' for a list of commands or 'exit' to quit.
echo ===================================================
set /p COMMAND="Binuxx> "

:: Commands
if "%COMMAND%"=="help" goto :help
if "%COMMAND%"=="ls" goto :ls
if "%COMMAND%"=="pwd" goto :pwd
if "%COMMAND%"=="clear" goto :clear
if "%COMMAND%"=="exit" goto :exit
if "%COMMAND%"=="time" goto :time_cmd
if "%COMMAND%"=="date" goto :date_cmd
if "%COMMAND%"=="whoami" goto :whoami
if "%COMMAND%"=="sysinfo" goto :sysinfo
if "%COMMAND%"=="calc" goto :calc
if "%COMMAND%"=="shutdown" goto :shutdown
if "%COMMAND%"=="reboot" goto :reboot
if "%COMMAND%"=="echo" goto :echo_cmd
if "%COMMAND%"=="cat" goto :cat
if "%COMMAND%"=="touch" goto :touch
if "%COMMAND%"=="rm" goto :rm
if "%COMMAND%"=="mkdir" goto :mkdir
if "%COMMAND%"=="update" goto :update
if "%COMMAND%"=="upgrade" goto :upgrade
if "%COMMAND%"=="progress" goto :progress
echo Unknown command: %COMMAND%
pause
goto :main_menu

:help
echo ===================================================
echo Available Commands:
echo ls        - List directory contents
echo pwd       - Show current directory
echo clear     - Clear the screen
echo time      - Display the current time
echo date      - Display the current date
echo whoami    - Show the current logged-in user
echo sysinfo   - Show system information
echo calc      - Simple calculator
echo shutdown  - Shutdown the system (mock)
echo reboot    - Reboot the system (mock)
echo echo      - Display text
echo cat       - Display contents of a file
echo touch     - Create an empty file
echo rm        - Delete a file
echo mkdir     - Create a directory
echo update    - Check for updates
echo upgrade   - Upgrade the system
echo progress  - Show a sample progress bar
echo exit      - Log out and exit
echo ===================================================
pause
goto :main_menu

:: Command Definitions

:ls
dir /b
pause
goto :main_menu

:pwd
cd
pause
goto :main_menu

:clear
cls
pause
goto :main_menu

:time_cmd
time /t
pause
goto :main_menu

:date_cmd
date /t
pause
goto :main_menu

:whoami
echo You are logged in as %USERNAME%.
pause
goto :main_menu

:sysinfo
echo ===================================================
echo System Information:
echo OS: Binuxx 1.0
echo Logged-in User: %USERNAME%
echo Current Directory: %CD%
echo ===================================================
pause
goto :main_menu

:calc
set /p "expr=Enter calculation (e.g., 5+3): "
set /a result=%expr%
echo Result: %result%
pause
goto :main_menu

:shutdown
echo Shutting down the system...
pause
goto :main_menu

:reboot
echo Rebooting the system...
pause
goto :main_menu

:echo_cmd
set /p "text=Enter text to display: "
echo %text%
pause
goto :main_menu

:cat
set /p "file=Enter file name to read: "
type "%file%"
pause
goto :main_menu

:touch
set /p "file=Enter file name to create: "
type nul > "%file%"
echo File '%file%' created.
pause
goto :main_menu

:rm
set /p "file=Enter file name to delete: "
del "%file%" 2>nul && echo File deleted. || echo File not found.
pause
goto :main_menu

:mkdir
set /p "dir=Enter directory name to create: "
mkdir "%dir%" && echo Directory created. || echo Directory already exists.
pause
goto :main_menu

:progress
for /L %%i in (1,1,100) do (
    cls
    echo Progress: %%i%%
    timeout /nobreak /t 1 >nul
)
pause
goto :main_menu

:first_time_setup
cls
echo ===================================================
echo                  Binuxx Setup Wizard
echo ===================================================
echo Welcome! No users are currently registered.
echo Let's create the first admin account.
echo ===================================================
set /p ADMIN_USER="Enter admin username: "
set /p ADMIN_PASS="Enter admin password: "
echo %ADMIN_USER%:%ADMIN_PASS% > "%USER_DB%"
echo Admin account created successfully!
pause
goto :login

:login
cls
echo ===================================================
echo                    Binuxx Login
echo ===================================================
:retry_login
set "USERNAME="
set "PASSWORD="

set /p USERNAME="Username: "
set /p PASSWORD="Password: "

:: Compare username and password
for /f "tokens=1-2 delims=:" %%a in ('findstr /i "^%USERNAME%:" "%USER_DB%"') do (
    set "stored_user=%%a"
    set "stored_pass=%%b"
    
    if "%stored_user%"=="%USERNAME%" if "%stored_pass%"=="%PASSWORD%" (
        set "USERNAME=%stored_user%"
        set "USERTYPE=user"  :: Assuming regular user; can modify to set "admin" for specific usernames.
        goto :main_menu
    )
)

echo Invalid username or password. Try again.
pause
goto :retry_login

:update
echo Checking for updates...
timeout /t 1 >nul

:: URL for version check and updated software
set "VERSION_URL=https://raw.githubusercontent.com/letsmanueldev/binuxx/refs/heads/main/binnuxupdatechecker.txt"
set "UPDATE_URL=https://raw.githubusercontent.com/letsmanueldev/binuxx/refs/heads/main/binuxxsoftware.bat"
set "TEMP_VERSION_FILE=%~dp0temp_version.txt"
set "TEMP_UPDATE_FILE=%~dp0temp_update.bat"

:: Download the remote version file
curl -s -o "%TEMP_VERSION_FILE%" "%VERSION_URL%" || powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%VERSION_URL%', '%TEMP_VERSION_FILE%')"

if not exist "%TEMP_VERSION_FILE%" (
    echo Failed to check for updates. Please check your internet connection.
    pause
    goto :main_menu
)

:: Read the remote version from the file
set /p REMOTE_VERSION=<"%TEMP_VERSION_FILE%"
del "%TEMP_VERSION_FILE%"

:: Compare versions
call :compare_versions "%BINUX_VERSION%" "%REMOTE_VERSION%"
if %ERRORLEVEL%==1 (
    echo A newer version (%REMOTE_VERSION%) is available. Downloading update...
    curl -s -o "%TEMP_UPDATE_FILE%" "%UPDATE_URL%" || powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%UPDATE_URL%', '%TEMP_UPDATE_FILE%')"
    
    if exist "%TEMP_UPDATE_FILE%" (
        echo Update downloaded. You can now run 'upgrade' to apply it.
    ) else (
        echo Failed to download the update. Please try again later.
    )
) else (
    echo You are already on the latest version (%BINUX_VERSION%).
)

pause
goto :main_menu

:upgrade
echo Upgrading the system...
timeout /t 1 >nul

:: Check if update file exists before attempting to apply
if not exist "%TEMP_UPDATE_FILE%" (
    echo Error: No update file found. Please ensure that the update process was successful before attempting to upgrade.
    pause
    goto :main_menu
)

:: Apply the update
echo Applying the update...
call "%TEMP_UPDATE_FILE%" || (
    echo Failed to apply the update. Please try again later.
    pause
    goto :main_menu
)

del "%TEMP_UPDATE_FILE%"

echo Update applied successfully. Restarting Binuxx...
start "" "%~f0"
exit

:: Version Comparison Logic
:compare_versions
:: Parameters: %1 = local version, %2 = remote version
:: Returns ERRORLEVEL 1 if remote > local, otherwise 0
setlocal enabledelayedexpansion

set "local=%~1"
set "remote=%~2"

:: Split versions into parts
for /f "tokens=1-3 delims=." %%a in ("%local%") do set "local1=%%a" & set "local2=%%b" & set "local3=%%c"
for /f "tokens=1-3 delims=." %%a in ("%remote%") do set "remote1=%%a" & set "remote2=%%b" & set "remote3=%%c"

:: Compare versions
if !remote1! gtr !local1! (
    endlocal
    exit /b 1
) else if !remote1! lss !local1! (
    endlocal
    exit /b 0
) else if !remote2! gtr !local2! (
    endlocal
    exit /b 1
) else if !remote2! lss !local2! (
    endlocal
    exit /b 0
) else if !remote3! gtr !local3! (
    endlocal
    exit /b 1
) else if !remote3! lss !local3! (
    endlocal
    exit /b 0
)

endlocal
exit /b 0

:exit
echo Logging out...
exit
