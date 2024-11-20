::├  EXNCODE  ┤  Not beautiful, but extremely fast.

::Default
@echo off & setlocal enabledelayedexpansion & chcp 65001 >nul & set _ver=v1.0.0&mode con: cols=50 lines=15

::Colors/Visual
set rst=[m&set be1=[m[48;2;000;030;054m[38;2;049;168;255m& set be2=[m[38;2;049;168;255m& set gn1=[92m& set gn2=[102m[30m
set "bsm=echo %be1%       %rst%"
set "bbg=echo %be1%                                                  %rst%"
set "gsm=echo %gn2%       %rst%"

::Title
title EXN PHOTOFiT %_ver% - Photoshop Tools
echo %be1%  EXN PHOTOFiT - Photoshop Tools %_ver% %rst%&echo:

::Elevation
net session >nul 2>&1 || (echo You need administrator priviledges to run this program.&echo Trying to elevate... & chcp 437 >nul & powershell -command "Start-Process -Verb RunAs -FilePath '%0' -ArgumentList 'am_admin'" & chcp 65001 >nul & exit /b)

::Verify Requeriments
del /f /s /q "%temp%\exnps.txt" >nul 2>&1
dir /b "%ProgramFiles%\Adobe\*Photoshop*" > %temp%\exnps.txt
set "ps_cmd=type %temp%\exnps.txt ^| find"
set "er_2=call :er & echo You are using an very old version of Photoshop.&echo:&echo Press any key to exit. & pause >nul & exit"

::One version?
for /f %%G in ('type %temp%\exnps.txt ^| find /c /i "Photoshop"') do (if %%G GTR 1 call :er & echo There are multiple versions of Photoshop&echo installed on the system.&echo:&echo Press any key to exit. & pause >nul & exit)

::CS?
findstr /i "CS" %temp%\exnps.txt >nul 2>&1
if %errorlevel%==0 %er_2%

::CC?
findstr /i "CC" %temp%\exnps.txt >nul 2>&1
if %errorlevel%==0 %er_2%

::PS Version
for /f "tokens=3" %%g in ('%ps_cmd%str /r "[0-9]"') do (set ps_ver=%%g)
set "ps_dir=%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%"

::Op
set "nop=msg * This isn't a valid option. Choose a number from the list."

::N of functions
for /l %%G in (1,1,5) do (set ps_op%%G=1)

::The smaller possible
set "cc=Creative Cloud"

:menu
mode con: cols=50 lines=15
cls
title EXN PHOTOFiT %_ver%
call :ps_top
echo [7A[43C%be1%%gn1%PS %ps_ver% [1H[6B
echo %be1%   1   %be2%  Kill Background Processes
echo %be1%   2   %be2%  Debloat Photoshop
echo %be1%   3   %be2%  Firewall - Block PS
echo %be1%   4   %be2%  Project Page
echo %be1%   5   %be2%  Exit
%bsm%
echo:
set /p c=── Type a number and press ENTER: 
if !ps_op%c%! NEQ 1 (%nop% & goto menu) else (goto ps_op%c%)

:ps_op1
cls
call :ps_top
echo %be1%   ─   %be2%  Kill Background Processes%rst%
%bsm%
call :yn
set /p ps_op1_c=── 
if %ps_op1_c%==2 goto menu
if %ps_op1_c%==1 echo [6A&call :act&call :ps_op1_go &echo [5A&call :ok& pause >nul & goto menu
%nop% & goto ps_op1


:ps_op1_go
:: Kill processes
for %%G in ("Creative Cloud.exe" "Adobe Desktop Service.exe" "Adobe CEF Helper.exe" "AdobeUpdateService.exe" "CoreSync.exe" "AdobeIPCBroker.exe" "Adobe Installer.exe" "CCLibrary.exe" "AdobeNotificationClient.exe" "AdobeIPCBroker.exe" "CCXProcess.exe" "AGSService.exe" "AGMService.exe" "LogTransport2.exe" "AdobeGCClient.exe") do (taskkill /f /im %%G >nul 2>&1)
:: Disable Services
for %%G in (AGSService AdobeUpdateService AGMService AdobeARMservice) do (sc stop %%G >nul 2>&1 & sc config %%G start= disabled >nul 2>&1)
schtasks /change /tn "Adobe Creative Cloud" /Disable >nul 2>&1
goto:eof


:ps_op2
cls
call :ps_top
echo %be1%   ─   %be2%  Debloat Photoshop%rst%
%bsm%  Core Sync, CCX Process and A LOT more
%bsm%
call :yn
set /p ps_op2_c=── 
if %ps_op2_c%==2 goto menu
if %ps_op2_c%==1 goto ps_op2_go
%nop% & goto ps_op2


:ps_op2_go
set "acc=Adobe Creative Cloud"
echo [6A
call :act
::Kill processes first
call :ps_op1_go

::Start debloat process
for %%G in (Installer SLStore) do (rd /s /q %ProgramData%\Adobe\%%G >nul 2>&1)
for %%G in ("CEP\extensions\com.adobe.DesignLibraryPanel.html" "UXP\com.adobe.cclibrariespanel UXP\com.adobe.ccx.comments-webview" "DynamicLinkMediaServer") do (rd /s /q %ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Required\%%~G >nul 2>&1)
for %%G in ("%acc%" "%acc% Experience") do (rd /s /q %ProgramFiles%\Adobe\%%~G >nul 2>&1)
for %%G in ("Microsoft" "Adobe Desktop Common" "AdobeGCClient" "Creative Cloud Libraries" "CoreSyncExtension" "UXP") do (rd /s /q "%CommonProgramFiles%\Adobe\%%~G" >nul 2>&1)
for %%G in (ADS AdobeGenuineClient HDBox LCC Runtime) do (rd /s /q "%CommonProgramFiles(x86)%\Adobe\Adobe Desktop Common\%%G" >nul 2>&1)
for %%G in ("%ProgramFiles(x86)%\Adobe" "%SystemDrive%\Users\Public\Documents\Adobe" "%Homepath%\AppData\LocalLow\Adobe") do (rd /s /q "%%~G" >nul 2>&1)
for /d %%G in ("%CommonProgramFiles%\Adobe\CEP\extensions\CC_LIBRARIES*") do (rd /s /q "%%G" >nul 2>&1)
for %%G in ("Common\Media Cache" "Common\Media Cache Files" "Common\Peak Files" "Common\Team Projects Cache" "Common\Team Projects Local Hub" "CRLogs" "CameraRaw\Logs" "Adobe PDF" "Team Projects Local Hub") do (rd /s /q %appdata%\Adobe\%%~G >nul 2>&1)
for /d %%G in ("%CommonProgramFiles%\Adobe\UXP\extensions\com.adobe.ccx.start-*") do (rd /s /q "%%G" >nul 2>&1)
rd /s /q "%Homepath%\Creative Cloud Files" >nul 2>&1
echo [5A
call :ok                  
pause >nul
goto menu

:ps_op3
cls
call :ps_top
echo %be1%   ─   %be2%  Firewall - Block Photoshop%rst%
%bsm%
call :yn
set /p ps_op3_c=── 
if %ps_op3_c%==2 goto menu
if %ps_op3_c%==1 goto ps_op3_go

:ps_op3_go
echo [6A
call :act
for %%G in (in out) do (netsh advfirewall firewall add rule name="Photoshop.exe" dir=%%G program="%ProgramFiles%\Adobe\Adobe Photoshop %ps_ver%\Photoshop.exe" action=block enable=yes >nul 2>&1)
echo [5A
call :ok
pause >nul
goto menu

:ps_op4
start https://github.com/exncode/EXN-PHOTOFiT-Photoshop-Tools & goto menu

:ps_op5
exit

:ps_top
%bbg%
echo %be1%   EXN                                            %rst%
echo %be1%   █▀█ █ █ █▀█ ▀█▀ █▀█ █▀▀ ▀ ▀█▀                  %rst%
echo %be1%   █▀▀ █▀█ █▄█  █  █▄█ █▀  █  █                   %rst%
echo %be1%   7kb - Fast, small and easy.                    %rst%
%bbg%
%bsm%
goto:eof

:yn
echo %be1%   1   %gn2%  Start    %rst%
echo %be1%   2     Go back  %rst%
echo:
goto:eof

:act
%bsm%
%bsm%  Working, wait...
%bsm%                                           
echo:
goto:eof

:ok
%gsm%
echo %gn2%  Done [m%gn1%  Press any key to go back.
%gsm%                                           
goto:eof

:er
title ❌ Something went wrong.
echo [2A[41m[97m  Something went wrong :(  %rst%
echo:
goto:eof