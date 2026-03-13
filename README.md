Updating repos_tracker
----------------------
To avoid security issues, repos_tracker will not automatically sync. Please update manually when needed.
To update via Git CLI, navigate to your repos_tracker folder and run:
```
git pull
```

Automatic Installation (Windows)
--------------------------------
Please download and run the installer found at:

https://raw.githubusercontent.com/LoweAlexander/repos_tracker/master/installer.bat

Manual Installation (Windows)
-----------------------------
Prerequisits:
- winget install Git.Git
- winget install GitHub.cli
- gh auth login
- git config --global user.email "your@email.com"
- git config --global user.name "Your Name"

Setup:
- cd "C:\Users\%USERNAME%\Documents" (change as appropriate)
- mkdir tracked_repos
- cd tracked_repos
- gh repo clone LoweAlexander/repos_tracker

Gist Setup:
- Create new gist for storing names of tracked repos
- Add LoweAlexander/repos_tracker to the gist to track this repo
- Create repos_gist_location.txt
- In repos_gist_location.txt, write the 32 character identifier for the gist (e.g. can be found in the URL) to the first line
