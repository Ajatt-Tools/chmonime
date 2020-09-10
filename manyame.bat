@echo off
setlocal EnableExtensions

rem get unique file name 
:uniqLoop
set "uniqueFileName=%tmp%\bat~%RANDOM%.tmp"
if exist "%uniqueFileName%" goto :uniqLoop
bash manyame.sh "%uniqueFileName%" %*
echo Success! Press enter to exit...
pause >nul