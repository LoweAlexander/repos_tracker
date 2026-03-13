@echo off
setlocal EnableDelayedExpansion


:: DOWNLOADS
where winget >nul 2>&1
if errorlevel 1 (
    echo winget is not available on your system.
    echo Please install Git and GitHub CLI manually:
    echo   Git:        https://git-scm.com/download/win
    echo   GitHub CLI: https://cli.github.com/
    echo.
    echo After installing, re-run this installer.
    goto :exit_script
)

where git >nul 2>&1
if errorlevel 1 (
    echo Git is not installed.
    set /p "INSTALL_GIT=Would you like to install it now? (y/n): "
    if /i "!INSTALL_GIT!"=="y" (
        winget install --id Git.Git -e
    )
)

where gh >nul 2>&1
if errorlevel 1 (
    echo GitHub CLI is not installed.
    set /p "INSTALL_CLI=Would you like to install it now? (y/n): "
    if /i "!INSTALL_CLI!"=="y" (
        winget install --id GitHub.cli -e
    )
)

where git >nul 2>&1
if errorlevel 1 (
    echo Git installation may have failed, please install manually.
    goto :exit_script
)

where gh >nul 2>&1
if errorlevel 1 (
    echo GitHub CLI installation may have failed, please install manually.
    goto :exit_script
)

for /f "usebackq delims=" %%F in (`powershell -command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Choose where to install repo tracker'; if ($f.ShowDialog() -eq 'OK') { $f.SelectedPath }"`) do set "ROOT=%%F"

if "!ROOT!"=="" (
    echo No folder selected, exiting.
    goto :exit_script
)
echo Installing to: !ROOT!



:: GitHub Login

gh auth status >nul 2>&1
if errorlevel 1 (
    gh auth login
)

gh auth status >nul 2>&1
if errorlevel 1 (
    echo.
    echo GitHub CLI is not authenticated.
    echo Run: gh auth login
    goto :exit_script
)



:: Ensure HOME is set as git config requires it
if "!HOME!"=="" (
    set "HOME=%USERPROFILE%"
)

for /f "usebackq delims=" %%E in (`git config --global user.email`) do set "GIT_EMAIL=%%E"
for /f "usebackq delims=" %%N in (`git config --global user.name`) do set "GIT_NAME=%%N"

if "!GIT_EMAIL!"=="" (
    set /p "GIT_EMAIL=Enter your Git email: "
    git config --global user.email "!GIT_EMAIL!"
)

if "!GIT_NAME!"=="" (
    set /p "GIT_NAME=Enter your Git name: "
    git config --global user.name "!GIT_NAME!"
)



:: Set up dirs
cd !ROOT!
if exist "!ROOT!\tracked_repos" (
    echo WARNING: tracked_repos folder already exists at !ROOT!
    set /p "CONTINUE=This may overwrite existing data. Continue anyway? (y/n): "
    if /i "!CONTINUE!" neq "y" goto :exit_script
)

if not exist "!ROOT!\tracked_repos" mkdir "!ROOT!\tracked_repos"
cd "!ROOT!\tracked_repos"

if exist "!ROOT!\tracked_repos\repos_tracker\" (
    echo repos_tracker already exists, skipping clone.
) else (
    gh repo clone LoweAlexander/repos_tracker "!ROOT!\tracked_repos\repos_tracker"
)



:: Find the gist containing tracked_repos.txt
gh gist list --limit 100 > "%TEMP%\gist_list.txt"
for /f "usebackq tokens=1" %%I in ("%TEMP%\gist_list.txt") do (
    gh gist view %%I --files > "%TEMP%\gist_files.txt"
    findstr /i "tracked_repos.txt" "%TEMP%\gist_files.txt" >nul 2>&1
    if not errorlevel 1 (
        set "GIST_ID=%%I"
    )
)

if exist "!ROOT!\tracked_repos\repos_tracker\repos_gist_location.txt" (
    echo WARNING: repos_gist_location.txt already exists.
    set /p "OVERWRITE=Overwrite? (y/n): "
    if /i "!OVERWRITE!" neq "y" goto :exit_script
)

echo !GIST_ID! > "!ROOT!\tracked_repos\repos_tracker\repos_gist_location.txt"
echo Gist ID saved to repos_gist_location.txt



:: Shortcut
set /p "CREATE_SHORTCUT=Would you like to create a desktop shortcut? (y/n): "
if /i "!CREATE_SHORTCUT!"=="y" (
    set "SHORTCUT_TARGET=!ROOT!\tracked_repos\repos_tracker\sync_repos.bat"
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\SYNC REPOS.lnk'); $s.TargetPath = '!SHORTCUT_TARGET!'; $s.IconLocation = '%SystemRoot%\System32\SHELL32.dll,293'; $s.Save()"
)



:: Cleanup
del "%TEMP%\gist_list.txt" >nul 2>&1
del "%TEMP%\gist_match.txt" >nul 2>&1



echo.
echo Installation complete!
echo Run SYNC REPOS from your desktop or !ROOT!\tracked_repos\repos_tracker\sync_repos.bat
echo.

:exit_script
if "%1"=="auto" goto :skippauses
echo|set /p="Press any key to close..."
pause >nul
:skippauses
exit

