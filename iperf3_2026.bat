@echo off
setlocal EnableExtensions
title iperf3 bandwidth test

rem ===== Settings =====
set "STREAMS=5"
set "PORT=5201"
set "IPERF_DIR=%~dp0iperf3"
set "IPERF=%IPERF_DIR%\iperf3.exe"

rem ===== 1. Make sure iperf3 exists (run "iperf3_test.bat update" to force the newest version) =====
if /i "%~1"=="update" goto download
if exist "%IPERF%" goto have_iperf

:download
echo Downloading the latest iperf3 for Windows, please wait...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $ProgressPreference='SilentlyContinue'; $r=Invoke-WebRequest 'https://github.com/ar51an/iperf3-win-builds/releases/latest' -Method Head -UseBasicParsing; $tag=Split-Path $r.BaseResponse.ResponseUri.AbsolutePath -Leaf; if ($tag -notmatch '^\d+(\.\d+)+$') { throw 'Could not detect the latest version' }; $zip=Join-Path $env:TEMP ('iperf-'+$tag+'-win64.zip'); Invoke-WebRequest ('https://github.com/ar51an/iperf3-win-builds/releases/download/'+$tag+'/iperf-'+$tag+'-win64.zip') -OutFile $zip -UseBasicParsing; New-Item -ItemType Directory -Force '%IPERF_DIR%' | Out-Null; Expand-Archive -LiteralPath $zip -DestinationPath '%IPERF_DIR%' -Force; Remove-Item $zip; exit 0 } catch { Write-Host ('Download failed: ' + $_.Exception.Message); exit 1 }"
if errorlevel 1 goto dl_failed
if not exist "%IPERF%" goto dl_failed

:have_iperf
set "iperf_ver="
for /f "tokens=1,2" %%a in ('"%IPERF%" --version 2^>nul') do (set "iperf_ver=%%a %%b" & goto ver_done)
:ver_done
if not defined iperf_ver goto iperf_broken
echo Using %iperf_ver%

rem ===== 2. Customer public IP =====
set "public_ip=unknown"
for /f "delims=" %%a in ('powershell -NoProfile -Command "(Resolve-DnsName myip.opendns.com -Server resolver1.opendns.com -Type A -DnsOnly -ErrorAction SilentlyContinue).IPAddress"') do set "public_ip=%%a"

rem ===== 3. Select server + fast reachability check =====
:select_server
echo.
echo   1. Stockholm STB 100G
echo   2. GBG-BCK 10G
echo   3. HGD 10G
choice /c 123 /n /m "Select the iperf3 server [1-3]: "
if errorlevel 3 (set "server=90.130.70.73") else if errorlevel 2 (set "server=bck-speedtest-1.tele2.net") else (set "server=stb-speedtest-1.tele2.net")

echo Checking %server%:%PORT% ...
powershell -NoProfile -Command "try { $ip=[Net.Dns]::GetHostAddresses('%server%') | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1; $c=New-Object Net.Sockets.TcpClient([Net.Sockets.AddressFamily]::InterNetwork); $a=$c.BeginConnect($ip,%PORT%,$null,$null); if ($a.AsyncWaitHandle.WaitOne(3000,$false) -and $c.Connected) { exit 0 } } catch { }; exit 1"
if errorlevel 1 (
  echo.
  echo IP not reachable: %server% port %PORT%
  echo The server may be down, or port %PORT% is blocked by a firewall.
  goto select_server
)

rem ===== 4. Duration =====
:select_duration
set "duration="
set /p "duration=Test duration in seconds (10-60, Enter = 10): "
if not defined duration set "duration=10"
for /f "delims=0123456789" %%x in ("%duration%") do goto bad_duration
if %duration% lss 10 goto bad_duration
if %duration% gtr 60 goto bad_duration
goto duration_ok
:bad_duration
echo Invalid choice, please try again.
goto select_duration
:duration_ok

rem ===== 5. Direction =====
choice /c 12 /n /m "1 = Download, 2 = Upload: "
if errorlevel 2 (set "dir_name=upload" & set "dir_params=") else (set "dir_name=download" & set "dir_params=-R")

rem ===== 6. Result file =====
for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "stamp=%%t"
set "outfile=%~dp0iperf3_result_%dir_name%_%duration%s_%stamp%.txt"
(
  echo iperf3 test %date% %time%
  echo Customer public IP: %public_ip%
  echo Server: %server%  Direction: %dir_name%  Duration: %duration%s  Streams: %STREAMS%
  echo Client: %iperf_ver%
  echo.
) > "%outfile%"

rem ===== 7. Run (retries if a public server is busy) =====
set "tries=0"
:run
set /a tries+=1
echo Running %dir_name% test for %duration%s with %STREAMS% streams, please wait...
"%IPERF%" -4 -c %server% -p %PORT% -P %STREAMS% -O 3 --connect-timeout 3000 %dir_params% -t %duration% >> "%outfile%" 2>&1
if errorlevel 1 if %tries% lss 3 (
  echo Test failed, retrying in 5 seconds...
  timeout /t 5 /nobreak >nul
  goto run
)
if errorlevel 1 goto test_failed

rem ===== 8. Show result =====
set "result=n/a"
for /f "tokens=6,7" %%a in ('findstr /c:"[SUM]" "%outfile%" ^| findstr /c:"receiver"') do set "result=%%a %%b"
echo.
echo Result (%dir_name% from %server%): %result%
echo Saved to: %outfile%
echo.
pause
exit /b 0

:test_failed
echo.
echo The test failed after %tries% attempts. Details are in:
echo %outfile%
pause
exit /b 1

:dl_failed
echo.
echo Could not download iperf3. Check your internet connection, or download it manually from
echo https://github.com/ar51an/iperf3-win-builds/releases/latest
echo and put iperf3.exe and cygwin1.dll in: %IPERF_DIR%
pause
exit /b 1

:iperf_broken
echo.
echo iperf3.exe did not start. Run "%~nx0 update" to reinstall it
echo (antivirus software sometimes removes cygwin1.dll).
pause
exit /b 1
