@echo off
set version=1.0
title MinGW-w64 Installer v%version%
ping /n 1 github.com > nul
if %errorLevel% neq 0 (
   echo No server connection. Please check your internet connection and try again.
   pause > nul
   exit
)
whoami /groups | find "S-1-16-12288" > nul
if %errorLevel% equ 0 (
   set administrator=1
) else (
   set administrator=0
   echo * Run as administrator to be able to change the system variable, or continue with a local installation. *
   echo.
)
echo MinGW-w64 Installer v%version%
echo ==================================================
echo [1] 32 bits, Minimal C Runtime, DWARF, Universal C Runtime
echo [2] 32 bits, Subsystem POSIX, DWARF, Microsoft Visual C++ Runtime
echo [3] 32 bits, Subsystem POSIX, DWARF, Universal C Runtime
echo [4] 32 bits, Subsystem Win32, DWARF, Microsoft Visual C++ Runtime
echo [5] 32 bits, Subsystem Win32, DWARF, Universal C Runtime
echo [6] 64 bits, Minimal C Runtime, SHE, Universal C Runtime 
echo [7] 64 bits, Subsystem POSIX, SHE, Microsoft Visual C++ Runtime
echo [8] 64 bits, Subsystem POSIX, SHE, Universal C Runtime
echo [9] 64 bits, Subsystem Win32, SHE, Microsoft Visual C++ Runtime
echo [0] 64 bits, Subsystem Win32, SHE, Universal C Runtime
echo ==================================================
choice /c 1234567890 /n /m "Select a MinGW-w64 build:"
if %errorLevel% equ 1 (
    set architecture=i686
    set build=mcf-dwarf-ucrt
)
if %errorLevel% equ 2 (
    set architecture=i686
    set build=posix-dwarf-msvcrt
)
if %errorLevel% equ 3 (
    set architecture=i686
    set build=posix-dwarf-ucrt
)
if %errorLevel% equ 4 (
    set architecture=i686
    set build=win32-dwarf-msvcrt
)
if %errorLevel% equ 5 (
    set architecture=i686
    set build=win32-dwarf-ucrt
)
if %errorLevel% equ 6 (
    set architecture=x86_64
    set build=mcf-seh-ucrt
)
if %errorLevel% equ 7 (
    set architecture=x86_64
    set build=posix-seh-msvcrt
)
if %errorLevel% equ 8 (
    set architecture=x86_64
    set build=posix-seh-ucrt
)
if %errorLevel% equ 9 (
    set architecture=x86_64
    set build=win32-seh-msvcrt
)
if %errorLevel% equ 10 (
    set architecture=x86_64
    set build=win32-seh-ucrt
)
echo --------------------------------------------------
if %administrator% equ 1 (
   set installPath=C:\MinGW-w64
) else (
   set installPath=%userProfile%\MinGW-w64
)
choice /c yn /m "Install MinGW-w64 in '%installPath%'"
if %errorLevel% equ 2 (
   set /p installPath=Set install path: 
)
if not exist "%installPath%" (
   mkdir "%installPath%"
)
pushd "%installPath%"
curl -s https://api.github.com/repos/niXman/mingw-builds-binaries/releases/latest > %temp%\latest-release.json
for /f "tokens=2 delims=:," %%A in ('findstr /i "tag_name" %temp%\latest-release.json') do set latestRelease=%%A
del /q %temp%\latest-release.json
set "latestRelease=%latestRelease:~2,-1%"
for /f "tokens=1,2,3 delims=-" %%A in ("%latestRelease%") do (
    set release=%%A
    set runtime=%%B
    set revision=%%C
)
set file=%architecture%-%release%-release-%build%-%runtime%-%revision%.7z
set url=https://github.com/niXman/mingw-builds-binaries/releases/download/%latestRelease%/%file%
echo --------------------------------------------------
curl -L -o %file% %url%
echo --------------------------------------------------
tar -zxvf "%file%" -C "." --strip-components=1 "mingw64/*"
del /q "%file%"
echo %path% | findstr /i "%cd%\bin" > nul
if %errorlevel% neq 0 (
    echo --------------------------------------------------  
    if %administrator% equ 1 (
        setx /m path "%cd%\bin";"%path%"
    ) else (
        setx path "%cd%\bin";"%path%"
    )
    echo To uninstall just delete this folder and remove the environment variable from this path. > "How to uninstall.txt"
)
echo ##################################################
echo Install finish.
pause > nul
exit
