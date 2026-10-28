@echo off
setlocal EnableExtensions
title Windows 11 - Advanced Cleanup
color 0B
chcp 65001 >nul
mode con: cols=90 lines=35
fltmc >nul 2>&1
if errorlevel 1 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
echo.
echo ==========================================================
echo              WINDOWS 11 - ADVANCED CLEANUP
echo ==========================================================
echo.
echo Esta rotina limpa arquivos temporarios e caches.
echo Feche os navegadores e os programas abertos.
echo.
choice /c SN /n /m "Iniciar a limpeza? [S/N]: "
if errorlevel 2 exit /b 0
echo.
echo [1/12] Limpando temporarios do usuario...
if defined TEMP if exist "%TEMP%\" (
    del /f /s /q "%TEMP%\*" >nul 2>&1
    for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >nul 2>&1
)
echo [2/12] Limpando temporarios do Windows...
if exist "%SystemRoot%\Temp\" (
    del /f /s /q "%SystemRoot%\Temp\*" >nul 2>&1
    for /d %%D in ("%SystemRoot%\Temp\*") do rd /s /q "%%D" >nul 2>&1
)
echo [3/12] Limpando caches de miniaturas...
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo [4/12] Limpando caches graficos...
if exist "%LocalAppData%\D3DSCache\" (
    del /f /s /q "%LocalAppData%\D3DSCache\*" >nul 2>&1
    for /d %%D in ("%LocalAppData%\D3DSCache\*") do rd /s /q "%%D" >nul 2>&1
)
echo [5/12] Limpando relatorios de erros...
for %%P in (
    "%ProgramData%\Microsoft\Windows\WER\ReportArchive"
    "%ProgramData%\Microsoft\Windows\WER\ReportQueue"
    "%LocalAppData%\Microsoft\Windows\WER\ReportArchive"
    "%LocalAppData%\Microsoft\Windows\WER\ReportQueue"
) do (
    if exist "%%~P\" (
        del /f /s /q "%%~P\*" >nul 2>&1
        for /d %%D in ("%%~P\*") do rd /s /q "%%D" >nul 2>&1
    )
)
echo [6/12] Limpando caches de navegadores...
for %%P in (
    "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
    "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache"
    "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
    "%LocalAppData%\Microsoft\Edge\User Data\Default\Code Cache"
    "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache"
    "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Code Cache"
) do (
    if exist "%%~P\" (
        del /f /s /q "%%~P\*" >nul 2>&1
        for /d %%D in ("%%~P\*") do rd /s /q "%%D" >nul 2>&1
    )
)
echo [7/12] Limpando cache de downloads do Windows Update...
set "WAS_WUA=0"
set "WAS_BITS=0"
sc query wuauserv | findstr /i "RUNNING" >nul && set "WAS_WUA=1"
sc query bits | findstr /i "RUNNING" >nul && set "WAS_BITS=1"
if exist "%SystemRoot%\SoftwareDistribution\Download\" (
    net stop bits >nul 2>&1
    net stop wuauserv >nul 2>&1
    del /f /s /q "%SystemRoot%\SoftwareDistribution\Download\*" >nul 2>&1
    for /d %%D in ("%SystemRoot%\SoftwareDistribution\Download\*") do rd /s /q "%%D" >nul 2>&1
    if "%WAS_WUA%"=="1" net start wuauserv >nul 2>&1
    if "%WAS_BITS%"=="1" net start bits >nul 2>&1
)
echo [8/12] Limpando cache de otimizacao de entrega...
set "DOCACHE=%SystemRoot%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache"
if exist "%DOCACHE%\" (
    del /f /s /q "%DOCACHE%\*" >nul 2>&1
    for /d %%D in ("%DOCACHE%\*") do rd /s /q "%%D" >nul 2>&1
)
echo [9/12] Limpando despejos de falhas...
if exist "%LocalAppData%\CrashDumps\" del /f /q "%LocalAppData%\CrashDumps\*.dmp" >nul 2>&1
echo [10/12] Esvaziando a Lixeira...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo [11/12] Atualizando o cache DNS...
ipconfig /flushdns >nul 2>&1
echo [12/12] Executando limpeza de componentes...
DISM /Online /Cleanup-Image /StartComponentCleanup
echo.
echo ==========================================================
echo                  LIMPEZA CONCLUIDA
echo ==========================================================
echo.
echo                 ___
echo                /\__\
echo               /::|  |
echo              /:|:|  |
echo             /:/|:|__|__
echo            /:/ |::::\__\
echo            \/__/~~/:/  /
echo                  /:/  /
echo                 /:/  /
echo                /:/  /
echo                \/__/
echo.
echo              By Mysthic_FøxX
echo.
echo ==========================================================
echo.
pause
endlocal