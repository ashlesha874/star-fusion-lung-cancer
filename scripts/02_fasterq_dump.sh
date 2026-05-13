#!/bin/bash
#PBS -l select=1:ncpus=48:mem=100gb
#PBS -q short
#PBS -N fasterq
#PBS -l walltime=24:00:00
#PBS -J 0-26

cd $PBS_O_WORKDIR
echo "Array index: $PBS_ARRAY_INDEX"

module load sratoolkit/3.1.1

SAMPLE_LIST=($(grep -v '^$' config/jobs_sra.txt))
SAMPLE=${SAMPLE_LIST[${PBS_ARRAY_INDEX}]}

echo "Processing: $SAMPLE"
fasterq-dump --split-3 "${SAMPLE}"
echo "Done: $SAMPLE"
