#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=phylo_analysis
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_phylo_analysis_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_phylo_analysis_%j.e

# load modules
module load SeqKit/2.6.1
module load Clustal-Omega/1.2.4-GCC-10.3.0
module load FastTree/2.1.11-GCCcore-10.3.0


# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation
TE_LIB=/data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation/hifiasm_output.fa.mod.EDTA.final/hifiasm_output.fa.mod.EDTA.TElib.fa
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis
CDS_FILE=/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated
COPIA=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Copia_sequences.fa
GIPSY=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Gypsy_sequences.fa
BRASS_FASTA=/data/courses/assembly-annotation-course/CDS_annotation/data/Brassicaceae_repbase_all_march2019.fasta
REXDB_COPIA=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Copia_sequences.fa.rexdb-plant.dom.faa
REXDB_GIPSY=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Gypsy_sequences.fa.rexdb-plant.dom.faa
LIST_G=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/list_gypsy.txt
LIST_C=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/list_copia.txt
G_FASTA=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/Gypsy_RT.fasta
C_FASTA=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/Copia_RT.fasta
BRASS_C=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/brass_TEsorter/Brass_Copia_sequences.fa
BRASS_G=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/brass_TEsorter/Brass_Gypsy_sequences.fa
TE_O_COPIA=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/brass_TEsorter/Brass_Copia_sequences.fa.rexdb-plant.dom.faa
TE_O_GIPSY=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/brass_TEsorter/Brass_Gypsy_sequences.fa.rexdb-plant.dom.faa
LIST_BG=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/list_brass_gypsy.txt
LIST_BC=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/list_brass_copia.txt
BG_FASTA=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/Gypsy_RT_Brass.fasta
BC_FASTA=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/Copia_RT_Brass.fasta

# create directory if not available and enter it
mkdir -p $OUT_DIR $OUT_DIR/brass_TEsorter $OUT_DIR/clustalo $OUT_DIR/fasttree && cd $OUT_DIR

# Analysis of LTR retrotransposons
# step 1: Extract RT protein sequences from $.rexdb-plant.dom.faa using seqkit grep
# but 1st change header so that it is nicer when plotting later
# for gypsy
grep Ty3-RT $REXDB_GIPSY > $LIST_G #make a list of RT proteins to extract
sed -i 's/>//' $LIST_G # remove ">" from the header
#sed -i 's/|.*//' $LIST_G # split on "|" and take the part before it up until 'Gypsy'
sed -i 's/ .\+//' $LIST_G # remove all characters following "empty space" from the header
seqkit grep -f $LIST_G $REXDB_GIPSY -o $G_FASTA

# for copia
grep Ty1-RT $REXDB_COPIA > $LIST_C #make a list of RT proteins to extract
sed -i 's/>//' $LIST_C # remove ">" from the header
#sed -i 's/|.*//' $LIST_C # split on "|" and take the part before it up until 'Copia'
sed -i 's/ .\+//' $LIST_C # remove all characters following "empty space" from the header
seqkit grep -f $LIST_C $REXDB_COPIA -o $C_FASTA


# step 2: Repeat TEsorter analysis using the Brassicaceae TE database as input file.
cd $OUT_DIR/brass_TEsorter
# Extract the RT sequences from the output file
# Remember to analyze Copia and Gypsy elements separately.
# using conda
# eval "$(/home/amaalouf/miniconda3/bin/conda shell.bash hook)"
# conda activate TEsorter
seqkit grep -r -p "Gypsy" $BRASS_FASTA > $BRASS_G
seqkit grep -r -p "Copia" $BRASS_FASTA > $BRASS_C
TEsorter $BRASS_C -db rexdb-plant 
TEsorter $BRASS_G -db rexdb-plant 

# again now fix header for fasta so it's nicer
# for gypsy
grep Ty3-RT $TE_O_GIPSY > $LIST_BG #make a list of RT proteins to extract
sed -i 's/>//' $LIST_BG # remove ">" from the header
#sed -i 's/|.*//' $LIST_BG # split on "|" and take the part before it
sed -i 's/ .\+//' $LIST_BG # remove all characters following "empty space" from the header
seqkit grep -f $LIST_BG $TE_O_GIPSY -o $BG_FASTA

# for copia
grep Ty1-RT $TE_O_COPIA > $LIST_BC #make a list of RT proteins to extract
sed -i 's/>//' $LIST_BC # remove ">" from the header
#sed -i 's/|.*//' $LIST_BC # split on "|" and take the part before it
sed -i 's/ .\+//' $LIST_BC # remove all characters following "empty space" from the header
seqkit grep -f $LIST_BC $TE_O_COPIA -o $BC_FASTA

# step 3: Concatenate RTs from both Brassicaceae and Arabidopsis TEs into one fasta file.
cat $BC_FASTA $C_FASTA > $OUT_DIR/both_copia.fa
cat $BG_FASTA $G_FASTA > $OUT_DIR/both_gypsy.fa


cd $OUT_DIR
# step 4: Shorten identifiers of RT sequences and replace ":" with "_"
# the following part fixes my accession header
sed -i 's/#.\+//' both_copia.fa
sed -i 's/:/_/g' both_copia.fa
sed -i 's/#.\+//' both_gypsy.fa
sed -i 's/:/_/g' both_gypsy.fa
# this part fixes the brass headers
sed -i 's/|.*//' both_copia.fa
sed -i 's/|.*//' both_gypsy.fa


# step 5: Align the sequences with clustal omega
# the output alignment must be in fasta format (otherwise FastTree cannot read it)
cd $OUT_DIR/clustalo
clustalo -i $OUT_DIR/both_copia.fa -o copia_align.fa
clustalo -i $OUT_DIR/both_gypsy.fa -o gypsy_align.fa


# step 6: Infer approximately-maximum-likelihood phylogenetic tree with FastTree
cd $OUT_DIR/fasttree
FastTree -out copia_tree $OUT_DIR/clustalo/copia_align.fa
FastTree -out gypsy_tree $OUT_DIR/clustalo/gypsy_align.fa

# step 7: visualize
# run script 017