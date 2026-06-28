@echo off
cd /d "C:\dart\git_project\barbershop_app\barbershop_app"
echo Staging all files...
git add -A
echo.
echo Committing...
git commit -m "feat: initial setup with base structure and splash screen"
echo.
echo Pushing to GitHub...
git push -u origin main
echo.
echo Done!
pause
