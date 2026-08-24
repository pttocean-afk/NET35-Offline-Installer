@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title .NET 3.5 Offline Installer

net session >nul 2>&1
if not "%errorlevel%"=="0" goto NEED_ADMIN

echo ============================================
echo   .NET Framework 3.5 Offline Installer
echo ============================================
echo.

echo Checking .NET 3.5 status...
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" /v Install 2>nul | findstr /C:"0x1" >nul
if "%errorlevel%"=="0" goto ALREADY_INSTALLED

echo Not installed. Proceeding...

for /f "tokens=6 delims=[]. " %%i in ('ver') do set "BUILD=%%i"
echo Build: %BUILD%

REM ===== Windows 11 26H1 (build 28000)+: standalone installer only =====
REM Starting with 26H1, .NET 3.5 is no longer a Windows component (FoD).
REM DISM /Source:sxs and Windows Update both CANNOT install it anymore.
REM Microsoft ships a standalone DotNet35Setup.exe instead; we look for it
REM next to this script (DotNet35Setup.exe) and run it silently.
if %BUILD% GEQ 28000 goto MODERN_INSTALL

set "OSFAMILY=Win10"
if %BUILD% GEQ 22000 set "OSFAMILY=Win11"
echo OS family: %OSFAMILY%

if "%OSFAMILY%"=="Win11" set "SXSPATH=%~dp0Win11_25H2\sxs"
if "%OSFAMILY%"=="Win10" set "SXSPATH=%~dp0Win10_22H2\sxs"

echo Offline source: %SXSPATH%
if not exist "%SXSPATH%\microsoft-windows-netfx3*.cab" goto ONLINE_INSTALL

echo.
echo Installing from offline source...
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /Source:"%SXSPATH%" /LimitAccess
if "%errorlevel%"=="0" goto OFFLINE_OK

echo.
echo Offline install failed. Trying Windows Update...
goto ONLINE_INSTALL

:MODERN_INSTALL
echo.
echo Windows 11 26H1+ detected: .NET 3.5 is no longer a Windows component.
echo DISM/sxs and Windows Update cannot install it on this OS.
set "MODERNSETUP=%~dp0DotNet35Setup.exe"
if not exist "%MODERNSETUP%" goto MODERN_MISSING

echo Running standalone installer (Microsoft KB5087077)...
"%MODERNSETUP%" /passive /norestart
if "%errorlevel%"=="0" goto MODERN_OK
if "%errorlevel%"=="3010" goto MODERN_REBOOT
goto MODERN_FAILED

:MODERN_OK
echo.
echo OK: .NET Framework 3.5 installed successfully. [standalone installer]
goto END

:MODERN_REBOOT
echo.
echo OK: installed. A RESTART IS REQUIRED to finish. [standalone installer]
goto END

:MODERN_MISSING
echo.
echo FAIL: DotNet35Setup.exe was not found next to install.bat.
echo Download it from Microsoft (Windows 11 26H1 standalone installer):
echo   https://go.microsoft.com/fwlink/?LinkID=2337635
echo and place it in this folder, then run install.bat again.
goto MODERN_END

:MODERN_FAILED
echo.
echo FAIL: The standalone installer returned an error.
echo Check the log under %%TEMP%% (Microsoft_.NET_Framework_3.5_*.log).
goto MODERN_END

:MODERN_END
echo.
echo ============================================
pause
exit /b 1

:ONLINE_INSTALL
echo.
echo Using Windows Update. This may take a while...
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
if "%errorlevel%"=="0" goto ONLINE_OK
goto FAILED

:ALREADY_INSTALLED
echo.
echo .NET Framework 3.5 is already enabled. Nothing to do.
goto END

:OFFLINE_OK
echo.
echo OK: .NET Framework 3.5 installed successfully. [offline]
goto END

:ONLINE_OK
echo.
echo OK: .NET Framework 3.5 installed successfully. [online]
goto END

:FAILED
echo.
echo FAIL: Installation failed.
echo Please check Windows Update policy or run this as administrator.
goto END

:NEED_ADMIN
echo ============================================
echo   ADMIN RIGHTS REQUIRED
echo ============================================
echo.
echo Right-click install.bat and choose:
echo Run as administrator
goto END

:END
echo.
echo ============================================
pause
exit /b 0
