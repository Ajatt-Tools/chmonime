@echo off
setlocal EnableExtensions
mode con: cols=100 lines=30
if exist "chmonime.sh" goto :check
Executables\busybox wget -q https://raw.githubusercontent.com/asakura42/chmonime/master/chmonime.sh -O chmonime.sh
:check
for /f "tokens=* USEBACKQ" %%a in (
`for %%I in ^(chmonime.sh^) do @echo %%~zI`
) do (
set local=%%a
)
FOR /F "tokens=* USEBACKQ" %%F IN (
`Executables\busybox wget -q --spider --server-response https://raw.githubusercontent.com/asakura42/chmonime/master/chmonime.sh -O - 2^>^&1 ^| Executables\busybox sed -ne "/Content-Length/{s/.*: //;p}"`) DO (
SET remote=%%F
)
IF %remote% EQU %local% (GOTO uniqLoop) ELSE (GOTO dl)
:dl
Executables\busybox wget -q https://raw.githubusercontent.com/asakura42/chmonime/master/chmonime.sh -O chmonime.sh
GOTO uniqLoop
:uniqLoop
set "uniqueFileName=%tmp%\rand%RANDOM%.tmp"
if exist "%uniqueFileName%" goto :uniqLoop
:uniqBat
set "uniqueBatName=%tmp%\bat%RANDOM%.bat"
if exist "%uniqueBatName%" goto :uniqBat
echo cd /d %cd%\Executables > %uniqueBatName%
Executables\busybox bash chmonime.sh "%uniqueFileName%" "%uniqueBatName%" %*
call %uniqueBatName%
echo Success! Press enter to exit...
pause >nul

