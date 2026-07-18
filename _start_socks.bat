@echo off
title UrProxy
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
echo   STEP 1: Searching releases for matching asset
echo ============================================================
for /f "usebackq tokens=1,2 delims=|" %%A in (`powershell -NoProfile -Command ^
  "$repo='urnetwork/build';" ^
  "$prefix='urnetwork-proxy-socks-';" ^
  "$url=$null;$name=$null;" ^
  "for($page=1;$page-le 10;$page++){" ^
  "  $rels=Invoke-RestMethod ('https://api.github.com/repos/{0}/releases?page={1}&per_page=10' -f $repo,$page);" ^
  "  if($rels.Length -eq 0){break};" ^
  "  foreach($r in $rels){" ^
  "    $a=$r.assets | Where-Object { $_.name -like ($prefix+'*') } | Select-Object -First 1;" ^
  "    if($a){$url=$a.browser_download_url;$name=$a.name;break}" ^
  "  };" ^
  "  if($url){break}" ^
  "};" ^
  "if($url){Write-Output ($url+'|'+$name)}else{Write-Output '||'}"`) do (
    set "URL=%%A"
    set "FILENAME=%%B"
)

if not defined URL (
  echo ERROR: No urnetwork-proxy-socks-*.tar.gz asset found.
  exit /b 1
)

echo Latest asset filename: %FILENAME%

echo ============================================================
echo   STEP 2: Downloading release version
echo ============================================================
set "MAX_RETRIES=3"
set "RETRY_COUNT=0"

:download_retry
set /a RETRY_COUNT+=1
if exist "cached\%FILENAME%" (
    echo File already cached: cached\%FILENAME%
    echo Skipping download...
) else (
    echo Downloading new release asset... (Attempt %RETRY_COUNT%/%MAX_RETRIES%)
    curl -L -k -A "Mozilla/5.0" -o "cached\%FILENAME%" "%URL%"
    if errorlevel 1 (
        if %RETRY_COUNT% LSS %MAX_RETRIES% (
            echo Download failed. Retrying in 5 seconds...
            timeout 5 >nul
            goto download_retry
        )
        echo ERROR: Download failed after %MAX_RETRIES% attempts.
        exit /b 1
    )
)

if not exist "cached\%FILENAME%" (
    echo ERROR: Downloaded file not found.
    exit /b 1
)

for %%A in ("cached\%FILENAME%") do if %%~zA==0 (
    echo ERROR: Downloaded file is empty.
    del /f /q "cached\%FILENAME%"
    exit /b 1
)

echo Download verified successfully.

echo ============================================================
echo   STEP 3: Extracting socks (%ARCH%)
echo ============================================================
timeout 3 >nul
powershell -NoProfile -Command ^
  "$tgz = 'cached\%FILENAME%';" ^
  "$tmp = 'cached\extracted_socks';" ^
  "$src = Join-Path $tmp ('windows\' + '%ARCH%');" ^
  "if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force };" ^
  "mkdir $tmp | Out-Null;" ^
  "tar -xzf $tgz -C $tmp;" ^
  "if (-not (Test-Path (Join-Path $src 'socks.exe'))) { Write-Error 'socks.exe not found after extraction'; exit 1 };" ^
  "Get-ChildItem -Path $src -File | Where-Object { $_.Name -ne 'socks.exe' } | Move-Item -Destination '.' -Force;" ^
  "Move-Item -Path (Join-Path $src 'socks.exe') -Destination 'ur_socks.exe' -Force"
if errorlevel 1 (
    if exist cached\extracted_socks rd /s /q cached\extracted_socks
    echo ERROR: Extraction failed or socks.exe not found.
    exit /b 1
)
if not exist "ur_socks.exe" (
    if exist cached\extracted_socks rd /s /q cached\extracted_socks
    echo ERROR: ur_socks.exe was not created after extraction.
    exit /b 1
)
echo Extraction verified successfully.

echo ============================================================
echo   STEP 4: Cleaning up temporary files
echo ============================================================
timeout 3 >nul
if exist cached\extracted_socks rd /s /q cached\extracted_socks

echo ============================================================
echo   STEP 5: Reading ENV.ini credentials
echo ============================================================
if not exist "ENV.ini" (
    echo ============================================================
    echo   ERROR: ENV.ini not found in current directory
    echo ============================================================
    exit /b 1
)

for /f "tokens=1,2 delims==" %%A in ('powershell -NoProfile -Command ^
  "$section = '';" ^
  "Get-Content 'ENV.ini' | ForEach-Object {" ^
  "  if ($_ -match '^\[(.+)\]$') { $section = $Matches[1] }" ^
  "  if ($section -eq 'PROXY' -and $_ -match '=') { $_ }" ^
  "}"') do (
    if /i "%%A"=="USER" set "USER=%%B"
    if /i "%%A"=="PASS" set "PASS=%%B"
    if /i "%%A"=="COUNTRY" set "COUNTRY=%%B"
    if /i "%%A"=="LISTEN_ADDR" set "LISTEN_ADDR=%%B"
)

if not defined LISTEN_ADDR set "LISTEN_ADDR=127.0.0.1:9999"
if not defined COUNTRY set "COUNTRY=United States"

if not defined USER (
    echo ============================================================
    echo   ERROR: USER not set in ENV.ini [PROXY] section
    echo ============================================================
    exit /b 1
)

if not defined PASS (
    echo ============================================================
    echo   ERROR: PASS not set in ENV.ini [PROXY] section
    echo ============================================================
    exit /b 1
)

echo ============================================================
echo   STEP 6: Running Binary
echo ============================================================
ur_socks --addr "%LISTEN_ADDR%" --user-auth="%USER%" --password="%PASS%" --country="%COUNTRY%"
set "EXITCODE=%errorlevel%"

echo ============================================================
echo   DONE: Provider authentication attempted
echo ============================================================

endlocal
if %EXITCODE% neq 0 pause
exit /b %EXITCODE%
