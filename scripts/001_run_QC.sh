#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=read_qc
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH --cpus-per-task=4
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_qc_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_qc_%j.e

# load modules


# set variables
FASTA_DIR=/data/users/amaalouf/transcriptome_assembly/read_QC
QC_DIR=/data/users/amaalouf/transcriptome_assembly/read_QC/fastqc
LOCAL_RAW=/data/users/amaalouf/transcriptome_assembly/read_QC/raw_data
RAW_DATA=/data/courses/assembly-annotation-course/raw_data

# create directory if not available
mkdir -p $LOCAL_RAW
mkdir -p $QC_DIR

# create soft link for fasta in directory
ln -s $RAW_DATA/Lu-1/* $LOCAL_RAW
ln -s $RAW_DATA/RNAseq_Sha $LOCAL_RAW

# run the container fastqc on untrimmed fasta
apptainer exec\
 --bind $QC_DIR\
  /containers/apptainer/fastqc-0.12.1.sif\
   fastqc --outdir $QC_DIR/RNAseq_Sha_1 $LOCAL_RAW/RNAseq_Sha/ERR754081_1.fastq.gz

   apptainer exec\
 --bind $QC_DIR\
  /containers/apptainer/fastqc-0.12.1.sif\
   fastqc --outdir $QC_DIR/RNAseq_Sha_2 $LOCAL_RAW/RNAseq_Sha/ERR754081_2.fastq.gz

   apptainer exec\
 --bind $QC_DIR\
  /containers/apptainer/fastqc-0.12.1.sif\
   fastqc --outdir $QC_DIR/Lu-1 $LOCAL_RAW/ERR11437310.fastq.gz

