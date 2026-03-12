This repo requires github.CLI to run (shown for WINDOWS):
- winget install Git.Git
- gh auth login
- git config --global user.email "your@email.com"
- git config --global user.name "Your Name"

Fetch the repo:
- cd "C:\Users\%USERNAME%\Documents" (change as appropriate)
- mkdir phd_code_repos
- cd phd_code_repos
- gh repo clone LoweAlexander/github_utilities

Setup:
- Create new gist for storing names of tracked repos
- Add LoweAlexander/github_utilities to the gist to track this repo
- Clone this repo into a new directory phd_code_repos
- In SYNC_RESEARCH.bat, set path to directory of repos: phd_code_repos
- Create repos_gist_location.txt
- In repos_gist_location.txt, set https address for the gist
