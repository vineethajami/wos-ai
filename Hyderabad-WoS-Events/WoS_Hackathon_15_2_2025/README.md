# Hyderabad / WoS Workshop
## Developing Applications on the Windows on Snapdragon Platform 
A single day workshop for developers to build AI applications. The goal is to create sample AI/ML applications using Qualcomm WoS platfom and capture feedbacks based on your experience.

## Scope 
### Overview 
- If you have not done so, [set up your Qualcomm ID](https://myaccount.qualcomm.com/signup), confirm your email .This gives you access to the documentation and Qualcomm tools.
- Work on the task assigned to you. Please provide feedback as you navigate Qualcomm documentation in the excel sheet provided to you .
- Update the Feedback form (Excel) as you follow your workflow. Write down times you got stuck, confused and, if applicable, how you resolved it.

## Introduction and Setup 
### Introduction  
- [Windows on Snapdragon](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/welcome.html)
- [AI Stack](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/ai-overview.html)

### Setup
- Laptop setup: You will be provided a Windows Laptop which has Qualcomm X Elite chipset
  
## AI workflow:
#### AI App Development Overview
- [AI App Development](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/ai-app-development.html)
- [AI Developer Workflow](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/ai-dev-workflow.html) 

### Task 1.1: Setup ONNX runtime and run  ORT CPU tutorial.
The goal is to download and setup ONNX Runtime for CPU.
#### Reference 
- [ONNXRuntime CPU EP ](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/ort-cpu-ep.html)  
#### Testing and Feedback  
- Try out the example and provide your feedback on this Section.

### Task 1.2: Setup ONNX runtime and run  ORT QNN EP – CPU backend  tutorial.
The goal is to download and setup ONNX Runtime for QNN CPU EP.
#### Reference
 - [ONNXRuntime QNN CPU EP](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/ort-qnn-ep.html) 
#### Testing and Feedback  
- Try out the example and provide your feedback on this section.
- Please refer on the Note at point #3

### Task 1.3: Setup ONNX runtime and run  ORT DML EP – GPU  backend  tutorial.
The goal is to download and setup ONNX Runtime for DML GPU EP.
#### Reference 
 - [ONNXRuntime DML GPU EP](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/ort-dml.html)   
#### Testing and Feedback  
- Try out the example and provide your feedback on this section.

### Task 1.4: Setup ONNX runtime and run  ORT QNN EP – HTP  backend  tutorial.
The goal is to download and setup ONNX Runtime for QNN HTP EP.
#### References
- [ONNXRuntime QNN HTP EP](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/ort-qnn-ep.html)
#### Testing and Feedback 
- Try out the example and provide your feedback on this section.

### Task 2.1: Develop an AI based application using ORT – Use any model from AI Hub.
The goal is to Develop an AI application using the ORT Setup which we did in previous steps. We can use any of the model which is availble on Qualcomm AIHub.
#### References
- [AIHub Models](https://aihub.qualcomm.com/compute/models)
- Please select Model Precision as Floating point.
- ![image](https://github.com/user-attachments/assets/4f5e8dd5-293c-406e-a3ef-a07539cc071f)
- Each Model Page will have the option to download the model. Please click Download Model -> ONNX Runtime (Choose runtime) -> Download Model.
- For more details, Model Page will have Model Repository where we have Model details, Export scripts, Demo script for E2E model Execution with pytorch. [Example](https://github.com/quic/ai-hub-models/tree/main/qai_hub_models/models/deeplabv3_plus_mobilenet_quantized)
#### Testing and Feedback 
- Try out the models from AIHub, Develop Pre & post processing and create a E2E usecase and provide your feedback on documentation, AIHub Usage etc.

### Task 2.2: Develop an AI based application using ORT – Bring your Own Model(BYOM), Open Source.
The goal is to Develop an AI application using the ORT Setup which we did in previous steps. We can use any open source model.
#### References
- [ONNXRuntime QNN HTP Sample APP](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/ort-qnn-ep.html#ort-qnn-tutorial)
#### Testing and Feedback 
- Create a E2E usecase with the open source model and provide your feedback.

### Task 3: Develop a GenAI Usecase.
The goal is to Develop a GenAI application/Usecase using LM Studio, LLAMA_CPP, MLC_LLM
#### References
- [LM Studio](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/run-lm-studio.html)
- [LLAMA.CPP](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/run-llama-cpp.html)
- [MLC LLM](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/gpu-mlc-llm-usage-guide.html)
#### Testing and Feedback 
- Create a E2E usecase/application/chatbot with any LLM model and provide your feedback.

### Task 4: Qualcomm AI Engine Direct(QNN).
The goal is to go over the document, explore all the steps and try 3 to 5 models from AIHUB and experiment.
#### References
- [AI Engine Direct(QNN)](https://docs.qualcomm.com/bundle/publicresource/topics/80-62010-1/qnn.html)
- [AIHub Models](https://aihub.qualcomm.com/models?isQuantized=false)
#### Testing and Feedback 
- Try out the steps mentioned in the document and try the same steps with AIHub / Opensource models and provide your feedback.
