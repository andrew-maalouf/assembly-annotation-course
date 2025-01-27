#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=busco
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_busco_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_busco_%j.e

# load modules


# set variables
ASSEMBLY_HIFIASM=/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly/hifiasm_output.fa
ASSEMBLY_LJA=/data/users/amaalouf/transcriptome_assembly/assemblies/lja_assembly/assembly.fasta
ASSEMBLY_FLYE=/data/users/amaalouf/transcriptome_assembly/assemblies/flye_assembly/assembly.fasta
ASSEMBLY_TRINITY=/data/users/amaalouf/transcriptome_assembly/assemblies/trinity_assembly/final_output/trinity_assembly.Trinity.fasta
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/assemblies_comparison/busco
CONTAINER_SIF=/containers/apptainer/busco_5.7.1.sif

# create directory if not available
mkdir -p $OUT_DIR $OUT_DIR/hifiasm $OUT_DIR/flye $OUT_DIR/lja $OUT_DIR/trinity

# run busco
# --in: input file to analyse (nucleotide fasta file)
# --mode: sets the assessment MODE: genome, proteins, transcriptome
# --lineage_dataset: specify the name of the BUSCO lineage dataset to be used
# --cpu: specify the number of threads/cores to use. Unless this is specified BUSCO will only use one CPU, which could cause a long run time.
# --out: give your analysis run a recognisable short name. Output folders and files will be labelled with this name
# --out_path: optional location for results folder, excluding results folder name
apptainer exec\
 --bind $OUT_DIR\
  $CONTAINER_SIF\
  busco --in $ASSEMBLY_HIFIASM\
  --mode genome\
  --lineage_dataset brassicales_odb10\
  --cpu 16\
  --out busco_hifiasm\
  --out_path $OUT_DIR/hifiasm

  apptainer exec\
 --bind $OUT_DIR\
  $CONTAINER_SIF\
  busco --in $ASSEMBLY_FLYE\
  --mode genome\
  --lineage_dataset brassicales_odb10\
  --cpu 16\
  --out busco_flye\
  --out_path $OUT_DIR/flye

  apptainer exec\
 --bind $OUT_DIR\
  $CONTAINER_SIF\
  busco --in $ASSEMBLY_LJA\
  --mode genome\
  --lineage_dataset brassicales_odb10\
  --cpu 16\
  --out busco_lja\
  --out_path $OUT_DIR/lja

  apptainer exec\
 --bind $OUT_DIR\
  $CONTAINER_SIF\
  busco --in $ASSEMBLY_TRINITY\
  --mode transcriptome\
  --lineage_dataset brassicales_odb10\
  --cpu 16\
  --out busco_trinity\
  --out_path $OUT_DIR/trinity
  