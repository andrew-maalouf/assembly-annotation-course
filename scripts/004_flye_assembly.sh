#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=flye_assembly
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_flye_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_flye_%j.e

# load modules


# set variables
READS=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp/trimmed/Lu-1/Lu-1_trimmed.fastq.gz
WORK_DIR=/data/users/amaalouf/transcriptome_assembly
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/flye_assembly
FLYE_CONTAINER=/containers/apptainer/flye_2.9.5.sif

# create directory if not available
mkdir -p $OUT_DIR

# run the container
# --out-dir path: output directory
# --threads int: number of parallel threads [1]
# --pacbio-hifi path [path ...]: PacBio HiFi reads (<1% error)
apptainer exec\
 --bind $WORK_DIR\
  $FLYE_CONTAINER\
   flye --pacbio-hifi $READS\
    --out-dir $OUT_DIR\
     --threads 16