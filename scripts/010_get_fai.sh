#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=faidx
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_faidx_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_faidx_%j.e

# load modules
module load SAMtools/1.13-GCC-10.3.0

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly
ASSEMBLY_HIFIASM=/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly/hifiasm_output.fa

cd $WORK_DIR

samtools faidx $ASSEMBLY_HIFIASM