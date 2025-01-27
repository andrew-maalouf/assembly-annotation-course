#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=homology
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_busco_anno_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_busco_anno_%j.e

# load modules
module load BLAST+/2.15.0-gompi-2021a

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
ORIG_PROT_FA=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/protein.filtered.fasta
ORIG_TRANS_FA=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/transcript.filtered.fasta
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality
MAKER_P=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/longest_proteins.fasta
MAKER_T=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/longest_transcripts.fasta
UNIDB=/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa
MAKERBIN=/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin
GFF=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/filtered.genes.renamed.final.gff3

# create directory if not available
mkdir -p $OUT_DIR $OUT_DIR/homology

# Sequence homology to functionally validated proteins (UniProt database)
cd $OUT_DIR/homology
# # this step is already done: makeblastb -in $UNIDB -dbtype prot
# -query <File_In>: Input file name; Default = `-'
# -db <String>: BLAST database name
# -out <File_Out, file name length < 256>: Output file name; Default = `-'
# -outfmt <String>   alignment view options:
     #0 = Pairwise,
     #1 = Query-anchored showing identities,
     #2 = Query-anchored no identities,
     #3 = Flat query-anchored showing identities,
     #4 = Flat query-anchored no identities,
     #5 = BLAST XML,
     #6 = Tabular.....
blastp -query $ORIG_PROT_FA\
 -db $UNIDB\
  -num_threads 10\
   -outfmt 6\
    -evalue 1e-10\
     -out blastp_protein

cp $ORIG_PROT_FA ./maker_proteins.fasta
cp $GFF ./filtered.maker.gff3
$MAKERBIN/maker_functional_fasta $UNIDB blastp_protein maker_proteins.fasta > maker_proteins.fasta.Uniprot
$MAKERBIN/maker_functional_gff $UNIDB blastp_protein filtered.maker.gff3 > filtered.maker.gff3.Uniprot.gff3