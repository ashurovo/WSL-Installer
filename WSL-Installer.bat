@echo off

:: Check if running with admin privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo This script requires administrator privileges. Please run as an administrator.
    pause
    exit /b 1
)

:: Enable Windows Subsystem for Linux feature
echo Enabling Windows Subsystem for Linux feature...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart >nul

:: Enable Virtual Machine Platform feature (required for some distributions)
echo Enabling Virtual Machine Platform feature...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart >nul

:: Check if WSL 2 kernel is installed
ver > nul
if %errorlevel% == 0 (
    wsl --help > nul 2>&1
    if %errorlevel% == 1 (
        echo Installing WSL 2 kernel...
        echo This will take a while, get yourself a coffee.
        powershell.exe -Command "Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi -UseBasicParsing"
        msiexec.exe /i wsl_update_x64.msi /quiet /norestart
    ) else (
        echo WSL 2 kernel is already installed. Skipping installation.
    )
) else (
    echo WSL 2 requires Windows build 19041 or higher.
    pause
    exit
)

:: Display available Linux distributions and prompt user for selection
echo.
echo Available Linux distributions:
echo 1. Ubuntu 20.04 LTS
echo 2. Debian GNU/Linux 10 (buster)
echo 3. Kali Linux Rolling
set /p distro="Enter the number of your selected distribution: "

:: Install the selected Linux distribution
echo.
if %distro% equ 1 (
    echo Installing Ubuntu 20.04 LTS...
    powershell.exe -Command "Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu.appx -UseBasicParsing" >nul
    Ubuntu.appx >nul
) else if %distro% equ 2 (
    echo Installing Debian GNU/Linux...
    powershell.exe -Command "Invoke-WebRequest -Uri https://aka.ms/wsl-debian-gnulinux -OutFile Debian.appx -UseBasicParsing" >nul
    Debian.appx >nul
) else if %distro% equ 3 (
    echo Installing Kali Linux...
    powershell.exe -Command "Invoke-WebRequest -Uri https://aka.ms/wsl-kali-linux-new -OutFile Kali.appx -UseBasicParsing" >nul
    Kali.appx >nul
) else (
    echo Invalid selection. Please enter a number between 1 and 3.
    pause
    exit /b 1
)
:: uninstall the .appx file
echo.
if exist %cd%\Ubuntu.appx (
    echo Ubuntu 20.04 LTS installed successfully.
    powershell.exe -Command "Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu20.04onWindows | Remove-AppxPackage -AllUsers" >nul
    del /q Ubuntu.appx >nul
) else if exist %cd%\Debian.appx (
    echo Debian GNU/Linux installed successfully.
    powershell.exe -Command "Get-AppxPackage -Name TheDebianProject.DebianGNULinux | Remove-AppxPackage -AllUsers" >nul
    del /q Debian.appx >nul
) else if exist %cd%\Kali.appx (
    echo Kali Linux installed successfully.
    powershell.exe -Command "Get-AppxPackage -Name KaliLinux.54290C8133FEE_ | Remove-AppxPackage -AllUsers" >nul
    del /q Kali.appx >nul
)

echo.
pause