# =============================================================================
#
# Copyright (c) 2024, Qualcomm Innovation Center, Inc. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# =============================================================================

<#  dml_npu_setup.ps1 script for installing dependencies required for executing a sample application using DML EP on NPU. 
    Users can modify values such as installer paths etc.

    By default, $rootDirPath is set to C:\Qualcomm_AI, where all files will be downloaded.
    Note: Users can change this path to another location if desired.
#>

# Set the permission on PowerShell to execute the command. If prompted, accept and enter the desired input to provide execution permission.
Set-ExecutionPolicy RemoteSigned

# Define URLs for dependencies

# Cmake 3.30.4 url
$cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v3.30.4/cmake-3.30.4-windows-arm64.msi"

#git 2.47.0 url
$gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/Git-2.47.0.2-64-bit.exe"


# Visual Studio dependency 
$vsStudioUrl = "https://download.visualstudio.microsoft.com/download/pr/7593f7f0-1b5b-43e1-b0a4-cceb004343ca/09b5b10b7305ae76337646f7570aaba52efd149b2fed382fdd9be2914f88a9d0/vs_Enterprise.exe"

# Define working directory where all files will be stored and used in the tutorial. Users can change this path to their desired location.
$rootDirPath = "C:\Qualcomm_AI"

# Define download directory inside the working directory for downloading all dependency files and SDK
$downloadDirPath = "$rootDirPath\Downloaded_file"

# Define paths for downloaded installers
$cmakeDownloaderPath  = "$downloadDirPath\cmake-3.30.4-windows-arm64.msi"
$vsStudioDownloadPath = "$downloadDirPath\vs_Enterprise.exe"
$gitDownloadPath = "$downloadDirPath\Git-2.47.0.2-64-bit.exe"

# Define the cmake installation path.
$cmakeInstallPath = "C:\Program Files\CMake"

# Define the Git installation path.
$gitInstallPath = "C:\Program Files\Git"



$vsInstallerPath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe"
$SUGGESTED_VS_BUILDTOOLS_VERSION = "14.34"
$SUGGESTED_WINSDK_VERSION = "10.0.22621"
$SUGGESTED_VC_VERSION = "19.34"

$global:CHECK_RESULT = 1
$global:tools = @{}
$global:tools.add( 'vswhere', "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" )

# Create the Root folder if it doesn't exist
if (-Not (Test-Path $downloadDirPath)) {
    New-Item -ItemType Directory -Path $downloadDirPath
}


############################ Function ##################################


Function install_VS_Studio {
    param()
    process {
        # Install the VS Studio
        Start-Process -FilePath $vsStudioDownloadPath -ArgumentList "--installPath C:\VS --passive --wait --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --add Microsoft.VisualStudio.Component.VC.14.34.17.4.x86.x64 --add Microsoft.VisualStudio.Component.VC.14.34.17.4.ARM64 --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset" -Wait -PassThru
        # Check if the VS Studio
        check_MSVC_components_version
    }
}


Function show_recommended_version_message {
    param (
        [String] $SuggestVersion,
        [String] $FoundVersion,
        [String] $SoftwareName
    )
    process {
        Write-Warning "The version of $SoftwareName $FoundVersion found has not been validated. Recommended to use known stable $SoftwareName version $SuggestVersion"
    }
}

Function show_required_version_message {
    param (
        [String] $RequiredVersion,
        [String] $FoundVersion,
        [String] $SoftwareName
    )
    process {
        Write-Host "ERROR: Require $SoftwareName version $RequiredVersion. Found $SoftwareName version $FoundVersion" -ForegroundColor Red
    }
}


Function compare_version {
    param (
        [String] $TargetVersion,
        [String] $FoundVersion,
        [String] $SoftwareName
    )
    process {
        if ( (([version]$FoundVersion).Major -eq ([version]$TargetVersion).Major) -and (([version]$FoundVersion).Minor -eq ([version]$TargetVersion).Minor) ) { }
        elseif ( (([version]$FoundVersion).Major -ge ([version]$TargetVersion).Major) -and (([version]$FoundVersion).Minor -ge ([version]$TargetVersion).Minor) ) {
            show_recommended_version_message $TargetVersion $FoundVersion $SoftwareName
        }
        else {
            show_required_version_message $TargetVersion $FoundVersion $SoftwareName
            $global:CHECK_RESULT = 0
        }
    }
}

Function locate_prerequisite_tools_path {
    param ()
    process {
        # Get and Locate VSWhere
        if (!(Test-Path $global:tools['vswhere'])) {
            Write-Host "No Visual Studio Instance(s) Detected, Please Refer To The Product Documentation For Details" -ForegroundColor Red
        }
    }
}

Function detect_VS_instance {
    param ()
    process {
        locate_prerequisite_tools_path

        $INSTALLED_VS_VERSION = & $global:tools['vswhere'] -latest -property installationVersion
        $INSTALLED_PATH = & $global:tools['vswhere'] -latest -property installationPath
        $productId = & $global:tools['vswhere'] -latest -property productId

        return $productId, $INSTALLED_PATH, $INSTALLED_VS_VERSION
    }
}

Function check_VS_BuildTools_version {
    param (
        [String] $SuggestVersion = $SUGGESTED_VS_BUILDTOOLS_VERSION
    )
    process {
        $INSTALLED_PATH = & $global:tools['vswhere'] -latest -property installationPath
        $version_file_path = Join-Path $INSTALLED_PATH "VC\Auxiliary\Build\Microsoft.VCToolsVersion.default.txt"
        if (Test-Path $version_file_path) {
            $INSTALLED_VS_BUILDTOOLS_VERSION = Get-Content $version_file_path
            compare_version $SuggestVersion $INSTALLED_VS_BUILDTOOLS_VERSION "VS BuildTools"
            return $INSTALLED_VS_BUILDTOOLS_VERSION
        }
        else {
            Write-Error "VS BuildTools not installed"
            $global:CHECK_RESULT = 0
        }
        return "Not Installed"
    }
}

Function check_WinSDK_version {
    param (
        [String] $SuggestVersion = $SUGGESTED_WINSDK_VERSION
    )
    process {
        $INSTALLED_WINSDK_VERSION = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SDKs\Windows\v10.0' -Name ProductVersion
        if($?) {
            compare_version $SuggestVersion $INSTALLED_WINSDK_VERSION "Windows SDK"
            return $INSTALLED_WINSDK_VERSION
        }
        else {
            Write-Error "Windows SDK not installed"
            $global:CHECK_RESULT = 0
        }
        return "Not Installed"
    }
}

Function check_VC_version {
    param (
        [String] $VsInstallLocation,
        [String] $BuildToolVersion,
        [String] $Arch,
        [String] $SuggestVersion = $SUGGESTED_VC_VERSION
    )
    process {
        $VcExecutable = Join-Path $VsInstallLocation "VC\Tools\MSVC\" | Join-Path -ChildPath $BuildToolVersion | Join-Path -ChildPath "bin\Hostx64" | Join-Path -ChildPath $Arch | Join-Path -ChildPath "cl.exe"

        if(Test-Path $VcExecutable) {
            #execute $VcExecutable and retrieve stderr since version is in it.
            $process_alloutput = & "$VcExecutable" 2>&1
            $process_stderror = $process_alloutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }
            $CMD = $process_stderror | Out-String | select-string "Version\s+(\d+\.\d+\.\d+)" # The software version is output in STDERR
            $INSTALLED_VC_VERSION = $CMD.matches.groups[1].value
            if($INSTALLED_VC_VERSION) {
                compare_version $SuggestVersion $INSTALLED_VC_VERSION ("Visual C++(" + $Arch + ")")
                return $INSTALLED_VC_VERSION
            }
            else {
                Write-Error "Visual C++ not installed"
                $global:CHECK_RESULT = 0
            }
        }
        return "Not Installed"
    }
}

Function check_MSVC_components_version {
    param ()
    process {
        $check_result = @()
        $productId, $vs_install_path, $vs_installed_version = detect_VS_instance
        if ($productId) {
            $check_result += [pscustomobject]@{Name = "Visual Studio"; Version = $vs_installed_version}
        }
        else {
            $check_result += [pscustomobject]@{Name = "Visual Studio"; Version = "Not Installed"}
            $global:CHECK_RESULT = 0
        }
        $buildtools_version = check_VS_BuildTools_version
        $check_result += [pscustomobject]@{Name = "VS Build Tools"; Version = $buildtools_version}
        $check_result += [pscustomobject]@{Name = "Visual C++(x86)"; Version = check_VC_version $vs_install_path $buildtools_version "x64"}
        $check_result += [pscustomobject]@{Name = "Visual C++(arm64)"; Version = check_VC_version $vs_install_path $buildtools_version "arm64"}
        $check_result += [pscustomobject]@{Name = "Windows SDK"; Version = check_WinSDK_version}
        Write-Host ($check_result | Format-Table| Out-String).Trim()
    }
}



Function install_cmake {
    param()
    process {
        # Install CMake
        Start-Process msiexec.exe -ArgumentList "/i", $cmakeDownloaderPath, "/quiet", "/norestart" -Wait
        # Check if CMake was installed successfully
        if (Test-Path "$cmakeInstallPath\bin\cmake.exe") {
            Write-Output "CMake installed successfully."
            # Get the current PATH environment variable
            $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

            # Add the new paths if they are not already in the PATH
            if ($envPath -notlike "*$cmakeInstallPath\bin*") {
                $envPath = "$cmakeInstallPath\bin;$envPath"
                [System.Environment]::SetEnvironmentVariable("Path", $envPath, [System.EnvironmentVariableTarget]::User)
            }

            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine) + ";" + [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

            # Verify CMake installation
            cmake --version
        }
        else {
            Write-Output "CMake installation failed."
        }
    }
}

Function install_git {
    param()
    process {
        # Install Git
        Start-Process -FilePath $gitDownloadPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
        # Check if Git was installed successfully
        if (Test-Path "$gitInstallPath\bin\git.exe") {
            Write-Output "Git installed successfully."
            # Get the current PATH environment variable
            $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

            # Add the new paths if they are not already in the PATH
            if ($envPath -notlike "*$gitInstallPath\bin*") {
                $envPath = "$gitInstallPath\bin;$envPath"
                [System.Environment]::SetEnvironmentVariable("Path", $envPath, [System.EnvironmentVariableTarget]::User)
            }

            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine) + ";" + [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

            # Verify Git installation
            git --version
        }
        else {
            Write-Output "Git installation failed."
        }
    }
}

Function download_file {
    param (
        [string]$url,
        [string]$downloadfile
    )
    process {
        try {
            Invoke-WebRequest -Uri $url -OutFile $downloadfile
            return $true
        }
        catch {
            return $false
        }
    }
}
 
Function download_and_extract {
    param (
        [string]$artifactsUrl,
        [string]$rootDirPath
    )
    process {
        $zipFilePath = "$rootDirPath\downloaded.zip"
        # Download the ZIP file
        Invoke-WebRequest -Uri $artifactsUrl -OutFile $zipFilePath

         # Extract the ZIP file
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, $rootDirPath)
    }  
}
############################## Main code ##################################






Function download_install_cmake {
    param()
    process {
        # Checking if CMake already installed
        # If yes
        if (Test-Path "$cmakeInstallPath\bin\cmake.exe") {
            Write-Output "CMake already installed."
        }
        # Else downloading and installing CMake
        else {
            Write-Output "Downloading the CMake file ..."
            $result = download_file -url $cmakeUrl -downloadfile $cmakeDownloaderPath
            # Checking for successful download
            if ($result) {
                Write-Output "CMake file is downloaded at : $cmakeDownloaderPath"
                Write-Output "Installing CMake..."
                if (install_cmake) {
                    Write-Output "CMake 3.30.4 installed successfully."
                }
                else {
                    Write-Output "CMake installation failed. Please install CMake 3.30.4 from : $cmakeDownloaderPath"
                }
            }
            else {
                Write-Output "CMake download failed. Download the CMake file from : $cmakeUrl and install."
            }
        }
    }
}



Function download_install_git {
    param()
    process {
        # Checking if Git is already installed
        if (Test-Path "$gitInstallPath\bin\git.exe") {
            Write-Output "Git already installed."
        }
        # Else downloading and installing Git
        else {
            Write-Output "Downloading the Git file ..."
            $result = download_file -url $gitUrl -downloadfile $gitDownloadPath
            # Checking for successful download
            if ($result) {
                Write-Output "Git file is downloaded at : $gitDownloadPath"
                Write-Output "Installing Git..."
                if (install_git) {
                    Write-Output "Git 2.47.0.2 installed successfully."
                }
                else {
                    Write-Output "Git installation failed. Please install Git 2.47.0.2 from : $gitDownloadPath"
                }
            }
            else {
                Write-Output "Git download failed. Download the Git file from : $gitUrl and install."
            }
        }
    }
}



Function download_install_VS_Studio {
    param()
    process {
        # Checking if VStudio already installed
        # If yes
        if (Test-Path $vsInstallerPath) {
            Write-Output "VS-Studio already installed."
        }
        # Else downloading and installing VStudio
        else {
            Write-Output "Downloading the VS Studio..." 
            $result = download_file -url $vsStudioUrl -downloadfile $vsStudioDownloadPath
            # Checking for successful download
            if ($result) {
                Write-Output "VS Studio is downloaded at : $vsStudioDownloadPath" 
                Write-Output "installing VS-Studio..."
                if (install_VS_Studio) {
                    Write-Output "VS-Studio installed successfully." 
                }
                else{
                    Write-Output "VS-Studio installation failed..  from : $vsStudioDownloadPath"  
                }
            } 
            else{
                Write-Output "VS Studio download failed... Downloaded the VS Studio from :  $vsStudioUrl and install." 
            }
        }
    }
}






############################## main code ##################################

Function DML_NPU_Setup{
    param()
    process{        
        
        download_install_VS_Studio
	download_install_cmake
	download_install_git
        Write-Output "***** Installation of required dependencies is sucessful *****"
    }
}

DML_NPU_Setup
