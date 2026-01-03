#!/bin/bash

# Configuration
HF_HOME="/home/ec2-user/efs/huggingface"

# base-model checkpoints
if [ $# -gt 0 ]; then
    CHECKPOINT_DIRS=("$@")
    echo "Using CHECKPOINT_DIRS from command line arguments" | tee -a $LOG_FILE
else
    CHECKPOINT_DIRS=(
        "/home/ec2-user/efs/OLMo/workspace/checkpoints/aligned-bpe-cpt-v2/n7.6B_para-5.1_replay-2.5-aligned-bpe-1792-add_id_km_lo_ms_my_ta_th_tl_vi_zh_qwen3_v4/step3595-unsharded"
    )
    echo "Using default CHECKPOINT_DIRS" | tee -a $LOG_FILE
fi

TASK_AND_NUM_EXAMPLES=(
    "translation_only 5"
    # "nlp_sentiment_nli_casual 5"
    # "qa_5shot 5"
    # "qa_0shot 0"
    # "abssum_5shot 5"
    # "abssum_1shot 1"
    # "abssum_2shot 2"
)

# Function to run evaluation
run_evaluation() {
    local CHECKPOINT_DIR=$1
    local CHECKPOINT_NAME=$2
    local TASK=$3
    local NUM_EXAMPLES=$4
    local LOG_FILE=$5

    echo "========================================" | tee -a "$LOG_FILE"
    echo "Starting evaluation at $(date)" | tee -a "$LOG_FILE"
    echo "Checkpoint: $CHECKPOINT_DIR" | tee -a "$LOG_FILE"
    echo "Task: $TASK" | tee -a "$LOG_FILE"
    echo "Num examples: $NUM_EXAMPLES" | tee -a "$LOG_FILE"
    echo "Running on host: $(hostname)" | tee -a "$LOG_FILE"
    echo "GPU info:" | tee -a "$LOG_FILE"
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits 2>&1 | tee -a "$LOG_FILE" || echo "No GPU detected" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"

    # Run Python evaluation directly
    export HF_HOME="$HF_HOME"
    python /home/ec2-user/efs/SEA-HELM/seahelm_evaluation.py \
        --tasks "$TASK" \
        --output_dir "$CHECKPOINT_DIR" \
        --model_type vllm \
        --model_name "$CHECKPOINT_DIR" \
        --model_args "enable_prefix_caching=True,tensor_parallel_size=8" \
        --is_base_model \
        --use_custom_aligned_bpe_tokenizer \
        --num_in_context_examples "$NUM_EXAMPLES" | tee -a "$LOG_FILE"

    local EXIT_CODE=$?
    echo "========================================" | tee -a "$LOG_FILE"
    echo "Evaluation completed at $(date)" | tee -a "$LOG_FILE"
    echo "Exit code: $EXIT_CODE" | tee -a "$LOG_FILE"
    echo "========================================" | tee -a "$LOG_FILE"

    return $EXIT_CODE
}

# Main loop
for CHECKPOINT_DIR in "${CHECKPOINT_DIRS[@]}"; do
    echo "Evaluating checkpoint directory: $CHECKPOINT_DIR"

    # check if the directory exists (skip HuggingFace model names)
    if [[ "$CHECKPOINT_DIR" == *"/"* ]] && [[ "$CHECKPOINT_DIR" != *"/"*"/"* ]] || [[ ! -d "$CHECKPOINT_DIR" && "$CHECKPOINT_DIR" == *"/"*"/"* ]]; then
        # This is likely a HuggingFace model name (contains only one /)
        echo "Using HuggingFace model: $CHECKPOINT_DIR"
    elif [ ! -d "$CHECKPOINT_DIR" ]; then
        echo "Directory $CHECKPOINT_DIR does not exist. Skipping..."
        continue
    fi

    for TASK_AND_NUM in "${TASK_AND_NUM_EXAMPLES[@]}"; do
        TASK=$(echo $TASK_AND_NUM | cut -d' ' -f1)
        NUM_EXAMPLES=$(echo $TASK_AND_NUM | cut -d' ' -f2)

        echo "Running evaluation for task: $TASK with $NUM_EXAMPLES examples"

        CHECKPOINT_NAME=$(basename "$CHECKPOINT_DIR")
        
        # Create log file path (merged stdout and stderr)
        LOG_FILE="$CHECKPOINT_DIR/log-$CHECKPOINT_NAME-$TASK-$(date +%Y%m%d-%H%M%S).log"
        
        # Ensure the directory exists
        mkdir -p "$(dirname "$LOG_FILE")"

        # Run evaluation
        run_evaluation "$CHECKPOINT_DIR" "$CHECKPOINT_NAME" "$TASK" "$NUM_EXAMPLES" "$LOG_FILE"

        echo "Log saved to: $LOG_FILE"
        echo ""
        
        # Optional: add a small delay between tasks
        sleep 2
    done

    echo ""
    sleep 2
done

echo "All evaluations completed!"
