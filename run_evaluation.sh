#!/bin/bash

# Add a list of models (either local path or HuggingFace model id) to be evaluated
MODEL="/localhome/tansang/llm/aisingapore/Gemma-SEA-LION-v4-27B"

OUTPUT="results"

PYTHON_SCRIPT="seahelm_evaluation.py"

IS_BASE_MODEL=true
RERUN_CACHED_RESULTS=false

if [ $IS_BASE_MODEL == "true" ]; then
    BASE_MODEL="--base_model"
else
    BASE_MODEL=""
fi

if [ $RERUN_CACHED_RESULTS = true ]; then
    RERUN_RESULTS="--rerun_cached_results"
else
    RERUN_RESULTS=""
fi

# Create output dir at ${result_dir}/<exp name>/<timestamp>
output_dir="${OUTPUT}/$(echo ${MODEL} | awk -F/ '{print $(NF-1)}')"
mkdir -p "${output_dir}"
echo "Output directory: ${output_dir}"

PYTHON_SCRIPT="seahelm_evaluation.py"
export LITELLM_LOG="ERROR"

if [ $IS_BASE_MODEL == "true" ]; then
    BASE_MODEL="--is_base_model"
else
    BASE_MODEL=""
fi

if [ $RERUN_CACHED_RESULTS = true ]; then
    RERUN_RESULTS="--rerun_cached_results"
else
    RERUN_RESULTS=""
fi

seahelm_eval_args=(
    "python $PYTHON_SCRIPT"
    --tasks translation_only
    --output_dir $output_dir
    --model_name $MODEL
    --model_type vllm
    --model_args "dtype=bfloat16,enable_prefix_caching=True,tensor_parallel_size=4" 
    $BASE_MODEL
    $RERUN_RESULTS
)

seahelm_eval_cmd="${seahelm_eval_args[@]}"

$seahelm_eval_cmd