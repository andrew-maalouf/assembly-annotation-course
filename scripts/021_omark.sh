#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=omark
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_omark_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_omark__%j.e

# load module


# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/omark
ORIG_PROT_FA=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/protein.filtered.fasta
ORIG_PROT_FAI=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/protein.filtered.fasta.fai
OMAMER_PROT=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/protein.filtered.fasta.omamer
input_file=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/omark/all_isoforms.txt
output_file=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality/omark/all_isoforms.splice

# step 1: create environment
# eval "$(/home/amaalouf/miniconda3/bin/conda shell.bash hook)"
# module add Anaconda3/2022.05
# conda config --add channels conda-forge
# conda config --set channel_priority strict
# conda install alive-progress
# conda create -n OMArk bioconda::omark bioconda::omamer
# conda activate OMArk

# step 2
# mkdir annotation/output/quality/omark
# cd annotation/output/quality/omark/
# wget https://omabrowser.org/All/LUCA.h5

# step 3
mkdir -p $WORK_DIR
cd $WORK_DIR

omamer search --db LUCA.h5 --query $ORIG_PROT_FA --out $ORIG_PROT_FA.omamer

# step 4: splicing isoforms
cut -f1 $ORIG_PROT_FAI > all_isoforms.txt
# create an associative array to store isoforms per gene
declare -A gene_map

# Read each line from the input file
while IFS= read -r protein_id; do
    # Extract gene prefix (part before "-R")
    gene_prefix=$(echo "$protein_id" | sed -E 's/(-R.*)//')
    
    # Append protein ID to the corresponding gene key
    if [[ -z "${gene_map[$gene_prefix]}" ]]; then
        gene_map[$gene_prefix]="$protein_id"
    else
        gene_map[$gene_prefix]+=";$protein_id"
    fi
done < "$input_file"

# Write the grouped isoforms to the output file
> "$output_file"  # Clear the file if it exists
for gene in "${!gene_map[@]}"; do
    echo "${gene_map[$gene]}" >> "$output_file"
done


# run Omark
# -f: Path to an OMAmer search output file (Default mode)
# -of: The original proteomes file. Provide if you want optional FASTA file to be outputted by OMArk (Sequences by categories, sequences by detected species, etc
# -i: A text file, listing all isoforms of each gene as semi-colon separated values, with one gene per line. Use if your input proteome include more than one protein per gene.
# -d: Path to an OMAmer database
# -o: Path to the folder into which OMArk results will be output. OMArk will create it if it does not exist
omark -f $OMAMER_PROT\
 -of $ORIG_PROT_FA\
  -i $output_file\
   -d LUCA.h5\
    -o omark_output