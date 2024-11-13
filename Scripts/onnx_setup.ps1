# =============================================================================
#
# Copyright (c) 2024, Qualcomm Innovation Center, Inc. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# =============================================================================

<#  The onnx_setup.ps1 PowerShell script automates the setup of various ONNX Runtime (ORT) Execution Providers (EP) by downloading and installing necessary components.
    Such as Python, ONNX models, required artifacts, and redistributable packages. Separate functions are defined for each ORT EP. 
    Each function checks for the existence of a virtual environment at a rootDirPath and creates one if it doesn’t exist. 
    They then activate the virtual environment, upgrade pip, and install the required packages: onnxruntime for CPU EP, onnxruntime-directml for DML EP, onnxruntime-qnn for QNN EP, and optimum[onnxruntime] for Huggingface tutorials. 
    It is not necessary to install files for all ORT EP, users are free to try any one EP or all EPs based on their needs, and the script will handle the installation accordingly. After installation, a success message will be shown.
    The ORT_QNN_setup function also copies specific DLL files to the rootDirPath, which are needed to run the model on NPU. 
    By default, $rootDirPath is set to C:\Qualcomm_AI, where all files will be downloaded and the Python environment will be created.  
	
    Note: Users can change this path to another location if desired.
#>

# Set the permission on PowerShell to execute the command. If prompted, accept and enter the desired input to provide execution permission.
Set-ExecutionPolicy RemoteSigned 

# Define URLs for dependencies

<#  For Python 3.12.6 dependency:
    - Any version of Python can be used for AMD architecture.
    - For ARM architecture, install Python 3.11.x only. ORT QNN EP supports only Python ARM or AMD installations.
    - Other ORT EPs require the AMD version of Python.
    - To use ORT QNN EP on ARM, it is advised to create two Python environments: one for pre- and post-processing, and a second ARM environment for execution.
    Note: Python ARM has limitations with other dependencies such as torch, onnx, etc.
    Therefore, we recommend using the AMD version to avoid these issues.
#>
$pythonUrl = "https://www.python.org/ftp/python/3.12.6/python-3.12.6-amd64.exe"

<#  Artifacts for tutorials, including:
    - kitten.jpg: Test image for prediction.
    - qc_utils.py: Utility file for preprocessing images and postprocessing to get top 5 predictions.
    - imagenet_classes.txt: Image label file for post-processing.
#>

# Define the URL of the file to download
$kittenUrl = "https://raw.githubusercontent.com/quic/wos-ai/refs/heads/main/Artifacts/kitten.jpg"
$qc_utilsUrl = "https://raw.githubusercontent.com/quic/wos-ai/refs/heads/main/Artifacts/qc_utils.py"
$imagenetLabelsUrl = "https://raw.githubusercontent.com/quic/wos-ai/refs/heads/main/Artifacts/imagenet_classes.txt"


# ONNX model file for image prediction used in tutorials.
$modelUrl =  "https://qaihub-public-assets.s3.us-west-2.amazonaws.com/apidoc/mobilenet_v2.onnx"

# URL for downloading the Visual Studio Redistributable for ARM64. Visual studio is used during model exection on HTP(NPU) backend.
$vsRedistributableUrl = "https://aka.ms/vs/17/release/vc_redist.arm64.exe"

# Define working directory where all files will be stored and used in the tutorial. Users can change this path to their desired location.
$rootDirPath = "C:\Qualcomm_AI"

# Define download directory inside the working directory for downloading all dependency files and SDK.
$downloadDirPath = "$rootDirPath\Downloaded_file"

# Define the path where the installer will be downloaded.
$pythonDownloaderPath = "$downloadDirPath\python-3.12.6-amd64.exe" 
$vsRedistDownloadPath = "$downloadDirPath\vc_redist.arm64.exe"

# Retrieves the value of the Username
$username =  (Get-ChildItem Env:\Username).value

# Define the python installation path.
$pythonInstallPath = "C:\Users\$username\AppData\Local\Programs\Python\Python312"
$pythonScriptsPath = $pythonPath+"\Scripts"

# Define the mobilenet model download path.
$modelFilePath = "$rootDirPath\mobilenet_v2.onnx"

# Define the artifacts download path.
$kittenPath = "$rootDirPath\kitten.jpg"
$qc_utilsPath = "$rootDirPath\qc_utils.py"
$imagenetLabelsPath = "$rootDirPath\imagenet_classes.txt"

<#  Define the Python environment paths.
    Each tutorial section will have its own individual Python environment:

    - ORT CPU EP: Uses SDX_ORT_CPU_ENV, which has specific Python package dependencies.
    - ORT DML EP: Uses SDX_ORT_CPU_ENV, which has specific Python package dependencies.
    - ORT QNN EP: Uses SDX_ORT_QNN_ENV, which has specific Python package dependencies.
    - Hugging Face Optimum: Uses SDX_HF_ENV, which has specific Python package dependencies.

    Note: Each section has dependencies that cannot be used in conjunction with other Python packages.
    For example, ORT QNN EP and ORT CPU EP cannot install packages in the same Python environment.
    Users are advised to create separate Python environments for each case.

    Define the paths for each environment
#>
$SDX_ORT_CPU_ENV_Path = "$rootDirPath\SDX_ORT_CPU_ENV"
$SDX_ORT_DML_ENV_Path = "$rootDirPath\SDX_ORT_DML_ENV"
$SDX_ORT_HF_ENV_Path  = "$rootDirPath\SDX_ORT_HF_ENV"
$SDX_ORT_QNN_ENV_Path = "$rootDirPath\SDX_ORT_QNN_ENV"



# Create the Root folder if it doesn't exist
if (-Not (Test-Path $downloadDirPath)) {
    New-Item -ItemType Directory -Path $downloadDirPath
}


############################ Function ##################################

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

Function install-vsRedistributable
{
    param()
    process{
        Start-Process -FilePath $vsRedistDownloadPath -ArgumentList "/install", "/quiet", "/norestart" -Wait 
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
            return $true
        } 
        else {
            Write-Output "Python installation failed."
            return $false
        }
        
    }
}

Function download_artifacts{
    param ()
    process{
        # Kitten image for mobilenet example
        if(Test-Path $kittenPath){
            Write-Output "Kitten image is already downloaded at : $kittenPath"
        }
        else{
            $result = download_file -url $kittenUrl -downloadfile $kittenPath
            if($result){
                Write-Output "Kitten image is downloaded at : $kittenPath"
            }
            else{
                Write-Output "Kitten image download failed. Download from $kittenUrl"
            }
        }
        # qc_utils for pre and post processing for the mobilenet 
        if(Test-Path $qc_utilsPath){
            Write-Output "qc_utils.py is already downloaded at : $qc_utilsPath"
        }
        else{
            $result = download_file -url $qc_utilsUrl -downloadfile $qc_utilsPath
            if($result){
                Write-Output "qc_utils.py is downloaded at : $qc_utilsPath"
            }
            else{
                Write-Output "qc_utils.py download failed. Download from $qc_utilsUrl"
            }
        }
        # Imagenet labels
        if(Test-Path $imagenetLabelsPath){
            Write-Output "Imagenet labels is already downloaded at : $imagenetLabelsPath"
        }
        else{
            $result = download_file -url $imagenetLabelsUrl -downloadfile $imagenetLabelsPath
            if($result){
                Write-Output "Imagenet labels is downloaded at : $imagenetLabelsPath"
            }
            else{
                Write-Output "Imagenet labels download failed. Download from $imagenetLabelsUrl"
            }
        }
    }
}

Function download_install_python {
    param()
    process {
        # Download the python file 
        if (Test-Path $pythonDownloaderPath) {
            Write-Output "Python file is already downloaded at : $pythonDownloaderPath"
        }
        else {
            Write-Output "Downloading python file ..." 
            $result = download_file -url $pythonUrl -downloadfile $pythonDownloaderPath
            if ($result) {
                Write-Output "Python File is downloaded at : $pythonDownloaderPath" 
            } 
            else {
                Write-Output "Python download failed. Download the python file from :  $pythonUrl" 
            }
        }
        # Install python
        if (Test-Path "$pythonInstallPath\python.exe") {
            Write-Output "Python is already installed."
        }
        else {
            Write-Output "installing python..."
            if (install-python) {
                Write-Output "Python 3.12.6 is installed successfully." 
            }
            else{
                Write-Output "Python installation failed.. Please installed python 3.12.6 from : $pythonDownloaderPath"  
            }
        }
    }
}

Function download_onnxmodel {
    param()
    process {
        # Download Model file 
        if (Test-Path $modelFilePath) {
            Write-Output "ONNX File is already present at : $modelFilePath"
        }
        else {
            Write-Output "Downloading onnx model ..." 
            $result = download_file -url $modelUrl -downloadfile $modelFilePath
            if ($result) {
                Write-Output "Onnx File is downloaded at : $modelFilePath" 
            } 
            else {
                Write-Output "Onnx download failed. Download the onnx file from :  $modelUrl" 
            }
        }
    }
}


Function download_install_redistributable {
    param()
    process {
        # Download VS Redistributable file
        if (Test-Path $vsRedistDownloadPath) {
            Write-Output "VS-Redistributable is already present at : $vsRedistDownloadPath"
        }
        else {
            Write-Output "Downloading VS-Redistributable..." 
            $result = download_file -url $vsRedistributableUrl -downloadfile $vsRedistDownloadPath
            if ($result) {
                Write-Output "VS-Redistributable File is downloaded at : $vsRedistDownloadPath" 
            } 
            else{
                Write-Output "VS-Redistributable download failed.... Download the VS-Redistributable file from :  $vsRedistributableUrl" 
            }
        }
        # Install VS-Redistributable
        if (Test-Path "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\arm64") {
            Write-Output "VS-Redistributable is already installed."
        }
        else {
            Write-Output "installing VS-Redistributable..."
            if (install-vsRedistributable) {
                Write-Output "VS-Redistributable is installed successfully." 
            }
            else {
                Write-Output "VS-Redistributable installation failed... from : $vsRedistDownloadPath" 
            }
        }
    }
}


############################## Main code ##################################

Function ORT_CPU_Setup {
    param()
    process {
        download_install_python
        download_onnxmodel
        download_artifacts
        download_install_redistributable
        # Check if virtual environment was created
        if (-Not (Test-Path -Path  $SDX_ORT_CPU_ENV_Path))
        {
           py -3.12 -m venv $SDX_ORT_CPU_ENV_Path
        }
        # Check if the virtual environment was created successfully
        if (Test-Path "$SDX_ORT_CPU_ENV_Path\Scripts\Activate.ps1") {
            # Activate the virtual environment
            & "$SDX_ORT_CPU_ENV_Path\Scripts\Activate.ps1"
            python -m pip install --upgrade pip
            pip install onnxruntime
            pip install pillow
            deactivate
        } 
        Write-Output "***** Installation successful for ORT-CPU *****"
    }
}

Function ORT_DML_Setup {
    param()
    process {
        download_install_python
        download_onnxmodel
        download_artifacts
        download_install_redistributable
        # Check if virtual environment was created
        if (-Not (Test-Path -Path $SDX_ORT_DML_ENV_Path))
        {
            py -3.12 -m venv $SDX_ORT_DML_ENV_Path
        }
        # Check if the virtual environment was created successfully
        if (Test-Path "$SDX_ORT_DML_ENV_Path\Scripts\Activate.ps1") {
            # Activate the virtual environment
            & "$SDX_ORT_DML_ENV_Path\Scripts\Activate.ps1"
            python -m pip install --upgrade pip
            pip install onnxruntime-directml
            pip install pillow
            deactivate
        } 
        Write-Output "***** Installation successful for ORT-DML *****"
    }
}

Function ORT_HF_Setup {
    param()
    process {
        download_install_python
        download_install_redistributable
        # Check if virtual environment was created
        if (-Not (Test-Path -Path $SDX_ORT_HF_ENV_Path))
        {
            py -3.12 -m venv $SDX_ORT_HF_ENV_Path
        }
        # Check if the virtual environment was created successfully
        if (Test-Path "$SDX_ORT_HF_ENV_Path\Scripts\Activate.ps1") {
            # Activate the virtual environment
            & "$SDX_ORT_HF_ENV_Path\Scripts\Activate.ps1"
            python -m pip install --upgrade pip
            pip install optimum[onnxruntime]
            pip install onnxruntime-directml
            pip install pillow 
            deactivate
        }
        Write-Output "***** Installation successful for Hugging Face Optimum + ONNX-RT *****"
    }
}

Function ORT_QNN_Setup {
    param()
    process {
        download_install_python
        download_onnxmodel
        download_artifacts
        download_install_redistributable
        # Check if virtual environment was created
        if (-Not (Test-Path -Path $SDX_ORT_QNN_ENV_Path))
        {
            py -3.12 -m venv $SDX_ORT_QNN_ENV_Path
        }
        # Check if the virtual environment was created successfully
        if (Test-Path "$SDX_ORT_QNN_ENV_Path\Scripts\Activate.ps1") {
            # Activate the virtual environment
            & "$SDX_ORT_QNN_ENV_Path\Scripts\Activate.ps1"
            python -m pip install --upgrade pip
            pip install onnxruntime-qnn
            pip install pillow
            deactivate
        }
        $qnnEnvFilePath
        copy $SDX_ORT_QNN_ENV_Path\Lib\site-packages\onnxruntime\capi\QnnHtp.dll $rootDirPath
        copy $SDX_ORT_QNN_ENV_Path\Lib\site-packages\onnxruntime\capi\QnnCpu.dll $rootDirPath
        Write-Output "***** Installation successful for ONNX-QNN *****"
    }
}

