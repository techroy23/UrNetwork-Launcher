@echo off
setlocal enabledelayedexpansion
cls

:: ============================================================
:: Art
:: ============================================================

echo.
echo  .d8b.  d8b   db .d888b. db   dD d888888b d8b   db
echo d8' `8b 888o  88 VP  `8D 88 ,8P'   `88'   888o  88
echo 88ooo88 88V8o 88    odD' 88,8P      88    88V8o 88
echo 88~~~88 88 V8o88  .88'   88`8b      88    88 V8o88
echo 88   88 88  V888 j88.    88 `88.   .88.   88  V888
echo YP   YP VP   V8P 888888D YP   YD Y888888P VP   V8P
echo.

:: ============================================================
:: Detect system architecture
:: ============================================================

set "ARCH="

if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "ARCH=amd64"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"
if /i "%PROCESSOR_ARCHITECTURE%"=="x86" (
    if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" set "ARCH=amd64"
    if /i "%PROCESSOR_ARCHITEW6432%"=="ARM64" set "ARCH=arm64"
)

if not defined ARCH (
    echo ============================================================
    echo   ERROR: Unknown architecture detected
    echo ============================================================
    exit /b 1
)

:: Repo details
set "REPO=urnetwork/build"
set "API=https://api.github.com/repos/%REPO%/releases/latest"

:: Ensure cached folder exists
if not exist "cached" mkdir "cached"

echo ============================================================
echo   STEP 1: Checking latest release info
echo ============================================================
for /f "usebackq tokens=1,2 delims=|" %%A in (`powershell -NoProfile -Command ^
  "$r = Invoke-RestMethod '%API%';" ^
  "$a = $r.assets | Where-Object { $_.name -match '\.tar\.gz$' } | Select-Object -First 1;" ^
  "if ($null -eq $a) { Write-Output '||'; } else { Write-Output ($a.browser_download_url + '|' + $a.name) }"`) do (
    set "URL=%%A"
    set "FILENAME=%%B"
)

if not defined URL (
  echo ERROR: No .tar.gz asset found.
  exit /b 1
)

echo Latest asset filename: %FILENAME%

echo ============================================================
echo   STEP 2: Downloading release version
echo ============================================================
if exist "cached\%FILENAME%" (
    echo File already cached: cached\%FILENAME%
    echo Skipping download...
) else (
    echo Downloading new release asset...
    curl -L -H "User-Agent: curl" -o "cached\%FILENAME%" "%URL%"
    if errorlevel 1 (
      echo ERROR: Download failed.
      exit /b 1
    )
)

echo ============================================================
echo   STEP 3: Extracting provider (%ARCH%)
echo ============================================================
powershell -NoProfile -Command ^
  "$tgz = 'cached\%FILENAME%';" ^
  "$tmp = 'cached\extracted';" ^
  "if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force };" ^
  "mkdir $tmp | Out-Null;" ^
  "tar -xzf $tgz -C $tmp;" ^
  "Copy-Item -Path (Join-Path $tmp ('windows\' + '%ARCH%' + '\*')) -Destination '.' -Recurse -Force"

echo ============================================================
echo   STEP 4: Cleaning up temporary files
echo ============================================================
if exist latest.json del /f /q latest.json
if exist cached\extracted rd /s /q cached\extracted

echo ============================================================
echo   STEP 5: Reading ENV.ini credentials
echo ============================================================
:: Use PowerShell to safely parse ENV.ini
for /f "tokens=1,2 delims==" %%A in ('powershell -NoProfile -Command ^
  "$envFile = Get-Content 'ENV.ini';" ^
  "foreach ($line in $envFile) { if ($line -match '=') { $line } }"') do (
    if /i "%%A"=="USER" set "USER=%%B"
    if /i "%%A"=="PASS" set "PASS=%%B"
)

echo ============================================================
echo   STEP 6: Running provider authentication
echo ============================================================
provider auth-provide --user_auth="%USER%" --password="%PASS%" -f

echo ============================================================
echo   DONE: Provider authentication attempted
echo ============================================================

endlocal
pause
