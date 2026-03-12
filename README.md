This repo requires github.CLI to run (shown for WINDOWS):
- winget install Git.Git
- gh auth login
- git config --global user.email "your@email.com"
- git config --global user.name "Your Name"

Fetch the repo:
- cd "C:\Users\%USERNAME%\Documents" (change as appropriate)
- mkdir tracked_repos
- cd tracked_repos
- gh repo clone LoweAlexander/repos_tracker

Setup:
- Create new gist for storing names of tracked repos
- Add LoweAlexander/repos_tracker to the gist to track this repo
- Clone this repo into a new directory tracked_repos
- In SYNC_REPOS.bat, set path to directory of repos: tracked_repos
- Create repos_gist_location.txt
- In repos_gist_location.txt, set https address for the gist
