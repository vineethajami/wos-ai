# =============================================================================
#
# Copyright (c) 2025, Qualcomm Innovation Center, Inc. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# =============================================================================

<#  
    The oga_setup.ps1 PowerShell script automates the setup process for ONNX Runtime (ORT) QNN and GenAI by downloading and installing all required components, including Python, Git, ONNX Runtime GenAI, and ONNX Runtime QNN.
    The script checks whether a Python virtual environment exists at the specified $rootDirPath. If it does not, the script creates the environment, activates it, upgrades pip, and installs the necessary Python packages.
    Upon successful completion, a confirmation message is displayed. By default, the root directory is set to C:\WoS_AI, where all files will be downloaded and the virtual environment will be created. 
#>

############################ Define the URL for download ##################################

# URL for downloading the python 3.12.6 
<#  For Python 3.12.6 dependency:
    - Any version of Python can be used for AMD architecture.
    - For ARM architecture, install Python 3.11.x only. ORT QNN EP supports only Python ARM or AMD installations.
    - Other ORT EPs require the AMD version of Python.
    - To use ORT QNN EP on ARM, it is advised to create two Python environments: one for pre- and post-processing, and a second ARM environment for execution.
    Note: Python ARM has limitations with other dependencies such as torch, onnx, etc.
    Therefore, we recommend using the AMD version to avoid these issues.
#>
$pythonUrl = "https://www.python.org/ftp/python/3.12.6/python-3.12.6-amd64.exe"

$gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.49.0.windows.1/Git-2.49.0-arm64.exe"

<# Required files 
    - oga_setup.ps1      : oga_setup script for environment activation
    - License             : License document
#>
$licenseUrl        = "https://raw.githubusercontent.com/quic/wos-ai/refs/heads/main/LICENSE"


############################ python installation path ##################################
# Retrieves the value of the Username
$username =  (Get-ChildItem Env:\Username).value

$pythonInstallPath = "C:\Users\$username\AppData\Local\Programs\Python\Python312"
$pythonScriptsPath = $pythonInstallPath+"\Scripts"
$gitInstallPath = "C:\Program Files\Git"

<#
    The tutorial section will have its own individual Python environment:

    - OGA QNN EP           : Uses SDX_OGA_ENV, which has specific Python package dependencies.

    Define the paths for each environment to be created in the root directory 
	
    Note: Users can change this path to another location if desired.
#>

$OGA_ENV_Path = "Python_Venv\SDX_OGA_ENV"

####################################################################################
############################      Function        ##################################


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
    $global:downloadDirPath = "$rootDirPath\Downloads"
    # Create the Root folder if it doesn't exist
    if (-Not (Test-Path $downloadDirPath)) {
        New-Item -ItemType Directory -Path $downloadDirPath
    }
    # Define the path where the installer will be downloaded.
    $global:pythonDownloaderPath = "$downloadDirPath\python-3.12.6-amd64.exe"
    $global:gitDownloaderPath = "$downloadDirPath\Git-2.49.0-arm64.exe"
    
    # Define the license download path.
    $global:lincensePath      = "$rootDirPath\License"

    $global:debugFolder    = "$rootDirPath\Debug_Logs"
    # Create the Root folder if it doesn't exist
    if (-Not (Test-Path $debugFolder)) {
        New-Item -ItemType Directory -Path $debugFolder
    }
    
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

Function Show-Progress {
    param (
        [int]$percentComplete,
        [int]$totalPercent
    )
    $progressBar = ""
    $progressWidth = 100
    $progress = [math]::Round((($percentComplete/$totalPercent)*100) / 100 * $progressWidth)
    for ($i = 0; $i -lt $progressWidth; $i++) {
        if ($i -lt $progress) {
            $progressBar += "#"
        } else {
            $progressBar += "-"
        }
    }
    # Write-Progress -Activity "Progress" -Status "$percentComplete% Complete" -PercentComplete $percentComplete
    Write-Host "[$progressBar] ($percentComplete/$totalPercent) Setup Complete"
}

Function install_python {
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
        Start-Process -FilePath $gitDownloaderPath -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
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


Function download_script_license{
    param()
    process{
        # License 
        # Checking if License already present 
        # If yes
        if(Test-Path $lincensePath){
            Write-Output "License is already downloaded at : $lincensePath"
        }
        # Else dowloading
        else{
            $result = download_file -url $licenseUrl -downloadfile $lincensePath
            if($result){
                Write-Output "License is downloaded at : $lincensePath"
            }
            else{
                Write-Output "License download failed. Download from $licenseUrl"
            }
        }
    }
}

Function download_install_python {
    param()
    process {
        # Check if python already installed
        # If Yes
        if (Test-Path "$pythonInstallPath\python.exe") {
            Write-Output "Python already installed."
        }
        # Else downloading and installing python
        else{
            Write-Output "Downloading the python file ..." 
            $result = download_file -url $pythonUrl -downloadfile $pythonDownloaderPath
            # Checking for successful download
            if ($result) {
                Write-Output "Python File is downloaded at : $pythonDownloaderPath"
                Write-Output "Installing python..."
                if (install_python) {
                    Write-Output "Python installed successfully." 
                }
                else {
                    Write-Output "Python installation failed.. Please installed python from : $pythonDownloaderPath"  
                }
            } 
            else{
                Write-Output "Python download failed. Download the python file from : $pythonUrl and install." 
            }
        }
    }
}

Function download_install_git {
    param()
    process {
        # Check if Git is already installed
        if (Test-Path "$gitInstallPath\cmd\git.exe") {
            Write-Output "Git is already installed."
        }
        else {
            Write-Output "Downloading the Git installer..."
            $result = download_file -url $gitUrl -downloadfile $gitDownloaderPath
            # Check if download was successful
            if ($result) {
                Write-Output "Git installer downloaded at: $gitDownloaderPath"
                Write-Output "Installing Git..."
                if (install_git) {
                    Write-Output "Git installed successfully."
                }
                else {
                    Write-Output "Git installation failed. Please install Git manually from: $gitDownloaderPath"
                }
            }
            else {
                Write-Output "Git download failed. Please download Git manually from: $gitUrl and install."
            }
        }
    }
}


############################## Main code ##################################]

Function Check_Setup {
    param(
        [string]$logFilePath
    )
    process {
        $results = @()

        # Check if Python is installed
        if (Test-Path "$pythonInstallPath\python.exe") {
            $results += [PSCustomObject]@{
                Component = "Python"
                Status    = "Successful"
                Comments  = "$(python --version)"
            }
        } else {
            $results += [PSCustomObject]@{
                Component = "Python"
                Status    = "Failed"
                Comments  = "Download from $pythonUrl"
            }
        }

         # Check if Git is installed
        if (Test-Path "$gitInstallPath") {
            $results += [PSCustomObject]@{
                Component = "Git"
                Status    = "Successful"
                Comments  = "$(git --version)"
            }
        } else {
            $results += [PSCustomObject]@{
                Component = "Git"
                Status    = "Failed"
                Comments  = "Download from $gitUrl"
            }
        }

        # Output the results as a table
        $results | Format-Table -AutoSize

        # Capture System Info 
        $systemInfo = Get-ComputerInfo | Out-String

        # Store the results in a debug.log file with additional lines
        $logContent = @(
            "Status of the installation:"
            $results | Format-Table -AutoSize | Out-String
            "------ System Info ------"
            $systemInfo
        )
        # Store the results in a debug.log file
        $logContent | Out-File -FilePath $logFilePath
    }
}


Function OGA_Setup {
    param(
        [string]$rootDirPath = "C:\WoS_AI"
        )
    process {
    	# Set the permission on PowerShell to execute the command. If prompted, accept and enter the desired input to provide execution permission.
	Set-ExecutionPolicy RemoteSigned 
        Set_Variables -rootDirPath $rootDirPath
        download_install_python
        Show-Progress -percentComplete 1 4
        download_script_license
        Show-Progress -percentComplete 2 4
        download_install_git
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine) + ";" + [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
        # Run Git LFS install after Git is installed
        git lfs install
        Show-Progress -percentComplete 3 4
        $SDX_OGA_ENV_Path = "$rootDirPath\$OGA_ENV_Path"
        # Check if virtual environment was created
        if (-Not (Test-Path -Path  $SDX_OGA_ENV_Path))
        {
           py -3.12 -m venv $SDX_OGA_ENV_Path
        }
        # Check if the virtual environment was created successfully
        if (Test-Path "$SDX_OGA_ENV_Path\Scripts\Activate.ps1") {
            # Activate the virtual environment
            & "$SDX_OGA_ENV_Path\Scripts\Activate.ps1"
            python -m pip install --upgrade pip
            pip install onnxruntime-genai==0.8.0
            pip install onnxruntime-qnn==1.22.0
        }
        Show-Progress -percentComplete 4 4
        Write-Output "***** Installation for Onnxruntime-Genai *****"
        
        Write-Output "To activate the environment, run:"
        Write-Output "`n`t& '$SDX_OGA_ENV_Path\Scripts\Activate.ps1'"

        Check_Setup -logFilePath "$debugFolder\OGA_Setup_Debug.log"
        Invoke-Command { & "powershell.exe" } -NoNewScope
    }
}

Function Activate_OGA_VENV {
    param ( 
        [string]$rootDirPath = "C:\WoS_AI" 
    )
    process {
        $SDX_OGA_ENV_Path = "$rootDirPath\$OGA_ENV_Path"
        $global:DIR_PATH = $rootDirPath
        cd "$DIR_PATH"
        & "$SDX_OGA_ENV_Path\Scripts\Activate.ps1"
    }  
}
