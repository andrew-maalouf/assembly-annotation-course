#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=hifiasm_assembly
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_hifiasm_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_hifiasm_%j.e

# load modules


# set variables
READS=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp/trimmed/Lu-1/Lu-1_trimmed.fastq.gz
WORK_DIR=/data/users/amaalouf/transcriptome_assembly
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly
HIFIASM_CONTAINER=/containers/apptainer/hifiasm_0.19.8.sif
PREFIX=hifiasm_output

# create directory if not available
mkdir -p $OUT_DIR

cd $OUT_DIR

# run the container
# -t sets the number of CPUs in use
# -o specifies the prefix of output files 
apptainer exec\
 --bind $OUT_DIR\
  $HIFIASM_CONTAINER\
   hifiasm -o $PREFIX\
    -t 16\
     $READS

# convert gfa to fasta format
awk '/^S/{print ">"$2;print $3}' $OUT_DIR/$PREFIX.bp.p_ctg.gfa > $OUT_DIR/$PREFIX.fa