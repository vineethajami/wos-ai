# =============================================================================
#
# Copyright (c) 2024, Qualcomm Innovation Center, Inc. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# =============================================================================

# qnn_setup.ps1 script for installing QNN-related dependencies. Users can modify values such as installer paths, QNN SDK version, etc.
# Users can get information about the dependencies that will be installed on the system.

# Set the permission on PowerShell to execute the command. If prompted, accept and enter the desired input to provide execution permission.
Set-ExecutionPolicy RemoteSigned

# Define URLs for dependencies
# Python 3.10.9 dependency for QNN SDK.
$pythonUrl = "https://www.python.org/ftp/python/3.10.9/python-3.10.9-amd64.exe"

#cmake 3.30.4 url
$cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v3.30.4/cmake-3.30.4-windows-arm64.msi"

# Artifacts for tutorials, including:
# - kitten.jpg: Test image for prediction
# - qc_utils.py: Utility file for preprocessing images and postprocessing to get top 5 predictions
# - imagenet_classes.txt: Image label file for post-processing
# - Other files: PDFs and text files with Qualcomm legal information
$artifactsUrl = "https://docs.qualcomm.com/bundle/publicresource/HS11-62010-1.zip"

# ONNX model file for image prediction used in tutorials
$modelUrl = "https://qaihub-public-assets.s3.us-west-2.amazonaws.com/apidoc/mobilenet_v2.onnx"

# QNN SDK download link for converting, generating, and executing the model on HTP (NPU) backend
$aIEngineSdkUrl = "https://softwarecenter.qualcomm.com/api/download/software/qualcomm_neural_processing_sdk/v2.27.0.240926.zip"

# Visual Studio dependency for compiling and converting ONNX model to C++ & binary, used for generating model.dll file
$vsStudioUrl = "https://download.visualstudio.microsoft.com/download/pr/07db0e25-01f0-4ac0-946d-e03196d2cc8b/0c540fea0367e284bc673654490b22403e6a93e458f855670406a2ca13c20ffe/vs_Professional.exe"

# Define working directory where all files will be stored and used in the tutorial. Users can change this path to their desired location.
$rootDirPath = "C:\Qualcomm_AI"

# Define download directory inside the working directory for downloading all dependency files and SDK
$downloadDirPath = "$rootDirPath\Downloaded_file"

# Define paths for downloaded installers
$pythonDownloaderPath = "$downloadDirPath\python-3.10.9-amd64.exe"
$cmakeDownloaderPath = "$downloadDirPath\cmake-3.30.4-windows-arm64.msi"
$vsRedistDownloadPath = "$downloadDirPath\vc_redist.arm64.exe"
$vsStudioDownloadPath = "$downloadDirPath\vs_Professional.exe"
$artifacts_Path = "$rootDirPath\kitten.jpg"
$modelFilePath = "$rootDirPath\mobilenet_v2.onnx"
$aIEngineSdkDownloadPath = "$downloadDirPath\qairt\2.27.0.240926"

# QNN SDK installation path
$aIEngineSdkInstallPath = "C:\Qualcomm\AIStack\QAIRT"

# Retrieves the value of the Username
$username =  (Get-ChildItem Env:\Username).value

# Define the python installation path.
$pythonInstallPath = "C:\Users\$username\AppData\Local\Programs\Python\Python310"
$pythonScriptsPath = $pythonPath+"\Scripts"

# Define the cmake installation path.
$cmakeInstallPath = "C:\Program Files\CMake"
# Define Python QAIRT_VENV environment path. This environment will be used to install QNN SDK dependencies and tutorial-related dependencies.
$QAIRT_VENV_Path = "$rootDirPath\QAIRT_VENV"

# Define QNN SDK version (at the time of writing tutorials). Users can change this version if they have downloaded a different version of QNN SDK.
$QNN_SDK_VERSION = "2.27.0.240926"

# QNN SDK setup path for activating the environment
$qnnEnvFilePath = "$aIEngineSdkInstallPath\$QNN_SDK_VERSION\bin\envsetup.ps1"

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


Function Install-VS_Studio {
    param()
    process {
        # Install the VS Studio
        Start-Process -FilePath $vsStudioDownloadPath -ArgumentList "--installPath C:\VS --passive --wait --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended --add Microsoft.VisualStudio.Component.VC.14.34.17.4.x86.x64 --add Microsoft.VisualStudio.Component.VC.14.34.17.4.ARM64 --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset" -Wait -PassThru
        # Check if the VS Studio
        Check-MSVC-Components-Version
    }
}


Function Show-Recommended-Version-Message {
    param (
        [String] $SuggestVersion,
        [String] $FoundVersion,
        [String] $SoftwareName
    )
    process {
        Write-Warning "The version of $SoftwareName $FoundVersion found has not been validated. Recommended to use known stable $SoftwareName version $SuggestVersion"
    }
}

Function Show-Required-Version-Message {
    param (
        [String] $RequiredVersion,
        [String] $FoundVersion,
        [String] $SoftwareName
    )
    process {
        Write-Host "ERROR: Require $SoftwareName version $RequiredVersion. Found $SoftwareName version $FoundVersion" -ForegroundColor Red
    }
}


Function Compare-Version {
    param (
        [String] $TargetVersion,
        [String] $FoundVersion,
        [String] $SoftwareName
    )
    process {
        if ( (([version]$FoundVersion).Major -eq ([version]$TargetVersion).Major) -and (([version]$FoundVersion).Minor -eq ([version]$TargetVersion).Minor) ) { }
        elseif ( (([version]$FoundVersion).Major -ge ([version]$TargetVersion).Major) -and (([version]$FoundVersion).Minor -ge ([version]$TargetVersion).Minor) ) {
            Show-Recommended-Version-Message $TargetVersion $FoundVersion $SoftwareName
        }
        else {
            Show-Required-Version-Message $TargetVersion $FoundVersion $SoftwareName
            $global:CHECK_RESULT = 0
        }
    }
}

Function Locate-Prerequisite-Tools-Path {
    param ()
    process {
        # Get and Locate VSWhere
        if (!(Test-Path $global:tools['vswhere'])) {
            Write-Host "No Visual Studio Instance(s) Detected, Please Refer To The Product Documentation For Details" -ForegroundColor Red
        }
    }
}

Function Detect-VS-Instance {
    param ()
    process {
        Locate-Prerequisite-Tools-Path

        $INSTALLED_VS_VERSION = & $global:tools['vswhere'] -latest -property installationVersion
        $INSTALLED_PATH = & $global:tools['vswhere'] -latest -property installationPath
        $productId = & $global:tools['vswhere'] -latest -property productId

        return $productId, $INSTALLED_PATH, $INSTALLED_VS_VERSION
    }
}

Function Check-VS-BuildTools-Version {
    param (
        [String] $SuggestVersion = $SUGGESTED_VS_BUILDTOOLS_VERSION
    )
    process {
        $INSTALLED_PATH = & $global:tools['vswhere'] -latest -property installationPath
        $version_file_path = Join-Path $INSTALLED_PATH "VC\Auxiliary\Build\Microsoft.VCToolsVersion.default.txt"
        if (Test-Path $version_file_path) {
            $INSTALLED_VS_BUILDTOOLS_VERSION = Get-Content $version_file_path
            Compare-Version $SuggestVersion $INSTALLED_VS_BUILDTOOLS_VERSION "VS BuildTools"
            return $INSTALLED_VS_BUILDTOOLS_VERSION
        }
        else {
            Write-Error "VS BuildTools not installed"
            $global:CHECK_RESULT = 0
        }
        return "Not Installed"
    }
}

Function Check-WinSDK-Version {
    param (
        [String] $SuggestVersion = $SUGGESTED_WINSDK_VERSION
    )
    process {
        $INSTALLED_WINSDK_VERSION = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft SDKs\Windows\v10.0' -Name ProductVersion
        if($?) {
            Compare-Version $SuggestVersion $INSTALLED_WINSDK_VERSION "Windows SDK"
            return $INSTALLED_WINSDK_VERSION
        }
        else {
            Write-Error "Windows SDK not installed"
            $global:CHECK_RESULT = 0
        }
        return "Not Installed"
    }
}

Function Check-VC-Version {
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
                Compare-Version $SuggestVersion $INSTALLED_VC_VERSION ("Visual C++(" + $Arch + ")")
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

Function Check-MSVC-Components-Version {
    param ()
    process {
        $check_result = @()
        $productId, $vs_install_path, $vs_installed_version = Detect-VS-Instance
        if ($productId) {
            $check_result += [pscustomobject]@{Name = "Visual Studio"; Version = $vs_installed_version}
        }
        else {
            $check_result += [pscustomobject]@{Name = "Visual Studio"; Version = "Not Installed"}
            $global:CHECK_RESULT = 0
        }
        $buildtools_version = Check-VS-BuildTools-Version
        $check_result += [pscustomobject]@{Name = "VS Build Tools"; Version = $buildtools_version}
        $check_result += [pscustomobject]@{Name = "Visual C++(x86)"; Version = Check-VC-Version $vs_install_path $buildtools_version "x64"}
        $check_result += [pscustomobject]@{Name = "Visual C++(arm64)"; Version = Check-VC-Version $vs_install_path $buildtools_version "arm64"}
        $check_result += [pscustomobject]@{Name = "Windows SDK"; Version = Check-WinSDK-Version}
        Write-Host ($check_result | Format-Table| Out-String).Trim()
    }
}

Function install-python {
    param()
    process {
        # Install Python
        Start-Process -FilePath $pythonDownloaderPath -ArgumentList "/quiet InstallAllUsers=1 TargetDir=$pythonInstallPath" -Wait
        # Check if Python was installed successfully
        if (Test-Path "$pythonInstallPath\python.exe") {
            Write-Output "Python installed successfully."
            # Get the current PATH environment variable
            $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

            # Add the new paths if they are not already in the PATH
            if ($envPath -notlike "*$pythonScriptsPath*") {
                $envPath = "$pythonScriptsPath;$pythonInstallPath;$envPath"
                [System.Environment]::SetEnvironmentVariable("Path", $envPath, [System.EnvironmentVariableTarget]::User)
            }

            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine) + ";" + [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

            # Verify Python installation
            python --version
        }
        else {
            Write-Output "Python installation failed."
        }
    }
}

Function install-cmake {
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

Function Download-File {
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
 

Function Download-And-Extract-Artifact {
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
        # Remove the downloaded ZIP file
        Remove-Item -Path $zipFilePath
    }  
}



############################## main code ##################################


Function download_install_python {
    param()
    process {
        # Download the python file 
        if (Test-Path $pythonDownloaderPath) {
            Write-Output "Python file already present at : $pythonDownloaderPath" # -ForegroundColor Green
        }
        else {
                Write-Output "Downloading the python file ..." 
                #Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonDownloaderPath 
                $result = Download-File -url $pythonUrl -downloadfile $pythonDownloaderPath
                if ($result) {
                    Write-Output "Python File is downloaded at : $pythonDownloaderPath" 
                } 
                else{
                    Write-Output "Python download failed. Download the python file from :  $pythonUrl" 
                }
        }
        # Install python
        if (Test-Path "$pythonInstallPath\python.exe") {
            Write-Output "Python already installed."
        }
        else{
            Write-Output "installing python..."
            if (install-python) {
                Write-Output "Python 3.10.9 installed successfully." 
            }
            else{
                Write-Output "Python installation failed.. Please installed python 3.10.9 from : $pythonDownloaderPath"  
            }
        }
    }
}



Function download_install_cmake {
    param()
    process {
        # Download the CMake file
        if (Test-Path $cmakeDownloaderPath) {
            Write-Output "CMake file already present at : $cmakeDownloaderPath"
        }
        else {
            Write-Output "Downloading the CMake file ..."
            $result = Download-File -url $cmakeUrl -downloadfile $cmakeDownloaderPath
            if ($result) {
                Write-Output "CMake file is downloaded at : $cmakeDownloaderPath"
            }
            else {
                Write-Output "CMake download failed. Download the CMake file from : $cmakeUrl"
            }
        }
        # Install CMake
        if (Test-Path "$cmakeInstallPath\bin\cmake.exe") {
            Write-Output "CMake already installed."
        }
        else {
            Write-Output "Installing CMake..."
            if (install-cmake) {
                Write-Output "CMake 3.30.4 installed successfully."
            }
            else {
                Write-Output "CMake installation failed. Please install CMake 3.30.4 from : $cmakeDownloaderPath"
            }
        }
    }
}


Function download_onnxmodel {
    param()
    process {
        # Download Model file 
        if (Test-Path $modelFilePath) {
            Write-Output "ONNX File already present at : $modelFilePath" # -ForegroundColor Green
        }
        else {
            Write-Output "Downloading the onnx model ..." 
            $result = Download-File -url $modelUrl -downloadfile $modelFilePath
            if ($result) {
                Write-Output "Onnx File is downloaded at : $modelFilePath" 

            } 
            else{
                Write-Output "Onnx download failed. Download the onnx file from :  $modelUrl" 
            }
        }
    }
}


Function download_install_vsStudio {
    param()
    process {
            # Download VS Studio file
            if (Test-Path $vsStudioDownloadPath) {
                Write-Output "VS Studio already present at : $vsStudioDownloadPath" # -ForegroundColor Green
            }
            else {
                    Write-Output "Downloading the VS Studio..." 
                    Download-File -url $vsStudioUrl -downloadfile $vsStudioDownloadPath
                    if ($result) {
                        Write-Output "VS Studio is downloaded at : $vsStudioDownloadPath" 

                    } 
                    else{
                        Write-Output "VS Studio download failed... Downloaded the VS Studio from :  $vsStudioUrl" 
                    }
            }
            #install VS-Studio
            if (Test-Path $vsInstallerPath) {
                Write-Output "VS-Studio already installed."
            }
            else{
                Write-Output "installing VS-Studio..."
                if (install-VS_Studio) {
                    Write-Output "VS-Studio installed successfully." 
                }
                else{
                    Write-Output "VS-Studio installation failed..  from : $vsStudioDownloadPath"  
                }
            }
    }
}


Function download_install_AI_Engine_Direct_SDK {
    param()
    process {
        if (Test-Path $aIEngineSdkDownloadPath) {
            Write-Output "AI Engine Direct already present at : $aIEngineSdkDownloadPath" # -ForegroundColor Green
        }
        else {
            Write-Output "Downloading the AI Engine Direct..." 
            #Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonDownloaderPath 
            $result = Download-And-Extract-Artifact -artifactsUrl $aIEngineSdkUrl -rootDirPath $downloadDirPath
            if ($result) {
                Write-Output " AI Engine Direct Artifacts File is downloaded and extracted at : $downloadDirPath" 
            }
            else {
                Write-Output " AI Engine Direct Artifacts  are already present" 
            }
        }
        $folderName = [System.IO.Path]::GetFileName($aIEngineSdkDownloadPath)
        $destinationPath = Join-Path -Path $aIEngineSdkInstallPath -ChildPath $folderName

        if (-Not (Test-Path -Path $aIEngineSdkInstallPath)) {
            New-Item -Path $aIEngineSdkInstallPath -ItemType Directory
        }

        if (-Not (Test-Path -Path $destinationPath)) {
            Move-Item -Path $aIEngineSdkDownloadPath -Destination $destinationPath
            Write-Output "AI Engine Direct installed successfully to $destinationPath"
        } 
        else {
            Write-Output "AI Engine Direct already exists at $destinationPath"
        }
    }
}

Function download_extract_artifacts {
    param()
    process {
        # Download artifacts file
        if(-Not (Test-Path -Path  $artifacts_Path)){
            $result = Download-And-Extract-Artifact -artifactsUrl $artifactsUrl -rootDirPath $rootDirPath
            Write-Output "Artifacts File is downloaded and extracted at : $rootDirPath" 
        }   
        else{
            Write-Output "Artifacts are already present" 
        }     
    }
}



############################## main code ##################################

Function installation_for_QNN_dependencies {
    param()
    process{
        download_install_python
        download_onnxmodel
        download_extract_artifacts
        download_install_vsStudio
        download_install_AI_Engine_Direct_SDK
	download_install_cmake
        # Check if virtual environment was created
        if (-Not (Test-Path -Path $QAIRT_VENV_Path))
        {
            py -3.10 -m venv $QAIRT_VENV_Path
        }
        if (Test-Path "$QAIRT_VENV_Path\Scripts\Activate.ps1") {
            & "$QAIRT_VENV_Path\Scripts\Activate.ps1" 
            # upgrade pip
            python -m pip install --upgrade pip
            #update the QNN version in the below command as needed. 
            & C:\Qualcomm\AIStack\QAIRT\$QNN_SDK_VERSION\bin\envsetup.ps1
            python "${QNN_SDK_ROOT}\bin\check-python-dependency"
            pip install psutil==6.0.0 
            pip install tensorflow==2.10.1 
            pip install tflite==2.3.0
            pip install torch==1.13.1
            pip install torchvision==0.14.1 
            pip install onnx==1.12.0
            pip install onnxruntime==1.17.1
            pip install onnxsim==0.4.36  
            pip install fiftyone              
            pip install --upgrade opencv-python
            # checking all python dependency 
            python "${QNN_SDK_ROOT}\bin\check-python-dependency"
            # checking all winndow dependency
            & "${QNN_SDK_ROOT}/bin/check-windows-dependency.ps1"

        }
    }
}

installation_for_QNN_dependencies
