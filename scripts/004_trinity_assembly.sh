#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=trinity_assembly
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_trinity_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_trinity_%j.e

# load modules
module load Trinity/2.15.1-foss-2021a

# set variables
READS1=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp/trimmed/RNAseq_Sha/R1_trimmed.fastq.gz
READS2=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp/trimmed/RNAseq_Sha/R2_trimmed.fastq.gz
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/trinity_assembly

# create directory if not available
mkdir -p $OUT_DIR

# run trinity on trimmed RNA transcriptome
# --output: name of directory for output
# --seqType: type of reads: ( fa, or fq )
#  --CPU: number of CPUs to use, default: 2
# --max_memory: suggested max memory to use by Trinity where limiting can be enabled
#  If paired reads:
#      --left: left reads, one or more file names (separated by commas, not spaces)
#      --right: right reads, one or more file names (separated by commas, not spaces)
Trinity --seqType fq\
 --left $READS1\
  --right $READS2\
   --CPU 6\
    --max_memory 20G\
    --output $OUT_DIR