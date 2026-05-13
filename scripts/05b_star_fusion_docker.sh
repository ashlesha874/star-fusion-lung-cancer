#!/bin/bash
#PBS -l select=1:ncpus=48:mem=120GB
#PBS -q short
#PBS -l walltime=24:00:00
#PBS -N star-fusion-docker
#PBS -J 0-49

cd $PBS_O_WORKDIR

SAMPLE_LIST=($(grep -v '^$' config/jobs_fusion.txt))
SAMPLE=${SAMPLE_LIST[${PBS_ARRAY_INDEX}]}

# Use Docker image to avoid GLIBCXX dependency issues
# Run this if 05_star_fusion.sh fails with GLIBCXX errors
TRIMMED_DIR=$(pwd)/Trimmed_fastq
GENOME_LIB="/home/compbio/ref/ctat_GRCh38_gencode_v37/ctat_genome_lib_build_dir"

docker run --rm \
    -v "${TRIMMED_DIR}":/workdir \
    -v "${GENOME_LIB}":/ref \
    ln1:5000/trinityctat/starfusion \
    STAR-Fusion \
    --left_fq /workdir/${SAMPLE}_R1_paired.fastq.gz \
    --right_fq /workdir/${SAMPLE}_R2_paired.fastq.gz \
    --genome_lib_dir /ref \
    --examine_coding_effect \
    --FusionInspector validate \
    --output_dir /workdir/Fusion_results/${SAMPLE}

echo "Finished: ${SAMPLE}"
