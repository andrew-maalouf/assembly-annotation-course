#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=miniprot
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_miniprot_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_miniprot__%j.e

# load module

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/miniprot
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
OMAMER_PROT=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/protein.filtered.fasta.omamer
OMARK_OUT=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/omark/omark_output
CONTEXTUALIZE=/data/courses/assembly-annotation-course/CDS_annotation/softwares/OMArk-0.3.0/utils/omark_contextualize.py
ORIG_FA=/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly/hifiasm_output.fa
SEQ_FASTA=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/miniprot/missing_HOGs.fa
CONTAINER=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/miniprot/miniprot:0.12--he4a0461_0

# create directory
mkdir -p $WORK_DIR
cd $WORK_DIR

# Download the Orthologs of fragmented and missing genes from OMArk database
# conda activate OMArk
python $CONTEXTUALIZE fragment -m $OMAMER_PROT -o $OMARK_OUT -f fragment_HOGs
python $CONTEXTUALIZE missing -m $OMAMER_PROT -o $OMARK_OUT -f missing_HOGs

# with container or not
# without container:
# download and compile
#git clone https://github.com/lh3/miniprot
#cd miniprot && make

# run miniprot
# I: Indexing mode for faster mapping.
#--gff: Outputs a GFF file for easier visualization.
#--outs=0.95: Sets 95% similarity threshold
#apptainer exec\
# --bind /data\
# $CONTAINER\
miniprot/miniprot -I --gff --outs=0.95 $ORIG_FA $SEQ_FASTA > MINIPROT_OUTPUT.gff
