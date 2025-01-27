#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=maker
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_maker_manip_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_maker_manip_%j.e

# load modules


# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker
FINAL_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/hifiasm_output.maker.output
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
MAKERBIN=/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin
CONTAINER_SIF=/containers/apptainer/interProScan-5.67-99.0.sif
IPR=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation/interproscan/output.iprscan

# create directoriy for interproscan
mkdir -p $WORK_DIR/interproscan

cd $WORK_DIR

# merge the individual GFF files into a single file,
$MAKERBIN/gff3_merge -s -d $OUT_DIR/hifiasm_output_master_datastore_index.log > $WORK_DIR/assembly.all.maker.gff

$MAKERBIN/gff3_merge -n -s -d $OUT_DIR/hifiasm_output_master_datastore_index.log > $WORK_DIR/assembly.all.maker.noseq.gff

$MAKERBIN/fasta_merge -d $OUT_DIR/hifiasm_output_master_datastore_index.log -o $WORK_DIR/assembly.all.maker.fasta


# finalize annotation

# create directory to store the final filtered annotations and copy the necessary files to it
mkdir $FINAL_DIR

# get file "iprscan" that is needed
# from running script 016

# start copying
cd $WORK_DIR
cp $IPR $FINAL_DIR/.
cp assembly.all.maker.noseq.gff $FINAL_DIR/assembly.gff
cp assembly.all.maker.fasta.all.maker.proteins.fasta $FINAL_DIR/protein.fasta
cp assembly.all.maker.fasta.all.maker.transcripts.fasta $FINAL_DIR/transcript.fasta
cd $FINAL_DIR

# rename genes
# To assign clean, consistent IDs to the gene models, use MAKER’s ID mapping tools.
$MAKERBIN/maker_map_ids --prefix Lu-1 --justify 7 assembly.gff > id.map
$MAKERBIN/map_gff_ids id.map assembly.gff
#$MAKERBIN/map_data_ids id.map output.iprscan
$MAKERBIN/map_fasta_ids id.map protein.fasta
$MAKERBIN/map_fasta_ids id.map transcript.fasta