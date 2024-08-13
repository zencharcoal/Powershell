# PowerShell script to set up a Windows development environment with various tools

# Check for Chocolatey installation
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; 
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Output "Chocolatey is already installed."
}

# Update Chocolatey
choco upgrade chocolatey -y

# Install development tools
choco install visualstudio2022community -y # Visual Studio 2022 Community Edition for a full-featured IDE
choco install visualstudio2022buildtools -y # Visual Studio Build Tools for building applications
choco install vscode -y # Visual Studio Code for lightweight code editing
choco install cmake --version 3.26.4 -y # CMake for cross-platform C/C++ project building
choco install golang --version 1.20.5 -y # Go programming language
choco install python --version 3.11.4 -y # Python for scripting and automation
choco install dotnetcore-sdk --version 7.0.306 -y # .NET Core SDK for C# development
choco install sysinternals -y # Sysinternals Suite for advanced system utilities
choco install processhacker -y # Process Hacker for advanced process management
choco install git --version 2.41.0 -y # Git for version control
choco install 7zip --version 22.01 -y # 7-Zip for file archiving and compression
choco install putty -y # PuTTY for SSH and telnet client
choco install nasm --version 2.16.01 -y # Netwide Assembler for assembly language development
choco install ghidra -y # Ghidra for reverse engineering software
choco install windbg -y # Windows Debugger for debugging Windows applications
choco install rust --version 1.70.0 -y # Rust programming language for system programming

# Install additional tools using Chocolatey
$packages = @('x64dbg', 'windbg', 'binwalk', 'peid', 'cff-explorer', 'processhacker')
foreach ($package in $packages) {
    choco install $package -y
}

# Manual installations for packages not available or failed on Chocolatey
if (-not (Get-Command 'x64dbg' -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest -Uri "https://github.com/x64dbg/x64dbg/releases/download/snapshot/snapshot.zip" -OutFile "$env:TEMP\x64dbg.zip" -UseBasicParsing
    Expand-Archive -Path "$env:TEMP\x64dbg.zip" -DestinationPath "C:\Program Files\x64dbg"
    Remove-Item -Path "$env:TEMP\x64dbg.zip"
}

if (-not (Get-Command 'binwalk' -ErrorAction SilentlyContinue)) {
    # Installing binwalk on Windows may require additional dependencies and setup.
    # Consider running it inside a Linux VM or Docker for full functionality.
}

if (-not (Get-Command 'peid' -ErrorAction SilentlyContinue)) {
    # PEiD isn't maintained and its official site is down.
    # Make sure you trust the source if you decide to download it from third-party sites.
}

if (-not (Get-Command 'cff-explorer' -ErrorAction SilentlyContinue)) {
    # Direct download links for CFF Explorer might not be readily available.
    # You might need to visit NTCore's website, download it manually, and integrate it into your environment.
}

if (-not (Get-Command 'processhacker' -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest -Uri "https://github.com/processhacker/processhacker/releases/download/v2.39/processhacker-2.39-setup.exe" -OutFile "$env:TEMP\processhacker-setup.exe" -UseBasicParsing
    Start-Process -Wait -FilePath "$env:TEMP\processhacker-setup.exe"
    Remove-Item -Path "$env:TEMP\processhacker-setup.exe"
}

# Additional static library setup for Visual Studio
choco install vcpkg -y # Vcpkg for managing C and C++ libraries

# Set up vcpkg and integrate with Visual Studio
$env:VCPKG_ROOT = "C:\tools\vcpkg"
git clone https://github.com/microsoft/vcpkg.git $env:VCPKG_ROOT
& "$env:VCPKG_ROOT\bootstrap-vcpkg.bat"

# Integrate vcpkg with Visual Studio
& "$env:VCPKG_ROOT\vcpkg.exe" integrate install

# Example of installing static libraries using vcpkg
& "$env:VCPKG_ROOT\vcpkg.exe" install boost:x64-windows
& "$env:VCPKG_ROOT\vcpkg.exe" install openssl:x64-windows
& "$env:VCPKG_ROOT\vcpkg.exe" install sqlite3:x64-windows

# Install Firefox and Chrome using Chocolatey
choco install firefox -y
choco install googlechrome -y

# Configure environment variables if necessary
[System.Environment]::SetEnvironmentVariable('GOPATH', "$env:USERPROFILE\go", 'User')
[System.Environment]::SetEnvironmentVariable('GOROOT', "C:\Program Files\Go", 'User')
[System.Environment]::SetEnvironmentVariable('Path', "$env:Path;C:\Program Files\Go\bin", 'User')

Write-Output "Development environment setup complete. Please restart your PowerShell session or reboot your computer."

