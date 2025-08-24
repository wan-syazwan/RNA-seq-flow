# RNA-Seq Pipeline (WSL/Linux)

This repository contains a simple RNA-Seq analysis pipeline using **WSL** or Linux.  
The workflow includes:

1. Downloading FASTQ from SRA (`fasterq-dump`)
2. Quality control (`FastQC`)
3. Read trimming (`fastp`)
4. Alignment (`Bowtie2`)
5. SAM to BAM conversion (`samtools`)
6. Raw read count generation (`featureCounts`)

## Requirements
Install dependencies (Debian/Ubuntu example):
```bash
sudo apt update
sudo apt install fastqc bowtie2 samtools
# fastp, sra-tools, subread may require conda or manual install
