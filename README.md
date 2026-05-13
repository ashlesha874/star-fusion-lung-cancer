# STAR-Fusion lung cancer pipeline

![STAR-Fusion](https://img.shields.io/badge/STAR--Fusion-1.13-red)
![Samples](https://img.shields.io/badge/SRA_Samples-1387-blue)
![Batches](https://img.shields.io/badge/Compute_Nodes-40_parallel-orange)
![Platform](https://img.shields.io/badge/Platform-HPC_PBSPro-purple)
![Reference](https://img.shields.io/badge/Reference-GRCh38_gencode_v37-green)

## Overview
End-to-end pipeline for EGFR gene fusion detection in lung cancer
SRA samples (n=1,387 SRR IDs, SRP074349). Runs at scale on HPC
using PBS array jobs across parallel compute nodes simultaneously.

Downstream aim: compare gene expression between
EGFR fusion-positive vs EGFR fusion-negative samples.

## Pipeline steps
Lung_SRA_sample.csv (metadata)
↓
SRA Run Selector → match SRS/SRR IDs (Excel COUNTIF)
↓
prefetch → .sra files                    [script 01]
↓
Batch separation (50 samples/batch)      [script 00]
↓
rsync batches to HPC server
↓
fasterq-dump → paired FASTQ              [script 02 - PBS array]
↓
pigz → compress to .fastq.gz             [script 03]
↓
FastQC → fastp → FastQC                  [script 04 - PBS array]
↓
STAR-Fusion (module or Docker)           [script 05/05b - PBS array]
↓
Fusion_result/ per sample
↓
EGFR fusion+ve vs fusion-ve classification

## Scale
- 1,387 total SRR IDs (paired + single end)
- Processed in batches of 50
- PBS array jobs: up to 40 nodes simultaneously
- Per node: 48 CPUs, 120GB RAM

## Critical: module loading order
STAR and STAR-Fusion require gcc/13.3.0 loaded first:
```bash
module load gcc/13.3.0 star/2.7.11b star-fusion/1.13
```
Loading star/2.7.11b without gcc/13.3.0 causes GLIBCXX errors.

## Docker alternative
If GLIBCXX errors persist, use the Docker-based script:
```bash
qsub scripts/05b_star_fusion_docker.sh
```

## Usage

```bash
# 1. Add SRR IDs to config/project_SRR_ids.txt
# 2. Download SRA files
bash scripts/01_sra_download.sh

# 3. Separate into batches of 50
bash scripts/00_batch_separation.sh

# 4. Rsync batches to HPC
rsync -ravP batch1/ username@hpc_ip:/path/to/destination

# 5. On HPC: convert to FASTQ
# Generate jobs list first:
find . -name "*.sra" > config/jobs_sra.txt
qsub scripts/02_fasterq_dump.sh

# 6. Compress and generate fastq jobs list
qsub scripts/03_zip_fastq.sh

# 7. QC and trimming
qsub scripts/04_fastp_preprocess.sh

# 8. STAR-Fusion
qsub scripts/05_star_fusion.sh
```

## Requirements
sratoolkit/3.1.1
fastqc/0.12.1
fastp/0.24
pigz/2.8
gcc/13.3.0
star/2.7.11b
star-fusion/1.13
java/17
## Author
Ashlesha Pande — Senior Research Fellow
ACTREC, Tata Memorial Centre, Mumbai
ashlesha543@gmail.com
