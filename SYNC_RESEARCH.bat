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

echo time = %t%

for /d %%G in ("%ROOT%\*") do (

    echo Location: %%G
    set "NAME=%%~nxG"
    echo Name only: !NAME!
    
    echo.

    cd /d "%%G"

    echo -------------------------
    echo Checking !NAME!
    echo -------------------------

    if not exist ".git" (

        echo No git repository detected.

        echo Create GitHub repo for !NAME!?
	set /p answer=y/n:

        if /i "!answer!"=="y" (

            if not exist ".gitignore" (

    		echo Creating scientific .gitignore...

    		copy "!ROOT!\github_utilities\gitignore_template.txt" ".gitignore" >nul
	    )

	    echo Initialising git repository...
            git init

            git add .
            git commit -m "Initial commit"

            echo Creating GitHub repo...
            gh repo create !NAME! --private --source=. --remote=origin --push

        ) else (

            echo Skipping !NAME!
        )

    ) else (

        echo Syncing existing repository...

        git pull --rebase

        git add .

	git status -s

        git diff --cached --quiet
	if errorlevel 1 git commit -m "Auto-sync %COMPUTERNAME% %date% %t%"

        git push

    )

    echo.

)

echo =============
echo Sync Complete
echo =============
pause