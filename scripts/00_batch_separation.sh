#!/bin/bash
# Splits downloaded SRR folders into batches of 50
# Run after prefetch downloads are complete
# Usage: bash 00_batch_separation.sh

i=0; b=1
for f in SRR*; do
    ((i++))
    d="batch$b"
    mkdir -p "$d"
    mv "$f" "$d"
    ((i%50==0)) && ((b++))
done

echo "Done. Created $b batch(es) of 50 samples each."
