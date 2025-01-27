#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=lja_assembly
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_lja_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_lja_%j.e

# load modules


# set variables
READS=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp/trimmed/Lu-1/Lu-1_trimmed.fastq.gz
WORK_DIR=/data/users/amaalouf/transcriptome_assembly
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/lja_assembly
LJA_CONTAINER=/containers/apptainer/lja-0.2.sif

# create directory if not available
mkdir -p $OUT_DIR

# run the container fastqc on untrimmed fasta
# -o <file_name>: name of output folder. Resulting graph will be stored there
# --reads <file_name>: name of file that contains reads in fasta or fastq format
# -t <int>: Number of threads. The default value is 16
apptainer exec\
 --bind $WORK_DIR\
  $LJA_CONTAINER\
   lja --reads $READS\
    -o $OUT_DIR\
     -t 16