@echo off
setlocal EnableExtensions DisableDelayedExpansion
title Mysthic Aura - Windows 11
color 0B
chcp 65001 >nul
mode con: cols=90 lines=38
cd /d "%~dp0"
set "LOG=%~dp0Mysthic_Cleanup.log"
set "FAIL=0"
set "WAS_WUA=0"
set "WAS_BITS=0"
fltmc >nul 2>&1
if errorlevel 1 (
    echo Solicitando permissao de administrador...
    powershell -NoProfile -Command "try { Start-Process -FilePath $env:ComSpec -ArgumentList @('/k',('""{0}""' -f '%~f0')) -Verb RunAs; exit 0 } catch { exit 1 }"
    if errorlevel 1 (
        echo.
        echo Nao foi possivel abrir como administrador.
        pause
        exit /b 1
    )
    exit /b 0
)
> "%LOG%" echo Mysthic Cleanup - Inicio: %date% %time%
cls
echo.
echo ==========================================================
echo              WINDOWS 11 - MYSTHIC CLEANUP
echo ==========================================================
echo.
echo Log: "%LOG%"
echo.
echo A rotina limpa caches e arquivos temporarios.
echo Feche os navegadores e os programas abertos.
echo.
choice /c SN /n /m "Deseja iniciar? [S/N]: "
if errorlevel 2 goto :CANCEL
echo.
echo [1/10] Temporarios do usuario...
call :CLEAN "%TEMP%"
echo [2/10] Temporarios do Windows...
call :CLEAN "%SystemRoot%\Temp"
echo [3/10] Cache de miniaturas...
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >>"%LOG%" 2>&1
echo [4/10] Cache de shaders...
call :CLEAN "%LocalAppData%\D3DSCache"
echo [5/10] Relatorios de erros...
call :CLEAN "%ProgramData%\Microsoft\Windows\WER\ReportArchive"
call :CLEAN "%ProgramData%\Microsoft\Windows\WER\ReportQueue"
call :CLEAN "%LocalAppData%\Microsoft\Windows\WER\ReportArchive"
call :CLEAN "%LocalAppData%\Microsoft\Windows\WER\ReportQueue"
echo [6/10] Caches de navegadores...
call :CLEAN "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
call :CLEAN "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache"
call :CLEAN "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
call :CLEAN "%LocalAppData%\Microsoft\Edge\User Data\Default\Code Cache"
call :CLEAN "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache"
call :CLEAN "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Code Cache"
echo [7/10] Cache do Windows Update...
sc query wuauserv | findstr /i "RUNNING" >nul && set "WAS_WUA=1"
sc query bits | findstr /i "RUNNING" >nul && set "WAS_BITS=1"
net stop bits >>"%LOG%" 2>&1
net stop wuauserv >>"%LOG%" 2>&1
call :CLEAN "%SystemRoot%\SoftwareDistribution\Download"
if "%WAS_WUA%"=="1" net start wuauserv >>"%LOG%" 2>&1
if "%WAS_BITS%"=="1" net start bits >>"%LOG%" 2>&1
echo [8/10] Cache de entrega...
call :CLEAN "%SystemRoot%\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache"
echo [9/10] Despejos de falhas...
if exist "%LocalAppData%\CrashDumps\" (
    del /f /q "%LocalAppData%\CrashDumps\*.dmp" >>"%LOG%" 2>&1
)
echo [10/10] DNS e componentes do Windows...
ipconfig /flushdns >>"%LOG%" 2>&1
if errorlevel 1 set "FAIL=1"
DISM /Online /Cleanup-Image /StartComponentCleanup
if errorlevel 1 (
    set "FAIL=1"
    echo DISM retornou um erro.>>"%LOG%"
)
echo.
echo Esvaziando a Lixeira...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >>"%LOG%" 2>&1
goto :FINISH
:CLEAN
if not exist "%~1\" exit /b 0
del /f /s /q "%~1\*" >>"%LOG%" 2>&1
for /d %%D in ("%~1\*") do (
    if exist "%%~fD\" rd /s /q "%%~fD" >>"%LOG%" 2>&1
)
exit /b 0
:CANCEL
echo.
echo Operacao cancelada.
goto :END
:FINISH
echo.>>"%LOG%"
echo Finalizado: %date% %time%>>"%LOG%"
echo.
echo ==========================================================
if "%FAIL%"=="0" (
    echo                    ROTINA FINALIZADA
) else (
    echo               ROTINA FINALIZADA COM AVISOS
)
echo ==========================================================
echo.
echo Log salvo em:
echo "%LOG%"
echo.
echo Reinicie o Windows se necessario.
echo.
echo              ___
echo             /\__\
echo            /::|  |
echo           /:|:|  |
echo          /:/|:|__|__
echo         /:/ |::::\__\
echo         \/__/~~/:/  /
echo               /:/  /
echo              /:/  /
echo             /:/  /
echo             \/__/
echo.
echo          By Mysthic_FøxX
echo.
echo ==========================================================
echo.
goto :END
:END
echo Pressione qualquer tecla para fechar...
pause >nul
endlocal
exit /b