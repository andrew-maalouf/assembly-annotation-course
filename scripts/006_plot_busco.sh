#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=busco
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_plot_busco_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_plot_busco_%j.e

# load modules


# set variables
ASSEMBLY_HIFIASM=/data/users/amaalouf/transcriptome_assembly/assemblies/assemblies_evaluation/busco/hifiasm/busco_hifiasm/short_summary.specific.brassicales_odb10.busco_hifiasm.txt
ASSEMBLY_LJA=/data/users/amaalouf/transcriptome_assembly/assemblies/assemblies_evaluation/busco/lja/busco_lja/short_summary.specific.brassicales_odb10.busco_lja.txt
ASSEMBLY_FLYE=/data/users/amaalouf/transcriptome_assembly/assemblies/assemblies_evaluation/busco/flye/busco_flye/short_summary.specific.brassicales_odb10.busco_flye.txt
ASSEMBLY_TRINITY=/data/users/amaalouf/transcriptome_assembly/assemblies/assemblies_evaluation/busco/trinity/busco_trinity/short_summary.specific.brassicales_odb10.busco_trinity.txt
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/assemblies/assemblies_evaluation/busco/all
CONTAINER_SIF=/containers/apptainer/busco_5.7.1.sif

# create directory if not available
mkdir -p $OUT_DIR && cd $OUT_DIR

# copy all summaries into my output directory 
cp $ASSEMBLY_FLYE .
cp $ASSEMBLY_LJA .
cp $ASSEMBLY_HIFIASM .
cp $ASSEMBLY_TRINITY .

# generate plots
apptainer exec\
 --bind $OUT_DIR\
  $CONTAINER_SIF\
  generate_plot.py -wd $OUT_DIR

  