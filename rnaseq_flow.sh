#!/bin/bash
# RNA-seq pipeline: SRA download → QC → trimming → alignment → BAM → read count
# Author: wansyazwan
# Date: 24 August 2025

set -euo pipefail

# === INPUT FILES ===
# SRR_acc_list.txt should contain one SRR accession per line
# Reference genome (.fna) and annotation (.gtf) should be in ~/refgen/

SRR_LIST="SRR_acc_list.txt"
REF_FASTA=~/refgen/GCF_000008865.2_ASM886v2_genomic.fna
REF_GTF=~/refgen/GCF_000008865.2_ASM886v2_genomic.gtf
INDEX=~/refgen/GCF_000008865.2_ASM886v2_genomic

# === 1. Download FASTQ ===
mkdir -p fastq
while read sracode; do
  echo "[INFO] Downloading $sracode ..."
  fasterq-dump ${sracode} -O fastq --split-files --progress --threads $(nproc)
done < $SRR_LIST

# === 2. Quality control (FastQC) ===
mkdir -p fastqc
while read sracode; do
  echo "[INFO] Running FastQC for $sracode ..."
  fastqc fastq/${sracode}_1.fastq -o fastqc --threads $(nproc)
  fastqc fastq/${sracode}_2.fastq -o fastqc --threads $(nproc)
done < $SRR_LIST

# === 3. Trimming (fastp) ===
mkdir -p trimmed fastp_reports
while read sracode; do
  echo "[INFO] Trimming $sracode ..."
  fastp \
    -i fastq/${sracode}_1.fastq \
    -I fastq/${sracode}_2.fastq \
    -o trimmed/${sracode}_1_trimmed.fastq \
    -O trimmed/${sracode}_2_trimmed.fastq \
    --detect_adapter_for_pe \
    --thread $(nproc) \
    --html fastp_reports/${sracode}_report.html \
    --json fastp_reports/${sracode}_report.json
done < $SRR_LIST

# === 4. Build Bowtie2 index (only once) ===
if [ ! -f ${INDEX}.1.bt2 ]; then
  echo "[INFO] Building Bowtie2 index ..."
  bowtie2-build $REF_FASTA $INDEX
fi

# === 5. Alignment (Bowtie2) ===
mkdir -p bowtie_output
while read sracode; do
  echo "[INFO] Aligning $sracode ..."
  bowtie2 \
    -x $INDEX \
    -1 trimmed/${sracode}_1_trimmed.fastq \
    -2 trimmed/${sracode}_2_trimmed.fastq \
    -S bowtie_output/${sracode}_aligned.sam \
    --threads $(nproc)
done < $SRR_LIST

# === 6. Convert SAM → sorted BAM (samtools) ===
mkdir -p bam_sorted bam_index
while read sracode; do
  echo "[INFO] Processing $sracode ..."
  samtools view -@ $(nproc) -bS bowtie_output/${sracode}_aligned.sam | \
    samtools sort -@ $(nproc) -o bam_sorted/${sracode}_sorted.bam
  samtools index bam_sorted/${sracode}_sorted.bam -@ $(nproc) -o bam_index/${sracode}_sorted.bam.bai
done < $SRR_LIST

# === 7. Read counting (featureCounts) ===
mkdir -p featurecounts_output
while read sracode; do
  echo "[INFO] Counting features for $sracode ..."
  featureCounts \
    -S 2 \
    -p \
    -a $REF_GTF \
    -o featurecounts_output/${sracode}_count.tsv \
    bam_sorted/${sracode}_sorted.bam \
    -t gene -g gene_id -T $(nproc)
done < $SRR_LIST

echo "[INFO] Pipeline finished successfully!"
