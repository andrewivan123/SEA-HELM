#!/bin/bash

PARA_LAST_100B_CHECKPOINT_DIR="/scratch/e1583535/multiLingual-llm-project/outputs/evaluation-model-200K-bin-shard"
OUTPUT_DIR="/scratch/e1583535/multiLingual-llm-project/outputs/parallel-last-100B-checkpoints-evaluation"
CHECKPOINT_DIRS=(
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step2385-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step4770-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step7155-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step9540-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step11925-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step14310-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step16695-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step19080-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step21465-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step23850-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step26235-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step28620-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step31005-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step33390-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step35775-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step38160-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step40545-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step42930-unsharded-hf"
    # "${PARA_LAST_100B_CHECKPOINT_DIR}/step45315-unsharded-hf"
    "/scratch/e1583535/llm/nus-olmo/para-last-100B"
    "/scratch/e1583535/llm/nus-olmo/para-last-100B-step42931"
    "/scratch/e1583535/llm/nus-olmo/mixed-n10B"
    "/scratch/e1583535/llm/nus-olmo/para-first-n10B"
    "/scratch/e1583535/llm/nus-olmo/para-last-n10B-rerun"
    "/scratch/e1583535/llm/nus-olmo/para-replay-n10B"
)

TASK_AND_NUM_EXAMPLES=(
    # "translation_only 5"
    # "nlp_sentiment_nli_casual 5"
    # "qa_5shot 5"
    "qa_0shot 0"
    # "abssum_5shot 5"
    # "abssum_1shot 1"
    # "abssum_2shot 2"
)

for CHECKPOINT_DIR in "${CHECKPOINT_DIRS[@]}"; do
    echo "Evaluating checkpoint directory: $CHECKPOINT_DIR"

    # check if the directory exists
    if [ ! -d "$CHECKPOINT_DIR" ]; then
        echo "Directory $CHECKPOINT_DIR does not exist. Skipping..."
        continue
    fi

    for TASK_AND_NUM in "${TASK_AND_NUM_EXAMPLES[@]}"; do
        TASK=$(echo $TASK_AND_NUM | cut -d' ' -f1)
        NUM_EXAMPLES=$(echo $TASK_AND_NUM | cut -d' ' -f2)

        echo "Running evaluation for task: $TASK with $NUM_EXAMPLES examples"

        qsub -v CHECKPOINT_DIR="$CHECKPOINT_DIR",CHECKPOINT_NAME="$(basename $CHECKPOINT_DIR)",OUTPUT_DIR="$OUTPUT_DIR/$TASK",TASK="$TASK",NUM_EXAMPLES="$NUM_EXAMPLES" \
        -N seahelm_eval_$(basename $CHECKPOINT_DIR)_$TASK \
        /scratch/e1583535/SEA-HELM/mass_seahelm_evaluation.pbs

        sleep 10
    done

    sleep 10
done
