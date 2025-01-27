#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=busco_annotation
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_busco_anno_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_busco_anno_%j.e

# load modules

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
CONTAINER_SIF=/containers/apptainer/busco_5.7.1.sif
MAKER_P=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation/longest_proteins.fasta
MAKER_T=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation/longest_transcripts.fasta
UNIDB=/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa
MAKERBIN=/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin

# load module
module load BUSCO/5.4.2-foss-2021a

# create directory if not available
mkdir -p $OUT_DIR $OUT_DIR/busco_protein $OUT_DIR/busco_transcript
cd $OUT_DIR

# run busco on maker annotations
# --in: input file to analyse (nucleotide fasta file)
# --mode: sets the assessment MODE: genome, proteins, transcriptome
# --lineage_dataset: specify the name of the BUSCO lineage dataset to be used
# --cpu: specify the number of threads/cores to use. Unless this is specified BUSCO will only use one CPU, which could cause a long run time.
# --out: give your analysis run a recognisable short name. Output folders and files will be labelled with this name
# --out_path: optional location for results folder, excluding results folder name
busco --in $MAKER_P\
  --mode proteins\
  --lineage_dataset brassicales_odb10\
  --cpu 16\
  --out busco_prot\
  --out_path $OUT_DIR/busco_protein

busco --in $MAKER_T\
  --mode transcriptome\
  --lineage_dataset brassicales_odb10\
  --cpu 16\
  --out busco_trans\
  --out_path $OUT_DIR/busco_transcript