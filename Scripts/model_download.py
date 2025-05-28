# =============================================================================
#
# Copyright (c) 2024, Qualcomm Innovation Center, Inc. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# =============================================================================

# Use a pipeline as a high-level helper
from transformers import pipeline
pipe = pipeline("text-generation", model="meta-llama/Meta-Llama-3-8B-Instruct")
# Load model directly
from transformers import AutoTokenizer, AutoModelForCausalLM
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Meta-Llama-3-8B-Instruct")
model = AutoModelForCausalLM.from_pretrained("meta-llama/Meta-Llama-3-8B-Instruct")
import os
os.makedirs("llama_model")
tokenizer.save_pretrained("llama_model/")
model.save_pretrained("llama_model/")
