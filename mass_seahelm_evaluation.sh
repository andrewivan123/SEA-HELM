#!/bin/bash

PARA_LAST_100B_CHECKPOINT_DIR="/scratch/e1583535/llm/nus-olmo/para-last-100B-checkpoints"
OUTPUT_DIR="/scratch/e1583535/outputs/seahelm/new-tl-translation-eval"
CHECKPOINT_DIRS=(
    "/scratch/e1583535/llm/nus-olmo/para-only-34B8"
    "/scratch/e1583535/llm/nus-olmo/para-replay-n10B"
    "/scratch/e1583535/llm/nus-olmo/para-only-7B-34B-checkpoints/step2385-unsharded-hf"
    "/scratch/e1583535/llm/nus-olmo/para-only-7B-34B-checkpoints/step6201-unsharded-hf"
    "/scratch/e1583535/llm/nus-olmo/para-only-7B-34B-checkpoints/step8290-unsharded-hf"
    "aisingapore/Llama-SEA-LION-v3.5-8B-R"
    "sail/Sailor2-L-1B"
    "SeaLLMs/SeaLLMs-v3-1.5B"
)

TASK_AND_NUM_EXAMPLES=(
    "translation_tl 5"
    # "nlp_sentiment_nli_casual 5"
    # "qa_5shot 5"
    # "qa_0shot 0"
    # "abssum_5shot 5"
    # "abssum_1shot 1"
    # "abssum_2shot 2"
)

for CHECKPOINT_DIR in "${CHECKPOINT_DIRS[@]}"; do
    echo "Evaluating checkpoint directory: $CHECKPOINT_DIR"

    # check if the directory exists
    # if [ ! -d "$CHECKPOINT_DIR" ]; then
    #     echo "Directory $CHECKPOINT_DIR does not exist. Skipping..."
    #     continue
    # fi

    for TASK_AND_NUM in "${TASK_AND_NUM_EXAMPLES[@]}"; do
        TASK=$(echo $TASK_AND_NUM | cut -d' ' -f1)
        NUM_EXAMPLES=$(echo $TASK_AND_NUM | cut -d' ' -f2)

        echo "Running evaluation for task: $TASK with $NUM_EXAMPLES examples"

        qsub -v CHECKPOINT_DIR="$CHECKPOINT_DIR",CHECKPOINT_NAME="$(basename $CHECKPOINT_DIR)",OUTPUT_DIR="$OUTPUT_DIR/$TASK",TASK="$TASK",NUM_EXAMPLES="$NUM_EXAMPLES" \
        -N seahelm_eval_$(basename $CHECKPOINT_DIR)_$TASK \
        /scratch/e1583535/SEA-HELM/mass_seahelm_evaluation.pbs

        sleep 20
    done

    sleep 20
done
