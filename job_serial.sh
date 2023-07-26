#!/bin/bash -l

################# Part-1 Slurm directives ####################
## Working dir
#SBATCH -D /users/jl2058/TiDE
## Environment variables
#SBATCH --export=ALL
## Output and Error Files
#SBATCH -o job-%j.output
#SBATCH -e job-%j.error
## Job name
#SBATCH -J TiDE_Train
## Run time: "hours:minutes:seconds", "days-hours"
#SBATCH --time=24:05:00
## Memory limit (in megabytes) 100GB
#SBATCH --mem=102400
## Specify partition
#SBATCH -p nodes

################# Part-2 Shell script ####################
#===============================
#  Activate Flight Environment
#-------------------------------
source "${flight_ROOT:-/opt/flight}"/etc/setup.sh

#===========================
#  Create results directory
#---------------------------
RESULTS_DIR="$(pwd)/${SLURM_JOB_NAME}-outputs/${SLURM_JOB_ID}"
echo "Your results will be stored in: $RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

#===============================
#  Application launch commands
#-------------------------------
# Customize this section to suit your needs.

echo "Executing job commands, current working directory is $(pwd)"

# REPLACE THE FOLLOWING WITH YOUR APPLICATION COMMANDS

echo "Hello, dmog" > $RESULTS_DIR/test.output
echo "This is an example job. It ran on `hostname -s` (as `whoami`)." >> $RESULTS_DIR/test.output
echo "Output file has been generated, please check $RESULTS_DIR/test.output"

for horizon in 96 192
  do
    python3 -u -m train \
    --transform=true \
    --layer_norm=true \
    --holiday=true \
    --dropout_rate=0.5 \
    --batch_size=512 \
    --hidden_size=512 \
    --num_layers=2 \
    --hist_len=720 \
    --pred_len=$horizon \
    --dataset=etth1 \
    --decoder_output_dim=32 \
    --final_decoder_hidden=16 \
    --num_split=1 \
    --learning_rate=0.000984894211777642 \
    --min_num_epochs=10 > $RESULTS_DIR/etth1_${horizon}.log
  done

  for horizon in 336 720
  do
    python3 -m train \
    --transform=true \
    --layer_norm=true \
    --holiday=true \
    --dropout_rate=0.3 \
    --batch_size=512 \
    --hidden_size=256 \
    --num_layers=2 \
    --hist_len=720 \
    --pred_len=$horizon \
    --dataset=etth1 \
    --decoder_output_dim=8 \
    --final_decoder_hidden=128 \
    --num_split=1 \
    --learning_rate=0.00003822279848104051 \
    --min_num_epochs=20 \
    --hist_len=336 > $RESULTS_DIR/etth1_${horizon}.log
  done

echo "finished"