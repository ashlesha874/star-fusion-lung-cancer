#!/bin/bash
#PBS -l select=1:ncpus=48:mem=100gb
#PBS -q short
#PBS -N zip_fastq
#PBS -l walltime=24:00:00

cd $PBS_O_WORKDIR

module load pigz/2.8

echo "Compressing all .fastq files..."
pigz *.fastq
echo "Compression complete."

# Generate jobs list for preprocessing
ls -1 *_1.fastq.gz | sed 's/_1.fastq.gz//' > config/jobs_fastq.txt
echo "jobs_fastq.txt generated with $(wc -l < config/jobs_fastq.txt) samples"
