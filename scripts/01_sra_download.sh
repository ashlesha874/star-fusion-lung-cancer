#!/bin/bash
# SRA Download Script
# Downloads .sra files using prefetch for SRR IDs listed in jobs.txt
# Usage: bash 01_sra_download.sh

cd $PBS_O_WORKDIR

while IFS= read -r srr; do
    echo "Downloading: $srr"
    prefetch "$srr"
done < config/project_SRR_ids.txt

echo "All SRA downloads complete."
