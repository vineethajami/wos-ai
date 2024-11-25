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
$condaInstallPath= "C:\ProgramData\miniconda3"


########################################      Function        ##########################################

Function Set_Variables {
    param (
        [string]$rootDirPath = "C:\MLC_LLM_App"
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
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFilePath, "$rootDirPath\mlc_llm")
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




Function MLC_LLM_Setup {
    param(
        [string]$rootDirPath = "C:\MLC_LLM_App"
        )
    process {
        Set_Variables -rootDirPath $rootDirPath
        download_install_conda
		Write-Output "Creating the conda env ... "
        conda create -n mlc-venv -c conda-forge "llvmdev=15" "cmake>=3.24" git rust numpy==1.26.4 decorator psutil typing_extensions scipy attrs git-lfs python=3.12 onnx clang_win-64 -y
        #conda activate mlc-venv
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
      	
		$mlcEnvPath = (conda info --base) + "\envs\mlc-venv"

		# Install the package into the specified Conda environment
		& "$mlcEnvPath\Scripts\pip.exe" install "$downloadDirPath\mlc_llm_adreno_cpu-0.1.dev0-cp312-cp312-win_amd64.whl" --prefix $mlcEnvPath
		& "$mlcEnvPath\Scripts\pip.exe" install "$downloadDirPath\tvm_adreno_cpu-0.19.dev0-cp312-cp312-win_amd64.whl" --prefix $mlcEnvPath
		
    }
}
