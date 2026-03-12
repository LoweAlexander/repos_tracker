@echo off
setlocal EnableDelayedExpansion

set "ROOT=C:\Users\%USERNAME%\Documents\phd_code_repos"
set "GIST_LOCATION_FILE=%ROOT%\github_utilities\repos_gist_location.txt"

if not exist "%GIST_LOCATION_FILE%" (
    echo ERROR: Cannot find repos_gist_location.txt
    echo Expected location: %GIST_LOCATION_FILE%
    echo Please create this file and add your Gist ID to it.
    goto :exit_script
)
set /p GIST_ID=<"%GIST_LOCATION_FILE%"

if "!GIST_ID!"=="" (
    echo ERROR: repos_gist_location.txt is empty.
    echo Please add your Gist ID to it.
    goto :exit_script
)

pushd "%ROOT%\github_utilities"
git remote get-url origin > "%TEMP%\remote_url.txt"
set /p REMOTE_URL=<"%TEMP%\remote_url.txt"
echo REMOTE_URL = !REMOTE_URL!
for /f "tokens=3 delims=/" %%U in ("!REMOTE_URL!") do set "GITHUB_USER=%%U"
echo GITHUB_USER = !GITHUB_USER!
popd


echo ==============
echo Repo Sync Tool
echo ==============
echo.

gh auth status >nul 2>&1
if errorlevel 1 (
    echo.
    echo GitHub CLI is not authenticated.
    echo Run: gh auth login
    goto :exit_script
)

echo gh auth status: True
echo.

echo ROOT = %ROOT%
echo.

for /f "tokens=*" %%T in ('echo %time%') do set "t=%%T"
set "t=%t::=-%"


echo ------------------
echo Updating Repo List
echo ------------------
echo.

echo Fetching repo list from Gist.
gh gist view %GIST_ID% --filename tracked_repos.txt> "%TEMP%\repos.txt"
echo.

for /f "usebackq tokens=* eol=#" %%R in ("%TEMP%\repos.txt") do (
    set "REPO=%%R"
    echo Repo = !REPO!
    if not exist "%ROOT%\!REPO!" (
        echo Cloning !REPO!.
        gh repo clone !REPO! "%ROOT%\!REPO!"
    ) else (
        echo !REPO! already exists, skipping.
    )
)


echo ----------
echo SYNC REPOS
echo ----------
echo.

for /d %%G in ("%ROOT%\*") do (

    
    set "NAME=%%~nxG"
    cd /d "%%G"

    echo -------------------------
    echo Checking !NAME!
    echo -------------------------
    echo.

    if not exist ".git" (

        echo No git repository detected.

        echo Create GitHub repo for !NAME!?
	set /p answer=y/n:
        echo.

        if /i "!answer!"=="y" (

            if not exist ".gitignore" (

    		echo Creating .gitignore.

    		copy "!ROOT!\github_utilities\gitignore_template.txt" ".gitignore" >nul
	    )

	    echo Initialising git repository.
	    echo.
            git init

            git add .
            git commit -m "Initial commit"

            echo Creating GitHub repo...
	    echo.
            gh repo create !NAME! --private --source=. --remote=origin --push

	    echo Adding !GITHUB_USER!/!NAME! to repo list...
	    gh gist view %GIST_ID% > "%TEMP%\repos.txt"
	    echo !GITHUB_USER!/!NAME! >> "%TEMP%\repos.txt"
	    gh gist edit %GIST_ID% "%TEMP%\repos.txt"

        ) else (

            echo Skipping !NAME!
            echo.
        )

    ) else (
        echo Syncing existing repository.
        git add .
        git diff --cached --quiet
        if errorlevel 1 (
            git commit -m "Auto-sync %COMPUTERNAME% %date% %t%"
        )
        git pull --rebase
        git push
    )

    echo.

)

echo =============
echo Sync Complete
echo =============
echo.


:exit_script
if "%1"=="auto" goto :skippauses
echo|set /p="Press any key to close..."
pause >nul
:skippauses
exit



