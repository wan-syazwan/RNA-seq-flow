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
```

Or use conda:
```bash
conda install -c bioconda sra-tools fastqc fastp bowtie2 samtools subread
```

## Usage

1. Place your reference genome (.fna and .gtf) in `~/refgen/` or define your files path.
2. Prepare a list of SRR accession numbers in `SRR_acc_list.txt`.
3. Run the pipeline:
```bash rnaseq_flow.sh```

## Output

`fastq/` → raw FASTQ
`fastqc/` → quality reports
`trimmed/` → trimmed FASTQ
`bowtie_output/` → SAM alignments
`bam_sorted/` → sorted BAM
`bam_index/` → BAM index
`featurecounts_output/` → raw read counts
