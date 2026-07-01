# GitHub Release Checklist

## Repository Setup

1. Install or activate Xcode command line tools.
2. Initialize Git in this folder.
3. Create a GitHub repository named `singbridge` or another chosen product name.
4. Add the GitHub repository as `origin`.
5. Commit the v0.1 scaffold.
6. Push the main branch.
7. Create a `v0.1.0` tag after the package builds locally.

## Commands

```sh
git init
git add .
git commit -m "Create SingBridge karaoke MVP scaffold"
git branch -M main
git remote add origin git@github.com:<your-user>/singbridge.git
git push -u origin main
git tag v0.1.0
git push origin v0.1.0
```

## Current Blocker

This machine currently reports that command line developer tools are missing when `git` or `swift` is invoked. Until Xcode command line tools are installed or selected, terminal-based build, test, commit, and push commands cannot run.
