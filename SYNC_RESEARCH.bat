@echo off
setlocal EnableDelayedExpansion

set "ROOT=C:\Users\%USERNAME%\Documents\phd_code_repos"

echo ==============
echo Repo Sync Tool
echo ==============
echo.

gh auth status >nul 2>&1
if errorlevel 1 (
    echo.
    echo GitHub CLI is not authenticated.
    echo Run: gh auth login
    pause
    exit /b
)

echo gh auth status: True
echo.

echo ROOT = %ROOT%
echo.

for /f "tokens=*" %%T in ('echo %time%') do set "t=%%T"
set "t=%t::=-%"

for /d %%G in ("%ROOT%\*") do (

    
    set "NAME=%%~nxG"
    cd /d "%%G"

    echo -------------------------
    echo Checking !NAME!
    echo -------------------------

    if not exist ".git" (

        echo No git repository detected.

        echo Create GitHub repo for !NAME!?
	set /p answer=y/n:
        echo.

        if /i "!answer!"=="y" (

            if not exist ".gitignore" (

    		echo Creating .gitignore...

    		copy "!ROOT!\github_utilities\gitignore_template.txt" ".gitignore" >nul
	    )

	    echo Initialising git repository...
	    echo.
            git init

            git add .
            git commit -m "Initial commit"

            echo Creating GitHub repo...
	    echo.
            gh repo create !NAME! --private --source=. --remote=origin --push

        ) else (

            echo Skipping !NAME!
            echo.
        )

    ) else (

        echo Syncing existing repository...
	echo.
        git add .
        git pull --rebase
        git status -s
        git diff --cached --quiet
        if errorlevel 1 (
            git commit -m "Auto-sync %COMPUTERNAME% %date% %t%"
        )
        git remote -v >nul 2>&1
        if errorlevel 1 (
            echo No remote configured, skipping push.
	    echo.
        ) else (
            git push
        )
    )

    echo. This is a test.

)

echo =============
echo Sync Complete
echo =============
echo.
pause