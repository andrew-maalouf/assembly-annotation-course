#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=busco2
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_busco2_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_busco2_%j.e

# load modules
module load SAMtools/1.13-GCC-10.3.0
module load SeqKit/2.6.1
module load BUSCO/5.4.2-foss-2021a

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final
ORIG_PROT_FA=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/protein.filtered.fasta
ORIG_TRANS_FA=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/transcript.filtered.fasta
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/quality
MAKER_P=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/longest_proteins.fasta
MAKER_T=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/longest_transcripts.fasta
UNIDB=/data/courses/assembly-annotation-course/CDS_annotation/data/uniprot/uniprot_viridiplantae_reviewed.fa
MAKERBIN=/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin

cd $WORK_DIR

# get length for proteins
samtools faidx $ORIG_PROT_FA
cut -f1-2 $ORIG_PROT_FA.fai > protein_lengths.txt

# get length for transcripts
samtools faidx $ORIG_TRANS_FA
cut -f1-2 $ORIG_TRANS_FA.fai > transcript_lengths.txt

# for each of the text files, keep the longest sequence for each gene
# for protein
awk '{
    # extract the gene ID using the pattern "Lu-1" followed by digits, stopping before the suffix RA RB RC or whatever
    match($1, /(Lu-1[0-9]+)/, id_parts);
    gene_id = id_parts[1];

    # if gene_id is not in array or current length is greater, store the ID and length
    if (!(gene_id in max_length) || $2 > max_length[gene_id]) {
        max_length[gene_id] = $2;
        longest_id[gene_id] = $1;
    }
}
END {
    # output longest sequence ID for each gene
    for (gene in longest_id) {
        print longest_id[gene];
    }
}' protein_lengths.txt > protein_longest.txt

# for transcript
awk '{
    # extract the gene ID using the pattern "Lu-1" followed by digits, stopping before the suffix RA RB RC or whatever
    match($1, /(Lu-1[0-9]+)/, id_parts);
    gene_id = id_parts[1];

    # if gene_id is not in array or current length is greater, store the ID and length
    if (!(gene_id in max_length) || $2 > max_length[gene_id]) {
        max_length[gene_id] = $2;
        longest_id[gene_id] = $1;
    }
}
END {
    # output longest sequence ID for each gene
    for (gene in longest_id) {
        print longest_id[gene];
    }
}' transcript_lengths.txt > transcript_longest.txt

# remove -RA or whatever from the end to keep correct ID
#cut -d '-' -f1-2 protein_longest.txt > clean_protein_longest.txt
#cut -d '-' -f1-2 transcript_longest.txt > clean_transcript_longest.txt


# now use the 'longest' txt file to extract these fasta sequences
# for protein 
seqkit grep -f protein_longest.txt $ORIG_PROT_FA -o longest_proteins.fasta

# for transcript
seqkit grep -f transcript_longest.txt $ORIG_TRANS_FA -o longest_transcripts.fasta

##################################################
# busco

# create directory if not available
mkdir -p $OUT_DIR $OUT_DIR/busco_protein_2 $OUT_DIR/busco_transcript_2
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
  --out_path $OUT_DIR/busco_protein_2

busco --in $MAKER_T\
  --mode transcriptome\
  --lineage_dataset brassicales_odb10\
  --cpu 16\
  --out busco_trans\
  --out_path $OUT_DIR/busco_transcript_2