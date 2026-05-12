@echo off
echo ======================================================
echo   SORAI FEST - SQA AUTOMATION SUITE (LOCAL)
echo ======================================================
echo.
echo [1/4] Cleaning Project...
call flutter clean
echo.
echo [2/4] Fetching Dependencies...
call flutter pub get
echo.
echo [3/4] Running Static Analysis (Code Quality)...
call flutter analyze
echo.
echo [4/4] Running Widget & Logic Tests...
call flutter test
echo.
echo ======================================================
echo   AUTOMATION COMPLETED
echo ======================================================
pause
