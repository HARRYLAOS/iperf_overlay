@ECHO OFF
REM BFCPEOPTIONSTART
REM Advanced BAT to EXE Converter www.BatToExeConverter.com
REM BFCPEEXE=C:\Users\HARRY\Desktop\Harrys_IPERF_Tester.exe
REM BFCPEICON=
REM BFCPEICONINDEX=-1
REM BFCPEEMBEDDISPLAY=0
REM BFCPEEMBEDDELETE=1
REM BFCPEADMINEXE=0
REM BFCPEINVISEXE=0
REM BFCPEVERINCLUDE=1
REM BFCPEVERVERSION=1.0.0.0
REM BFCPEVERPRODUCT=Bandwidth Test
REM BFCPEVERDESC=Bandwidth Tester based on Iperf3
REM BFCPEVERCOMPANY=Charilaos Christopoulos
REM BFCPEVERCOPYRIGHT=2023
REM BFCPEWINDOWCENTER=1
REM BFCPEDISABLEQE=0
REM BFCPEWINDOWHEIGHT=25
REM BFCPEWINDOWWIDTH=80
REM BFCPEWTITLE=Harrys Iperf Tester
REM BFCPEOPTIONEND
@echo off
rem Get the public IP of the customer
for /f "tokens=2" %%a in ('nslookup myip.opendns.com resolver1.opendns.com^| findstr "Address"') do (
  set public_ip=%%a
)
:select_server
set /p server="Select the iperf3 server you want to test towards: 1. Stockholm Region STB 100G 2. GBG GIMP 10G 3. 84grams via Telia Carrier. Type the number and press Enter: "

if %server% == 1 (
  set iperf3_server=90.130.74.149
) else if %server% == 2 (
  set iperf3_server=90.130.74.151
) else if %server% == 3 (
  set iperf3_server=31.12.81.44
)
if not defined iperf3_server (
  echo Invalid choice, please try again.
  goto select_server
)
:select_duration
set /p duration="Enter the duration of the test in seconds (10sec up to 60sec): "

if not %duration% geq 10 if %duration% leq 60 (
  echo Invalid choice, please try again.
  goto select_duration
)
:select_direction
set /p direction="Do you want to test the download speed or upload speed? 1. Download. 2. Upload. Enter your choice: "

if %direction% == 1 set iperf3_params=-R
if %direction% == 2 set iperf3_params= 
if not defined iperf3_params (
  echo Invalid choice, please try again.
  goto select_direction
)

rem Store the result of the iperf3 test in a text file
echo Customer public IP: %public_ip% > iperf3_result_%duration%.txt
C:\iperf-3.1.3-win64\iperf3.exe -c %iperf3_server% -P 5 %iperf3_params% -t %duration% >> iperf3_result_%duration%.txt

rem Display the result of the bandwidth test
for /f "tokens=6,7" %%a in ('findstr "Bytes  Bits/sec" iperf3_result_%duration%.txt') do (
  set result=%%a %%b
)

msg * "Harry says that the result of the bandwidth test is: %result% .         Iperf3 test completed and results saved to iperf3_result%duration%.txt"
