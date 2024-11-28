# WOS-AI
Welcome to our repository! Here, we provide setup scripts and artifacts for Windows on Snapdragon developer workflows(ONNX and QNN). 
The setup script should be executed in Powershell Administrative mode.

Run the following to assign the working directory to ``$DIR_PATH``, serves as the root working directory(by default C:\WoS_AI).
``` shell
$DIR_PATH = "C:\WoS_AI"
```

## For ONNX Runtime Setup(ORT):
Run the following command to download the ort_setup script.
``` shell
Invoke-WebRequest -O ort_setup.ps1 https://raw.githubusercontent.com/quic/wos-ai/refs/heads/main/Scripts/ort_setup.ps1
```
ORT-CPU EP Setup
``` shell
powershell -command "&{. .\ort_setup.ps1; ORT_CPU_Setup -rootDirPath $DIR_PATH}"
```
ORT-DML EP  Setup
``` shell
powershell -command "&{. .\ort_setup.ps1; ORT_DML_Setup -rootDirPath $DIR_PATH}"
```
ORT-QNN EP  Setup
``` shell
powershell -command "&{. .\ort_setup.ps1; ORT_QNN_Setup -rootDirPath $DIR_PATH}"
```
Hugging Face Optimum + ONNX-RT EP Setup
``` shell
powershell -command "&{. .\ort_setup.ps1; ORT_HF_Setup -rootDirPath $DIR_PATH}"
```

## For AI Engine Directsetup(QNN):
Run the following command to download the qnn_setup script.
``` shell
Invoke-WebRequest -O qnn_setup.ps1 https://raw.githubusercontent.com/quic/wos-ai/refs/heads/main/Scripts/qnn_setup.ps1
```
QNN Setup:
``` shell
powershell  -command "&{. .\qnn_setup.ps1; QNN_Setup -rootDirPath $DIR_PATH}"
```

##  License Information

This project is licensed under the [BSD-3-Clause License](https://spdx.org/licenses/BSD-3-Clause.html). For the full license text, please refer to the [LICENSE](LICENSE) file in this repository.
