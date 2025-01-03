# Sample Application: ONNX Model Cpp Runner

## Overview
The **ONNX Model Cpp Runner** is a command-line application using CPP that executes ONNX models using different backends (CPU, HTP, or QNN). <br/><br/> 1) We have added a utils file to check for the availability of the NPU, if it is present we will create QNN Context binary and execute on HTP otherwise model will be executed on CPU. <br/>
2) We are using dxcore library & apis for the getting the NPU info, to compile the project need to link dxcore.lib file from C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\arm64, it is added in cmake as well. dxcore lib is part of the Windows SDK package.
<br/> <br/>

*Note: preprocessing and postprocessing are independent from model execution and taken care by user. we have used onnxruntime-qnn 1.20.1 for this example*

## Prerequisites
Before using the application, ensure that you have the following:


1. **ONNX Runtime from nuget**:  
   - Onnxruntime-qnn pre-build can be downloaded from [here](https://www.nuget.org/packages/Microsoft.ML.OnnxRuntime.QNN).
2. **Visual studio 2022**
3. **Python**

## Setup Workflow:
1. **Clone the repo**
    ```
    git clone https://github.com/quic/wos-ai/apps/ORT_Sample_app_with_NPU_Availabilty_Check.git

    cd ORT_Sample_app_with_NPU_Availabilty_Check
    ```
2. **Build the Application**: Need to build in Developer powershell for VS 2022

    ```
    .\run_qnn_ep_sample.bat C:\Users\Downloads\microsoft.ml.onnxruntime.qnn.1.20.1\build\native C:\Users\Downloads\microsoft.ml.onnxruntime.qnn.1.20.1\runtimes\win-arm64\native
    ```
*Note : Path `<PATH TO microsoft.ml.onnxruntime.qnn.1.20.1>` is the path of onnxruntime pre-build download. For more building [help](https://onnxruntime.ai/docs/build/eps.html#qnn),[sample app](https://github.com/microsoft/onnxruntime-inference-examples/tree/main/c_cxx/QNN_EP/mobilenetv2_classification)  & [QNN Execution Provider](https://onnxruntime.ai/docs/execution-providers/QNN-ExecutionProvider.html)*


3. **Run the application**:
    ```
    cd .\build\Release
    ./qnn_ep_sample --cpu mobilenetv2-12_shape.onnx kitten_input.raw 
    ./qnn_ep_sample --htp mobilenetv2-12_quant_shape.onnx kitten_input.raw
    ./qnn_ep_sample --qnn .\mobilenetv2-12_quant_shape.onnx_ctx.onnx kitten_input.raw
    ```

## Usage
    ```
    qnn_ep_sample.exe -h 
    ```
