#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=fastp
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=40G
#SBATCH --cpus-per-task=2
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_fastp_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_fastp_%j.e


# set variables
QC_DIR=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp
R1=/data/users/amaalouf/transcriptome_assembly/read_QC/raw_data/RNAseq_Sha/ERR754081_1.fastq.gz
R2=/data/users/amaalouf/transcriptome_assembly/read_QC/raw_data/RNAseq_Sha/ERR754081_2.fastq.gz
ACCESSION=/data/users/amaalouf/transcriptome_assembly/read_QC/raw_data/ERR11437310.fastq.gz
OUTPUT_DIR=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp/trimmed
CONTAINER_SIF=/containers/apptainer/fastp_0.23.2--h5f740d0_3.sif

mkdir -p $QC_DIR
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/RNAseq_Sha
mkdir -p $OUTPUT_DIR/Lu-1

# run fastp on Illumina data to trim and filter
# --in1: path to the first paired-end read file
# --in2: path to the second paired-end read file
# --out1: path to the trimmed first paired-end read file
# --out2: path to the trimmed second paired-end read file
apptainer exec\
 --bind $QC_DIR\
  $CONTAINER_SIF\
  fastp --in1 $R1\
 --in2 $R2\
  --out1 $OUTPUT_DIR/RNAseq_Sha/R1_trimmed.fastq.gz\
   --out2 $OUTPUT_DIR/RNAseq_Sha/R2_trimmed.fastq.gz\
    --json $OUTPUT_DIR/RNAseq_Sha.json\
     --html $OUTPUT_DIR/RNAseq_Sha.html\
      --report_title RNAseq_Sha


# run fastp on accession data without filtering to get the number of reads
# --disable_quality_filtering: disable quality filtering based on Phred scores
# --disable_length_filtering: disable length filtering based on read length
apptainer exec\
 --bind $QC_DIR\
  $CONTAINER_SIF\
  fastp -i $ACCESSION\
 -o $OUTPUT_DIR/Lu-1/Lu-1_trimmed.fastq.gz\
  --disable_quality_filtering \
    --disable_length_filtering \
   --json $OUTPUT_DIR/Lu-1.json\
    --html $OUTPUT_DIR/Lu-1.html\
     --report_title Lu-1