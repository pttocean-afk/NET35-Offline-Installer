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
