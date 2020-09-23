@echo off
setlocal EnableExtensions
if exist "manyame.sh" goto :check
busybox wget -q https://raw.githubusercontent.com/asakura42/manyame/nobloat/manyame.sh -O manyame.sh
:check
for /f "tokens=* USEBACKQ" %%a in (
`for %%I in ^(manyame.sh^) do @echo %%~zI`
) do (
set local=%%a
)
FOR /F "tokens=* USEBACKQ" %%F IN (
`busybox wget -q --spider --server-response https://raw.githubusercontent.com/asakura42/manyame/nobloat/manyame.sh -O - 2^>^&1 ^| busybox sed -ne "/Content-Length/{s/.*: //;p}"`) DO (
SET remote=%%F
)
IF %remote% EQU %local% (GOTO uniqLoop) ELSE (GOTO dl)
:dl
busybox wget -q https://raw.githubusercontent.com/asakura42/manyame/nobloat/manyame.sh -O manyame.sh
GOTO uniqLoop
:uniqLoop
set "uniqueFileName=%tmp%\rand%RANDOM%.tmp"
if exist "%uniqueFileName%" goto :uniqLoop
:uniqBat
set "uniqueBatName=%tmp%\bat%RANDOM%.bat"
if exist "%uniqueBatName%" goto :uniqBat
echo cd /d %cd% > %uniqueBatName%
busybox bash manyame.sh "%uniqueFileName%" "%uniqueBatName%" %*
call %uniqueBatName%
echo Success! Press enter to exit...
pause >nul
