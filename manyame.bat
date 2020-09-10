setlocal EnableExtensions
:uniqLoop
set "uniqueFileName=%tmp%\rand%RANDOM%.tmp"
if exist "%uniqueFileName%" goto :uniqLoop
:uniqBat
set "uniqueBatName=%tmp%\bat%RANDOM%.bat"
if exist "%uniqueBatName%" goto :uniqBat
echo cd /d %cd% > %uniqueBatName%
bash manyame.sh "%uniqueFileName%" "%uniqueBatName%" %*
call %uniqueBatName%
echo Success! Press enter to exit...
pause >nul
