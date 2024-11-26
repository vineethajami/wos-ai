# =============================================================================
#
# Copyright (c) 2024, Qualcomm Innovation Center, Inc. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# =============================================================================

<#  
    The MLC_Setup.ps1 PowerShell script automatesthe setup process for MLC LLM by downloading and installing necessary components, including Miniconda and various dependencies.
    It creates and activates a virtual environment, upgrades pip, and installs required Python packages. 
    The function also runs scripts to check and ensure all dependencies are correctly set up, providing a complete and successful installation for MLC LLM tutorials. 
    By default, $rootDirPath is set to C:\Qualcomm_AI, where all files will be downloaded.
	
    Note: Users can modify values such as rootDirPath, QNN SDK version, etc, if desired
#>



############################ Define the URL for download ###############################################

$condaUrl       = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
$mlcLlmUtilsUrl = "https://codelinaro.jfrog.io/artifactory/clo-472-adreno-opensource-ai/mlc-llm/mlc_llm-utils-win-x86.zip"
$mingwUrl       = "https://nuwen.net/files/mingw/mingw-19.0.exe"
$gitUrl         = "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/Git-2.47.0.2-64-bit.exe"

$condaInstallPath = "C:\ProgramData\miniconda3"
$mingwInstallPath = "C:\MinGW"
$gitInstallPath   = "C:\Program Files\Git"




########################################      Function        ##########################################

Function Set_Variables {
    param (
        [string]$rootDirPath = "C:\WoS_AI"
    )
    # Create the Root folder if it doesn't exist
    if (-Not (Test-Path $rootDirPath)) {
        New-Item -ItemType Directory -Path $rootDirPath
    }
    Set-Location -Path $rootDirPath
    # Define download directory inside the working directory for downloading all dependency files and SDK.
	$global:DIR_PATH = "$rootDirPath"
    $global:downloadDirPath = "$rootDirPath\Downloads"
    # Create the Root folder if it doesn't exist
    if (-Not (Test-Path $downloadDirPath)) {
        New-Item -ItemType Directory -Path $downloadDirPath
    }
    # Define the path where the installer will be downloaded.
    $global:condaDownloaderPath       = "$downloadDirPath\miniconda.exe"
	$global:mingwDownloaderPath       = "$downloadDirPath\mingw-19.0.exe"
    $global:gitDownloadPath           = "$downloadDirPath\Git-2.47.0.2-64-bit.exe"
}

Function download_file {
    param (
        [string]$url,
        [string]$downloadfile
    )
    # Download the file
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
        $zipFilePath = "$rootDirPath\Downloads\downloaded.zip"
		if (Test-Path $zipFilePath) {
            Write-Output "MLC already exists at : $condaDownloaderPath"
        } else {
			# Download the ZIP file
			Invoke-WebRequest -Uri $artifactsUrl -OutFile $zipFilePath
		}

         # Extract the ZIP file
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, "$rootDirPath\Mlc_llm")
	    return $true
    }  
}


Function install_conda {
    param()
    process {
        # Install conda
        #Start-Process -FilePath $condaDownloaderPath -ArgumentList "/S", "/D=$DIR_PATH\Miniconda3" -Wait
		#$env:Path += ";$DIR_PATH\Miniconda3;$DIR_PATH\Miniconda3\Scripts;$DIR_PATH\Miniconda3\Library\bin"
		Start-Process -FilePath $condaDownloaderPath -ArgumentList "/S" -Wait
        $env:Path += ";$condaInstallPath;$condaInstallPath\Scripts;$condaInstallPath\Library\bin"
        [System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine) + ";" + [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
        & "$condaInstallPath\Scripts\conda.exe" init
		return $true
    }   
}

Function Install-Mingw {
    param()
    process {
        # Install MinGW
        Start-Process -FilePath $mingwDownloaderPath -ArgumentList "/SILENT /DIR=$mingwInstallPath" -Wait

        # Check if MinGW was installed successfully
        if (Test-Path "$mingwInstallPath\bin\gcc.exe") {
            Write-Output "MinGW installed successfully."

            # Get the current PATH environment variable
            $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

            # Add the new paths if they are not already in the PATH
            if ($envPath -notlike "*$mingwInstallPath\bin*") {
                $envPath = "$mingwInstallPath\bin;$envPath"
                [System.Environment]::SetEnvironmentVariable("Path", $envPath, [System.EnvironmentVariableTarget]::User)
            }

            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine) + ";" + [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
            return $true
        } 
        else {
            return $false
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

Function download_install_conda {
    param()
    process {
        if (Test-Path $condaDownloaderPath) {
            Write-Output "conda File already exists at : $condaDownloaderPath"
        } else {
            Write-Output "Downloading the conda file ..."
            $result = download_file -url $condaUrl -downloadfile $condaDownloaderPath
            # Checking for successful download
            if ($result) {
                Write-Output "conda File is downloaded at : $condaDownloaderPath"
            } else {
                Write-Output "conda download failed. Download the conda file from : $condaUrl and install."
                return
            }
        }
        
        Write-Output "Installing conda..."
        if (install_conda) {
            Write-Output "conda installed successfully."
        }
    }
}

function download_install_mingw {
    param(
    )
    process {
        # Check if MinGW is already installed
        if (Test-Path "$mingwInstallPath\bin\gcc.exe") {
            Write-Output "MinGW already installed."
        }
        # Else downloading and installing MinGW
        else {
            Write-Output "Downloading the MinGW file ..."
            $result = download_file -url $mingwUrl -downloadfile $mingwDownloaderPath
            # Checking for successful download
            if ($result) {
                Write-Output "MinGW file is downloaded at: $mingwDownloaderPath"
                Write-Output "Installing MinGW..."
                if (Install-Mingw) {
                    Write-Output "MinGW installed successfully."
                }
                else {
                    Write-Output "MinGW installation failed. Please install MinGW from: $mingwDownloaderPath"
                }
            }
            else {
                Write-Output "MinGW download failed. Download the MinGW file from: $mingwUrl and install."
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

Function MLC_LLM_Setup {
    param(
        [string]$rootDirPath = "C:\WoS_AI"
        )
    process {
        Set_Variables -rootDirPath $rootDirPath
        download_install_conda
        download_install_mingw
        download_install_git
		Write-Output "Creating the conda env ... "
        conda create -n MLC_VENV -c conda-forge "llvmdev=15" "cmake>=3.24" git rust numpy==1.26.4 decorator psutil typing_extensions scipy attrs git-lfs python=3.12 onnx clang_win-64 -y
        #conda activate MLC_VENV
        download_and_extract -artifactsUrl $mlcLlmUtilsUrl -rootDirPath $rootDirPath
        cd $rootDirPath
		if (Test-Path "$downloadDirPath\mlc_llm_adreno_cpu-0.1.dev0-cp312-cp312-win_amd64.whl") {
            Write-Output "MLC wheel already exists at : $condaDownloaderPath"
        } else {
			Write-Output "Downloading MLC wheel file..."
			Invoke-WebRequest -o "$downloadDirPath\mlc_llm_adreno_cpu-0.1.dev0-cp312-cp312-win_amd64.whl" https://codelinaro.jfrog.io/artifactory/clo-472-adreno-opensource-ai/mlc-llm/mlc_llm_adreno_cpu-0.1.dev0-cp312-cp312-win_amd64.whl
			Write-Output "MLC wheel downloaded at : $downloadDirPath\mlc_llm_adreno_cpu-0.1.dev0-cp312-cp312-win_amd64.whl"
		}
		
		if (Test-Path "$downloadDirPath\tvm_adreno_cpu-0.19.dev0-cp312-cp312-win_amd64.whl") {
            Write-Output "TVM wheel already exists at : $condaDownloaderPath"
        } else {
			Write-Output "Downloading TVM wheel file..."
			Invoke-WebRequest -o "$downloadDirPath\tvm_adreno_cpu-0.19.dev0-cp312-cp312-win_amd64.whl" https://codelinaro.jfrog.io/artifactory/clo-472-adreno-opensource-ai/mlc-llm/tvm_adreno_cpu-0.19.dev0-cp312-cp312-win_amd64.whl
			Write-Output "TVM wheel downloaded at : $downloadDirPath\tvm_adreno_cpu-0.19.dev0-cp312-cp312-win_amd64.whl"
		}
      	
		$mlcEnvPath = (conda info --base) + "\envs\MLC_VENV"

		# Install the package into the specified Conda environment
		& "$mlcEnvPath\Scripts\pip.exe" install "$downloadDirPath\mlc_llm_adreno_cpu-0.1.dev0-cp312-cp312-win_amd64.whl" --prefix $mlcEnvPath
		& "$mlcEnvPath\Scripts\pip.exe" install "$downloadDirPath\tvm_adreno_cpu-0.19.dev0-cp312-cp312-win_amd64.whl" --prefix $mlcEnvPath
		
    }
}
