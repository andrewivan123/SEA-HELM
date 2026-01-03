#!/bin/bash

# CHECKPOINT_DIRS=(
#     "/scratch/e1583535/llm/nus-olmo/mixed-n10B"
#     "/scratch/e1583535/llm/nus-olmo/para-first-n10B"
#     "/scratch/e1583535/llm/nus-olmo/para-last-n10B-rerun"
#     "/scratch/e1583535/llm/nus-olmo/multi-uniform-n10B-SEA-7.5_replay-2.5-checkpoints/step4770-unsharded-hf"
#     "/scratch/e1583535/llm/nus-olmo/multi-para-replace-n10B-7.5_replay-2.5-checkpoints/step4770-unsharded-hf"
#     "/scratch/e1583535/llm/nus-olmo/para-replay-n10B"
#     "/scratch/e1583535/llm/nus-olmo/para-only-34B8"
#     "/scratch/e1583535/llm/nus-olmo/para-last-100B"
#     "/scratch/e1583535/llm/nus-olmo/para-only-7B-34B-checkpoints/step8290-unsharded-hf"
#     "aisingapore/Llama-SEA-LION-v3.5-8B-R"
#     # "swiss-ai/Apertus-8B-2509"
# )

# non-base-model Checkpoint
CHECKPOINT_DIRS=(
    "/scratch/e1583592/code/OLMo/workspace/checkpoints/aligned-bpe-cpt-v2/n7.6B_para-5.2_replay-2.4-aligned-bpe-1792-add_id_km_lo_ms_my_ta_th_tl_vi_zh_qwen3_v3/step3636-filtered-mapping-unsharded"
    # "/scratch/e1583592/code/OLMo/workspace/checkpoints/aligned-bpe-cpt-v2/para-last-n10B-rerun"
)

TASK_AND_NUM_EXAMPLES=(
    "translation_only 5"
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

        # set output_dir as parent of checkpoint dir
        OUTPUT_DIR=$(dirname "$CHECKPOINT_DIR")

        qsub -v CHECKPOINT_DIR="$CHECKPOINT_DIR",CHECKPOINT_NAME="$(basename $CHECKPOINT_DIR)",TASK="$TASK",NUM_EXAMPLES="$NUM_EXAMPLES" \
        -N seahelm_eval_$(basename $CHECKPOINT_DIR)_$TASK \
        mass_seahelm_evaluation.pbs

        sleep 10
    done

    sleep 10
done
