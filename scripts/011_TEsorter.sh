#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=tesorter
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_tesorter_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_tesorter_%j.e

# load modules
module load SeqKit/2.6.1

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation
TE_LIB=/data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation/hifiasm_output.fa.mod.EDTA.final/hifiasm_output.fa.mod.EDTA.TElib.fa
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter
CONTAINER_SIF=/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif
CDS_FILE=/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated
COPIA=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Copia_sequences.fa
GIPSY=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Gypsy_sequences.fa

# create directory if not available and enter it
mkdir -p $OUT_DIR && cd $OUT_DIR

# extract Copia sequences
seqkit grep -r -p "Copia" $TE_LIB > $COPIA
# extract Gypsy sequences
seqkit grep -r -p "Gypsy" $TE_LIB > $GIPSY


# run TEsorter
#apptainer exec\
# --bind /data\
#  $CONTAINER_SIF\
# TEsorter $COPIA -db rexdb-plant

#apptainer exec\
# --bind /data\
#  $CONTAINER_SIF\
# TEsorter $GIPSY -db rexdb-plant

 # using conda
 # eval "$(/home/amaalouf/miniconda3/bin/conda shell.bash hook)"
 # conda create --name TEsorter
 # conda activate TEsorter
 # conda install -c bioconda tesorter
 TEsorter $COPIA -db rexdb-plant
 TEsorter $GIPSY -db rexdb-plant