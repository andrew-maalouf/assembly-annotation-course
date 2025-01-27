#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=orthofinder
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_orthofinder_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_orthofinder__%j.e

# load module
module load R/4.1.0-foss-2021a
module load UCSC-Utils/448-foss-2021a
module load MariaDB/10.6.4-GCC-10.3.0


# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/parse_orthofinder2
SCRIPT=/data/users/amaalouf/transcriptome_assembly/scripts/19-parse_Orthofinder.R
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation

# create dir
mkdir -p $WORK_DIR $WORK_DIR/Plots
cd $WORK_DIR

# run script
Rscript $SCRIPT
# changes that were made to script:
# install complexupset locally
# make sure numeric columns for first plot are considered as numeric and not characters
# adjust ticks and labels on y axis for 1st plot