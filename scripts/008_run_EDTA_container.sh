#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=edta
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_edta_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_edta_%j.e

# load modules


# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation
ASSEMBLY_HIFIASM=/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly/hifiasm_output.fa
ASSEMBLY_LJA=/data/users/amaalouf/transcriptome_assembly/assemblies/lja_assembly/assembly.fasta
ASSEMBLY_FLYE=/data/users/amaalouf/transcriptome_assembly/assemblies/flye_assembly/assembly.fasta
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation
CONTAINER_SIF=/data/users/amaalouf/transcriptome_assembly/annotation/edta:2.2.0--hdfd78af_1
CDS_FILE=/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated

# create directory if not available and enter it
mkdir -p $OUT_DIR && cd $OUT_DIR

# run EDTA
# --genome [File]		The genome FASTA file. Required.
# --species [Rice|Maize|others]	Specify the species for identification of TIR candidates. Default: others
# --step [all|filter|final|anno]	Specify which steps you want to run EDTA. all: run the entire pipeline (default)
# --cds [File]		Provide a FASTA file containing the coding sequence (no introns, UTRs, nor TEs) of this genome or its close relative.
#  --anno [0|1]	Perform (1) or not perform (0, default) whole-genome TE annotation after TE library construction.
# --threads|-t	[int]	Number of theads to run this script (default: 4)

apptainer exec\
 --bind /usr/bin/which:/usr/bin/which\
 --bind $WORK_DIR\
  $CONTAINER_SIF\
 EDTA.pl\
  --genome $ASSEMBLY_HIFIASM\
  --species others\
  --step all\
  --cds $CDS_FILE\
  --anno 1\
  --threads 20   