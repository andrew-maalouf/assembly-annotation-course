#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=R
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=40
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_genespaceR_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_genespaceR__%j.e

# load module
module load R/4.1.0-foss-2021a
module load UCSC-Utils/448-foss-2021a
module load MariaDB/10.6.4-GCC-10.3.0


# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/genespace
SCRIPT1=/data/users/amaalouf/transcriptome_assembly/scripts/16-create_Genespace_folders.R
SCRIPT2=/data/users/amaalouf/transcriptome_assembly/scripts/17-Genespace.R
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/genespace_latest.sif
PEP=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/genespace/genespace/peptide
BED=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/genespace/genespace/bed

# create dir
mkdir -p $WORK_DIR
cd $WORK_DIR

# prepare my input files
Rscript $SCRIPT1

# add other accessions
# oriane
cp /data/users/okopp/assembly_annotation_course/genespace/bed/Kar1.bed $BED/Kar_1.bed
cp /data/users/okopp/assembly_annotation_course/genespace/peptide/Kar1.fa $PEP/Kar_1.fa
# leo
#cp /data/users/okopp/assembly_annotation_course/genespace/bed/St-0.bed $BED/St_0.bed
#cp /data/users/okopp/assembly_annotation_course/genespace/peptide/St-0.fa $PEP/St_0.fa
#rm $BED/St_0.bed
#rm $PEP/St_0.fa
# hector 
cp /data/users/harribas/assembly_course/annotation/scripts/genespace/bed/genome1.bed $BED/Altai_5.bed
cp /data/users/harribas/assembly_course/annotation/scripts/genespace/peptide/genome1.fa $PEP/Altai_5.fa

# rename mine
mv $BED/genome1.bed $BED/Lu_1.bed
mv $PEP/genome1.fa $PEP/Lu_1.fa

# run genespace
# modify manually 'wd' in $SCRIPT2 and remove arg[1] which is now useless
apptainer exec \
    --bind $COURSEDIR \
    --bind $WORK_DIR \
    --bind $SCRATCH:/temp \
    --bind /data \
    $CONTAINER\
     Rscript $SCRIPT2