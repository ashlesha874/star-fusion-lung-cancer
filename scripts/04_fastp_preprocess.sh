#!/bin/bash
#PBS -l select=1:ncpus=48:mem=120GB
#PBS -q short
#PBS -l walltime=24:00:00
#PBS -N qc_preprocess
#PBS -J 0-26

cd $PBS_O_WORKDIR
echo "Array index: $PBS_ARRAY_INDEX"

outdir_raw_qc="Raw_fastqc/"
trimmed_fastq="Trimmed_fastq"
outdir_trim_qc="Trimmed_fastqc/"

SAMPLE_LIST=($(grep -v '^$' config/jobs_fastq.txt))
SAMPLE=${SAMPLE_LIST[${PBS_ARRAY_INDEX}]}

module load fastqc/0.12.1 fastp/0.24 java/17
mkdir -p ${outdir_raw_qc} ${trimmed_fastq} ${outdir_trim_qc}

r1=${SAMPLE}_1.fastq.gz
r2=${SAMPLE}_2.fastq.gz

# Step 1: Raw QC
fastqc -t 16 ${r1} ${r2} -o ${outdir_raw_qc}

# Step 2: Trimming
fastp -i ${r1} -I ${r2} --thread 16 \
    -q 20 --length_required 50 \
    --cut_right --cut_right_window_size 4 \
    --cut_right_mean_quality 25 \
    --detect_adapter_for_pe \
    --trim_poly_g --trim_poly_x \
    -o ${trimmed_fastq}/${SAMPLE}_R1_paired.fastq.gz \
    -O ${trimmed_fastq}/${SAMPLE}_R2_paired.fastq.gz \
    --unpaired1 ${trimmed_fastq}/${SAMPLE}_R1_unpaired.fastq.gz \
    --unpaired2 ${trimmed_fastq}/${SAMPLE}_R2_unpaired.fastq.gz \
    --failed_out ${trimmed_fastq}/${SAMPLE}_failed.txt \
    -h ${trimmed_fastq}/${SAMPLE}_fastp.html

# Step 3: Post-trim QC
fastqc -t 16 \
    ${trimmed_fastq}/${SAMPLE}_R1_paired.fastq.gz \
    ${trimmed_fastq}/${SAMPLE}_R2_paired.fastq.gz \
    -o ${outdir_trim_qc}

echo "Finished: ${SAMPLE}"
