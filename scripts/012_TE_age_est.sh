#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=age_est
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_age_est_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_age_est_%j.e

# load modules
module load BioPerl/1.7.8-GCCcore-10.3.0

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation
ANNO=/data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation/hifiasm_output.fa.mod.EDTA.anno/hifiasm_output.fa.mod.out
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter
CONTAINER_SIF=/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif
PARSERM=/data/users/amaalouf/transcriptome_assembly/scripts/parseRM.pl
COPIA=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Copia_sequences.fa
GIPSY=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Gypsy_sequences.fa

# create directory if not available and enter it
mkdir -p $OUT_DIR && cd $OUT_DIR

# bin TE Divergence Data
# -i: input file
# -l: parsing type: To split the amount of DNA by bins of %div or My, allowing to generate landscape graphs for each repeat name, family or class (one output for each)
# -v: it prints warnings if -v is set, so user can check if it was unintentional (typo, etc)
perl $PARSERM -i $ANNO -l 50,1 -v

# run plot_div.R
# locally
