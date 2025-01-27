#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=faidx
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_faidx_length_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_faidx_length_%j.e

# load modules
module load SAMtools/1.13-GCC-10.3.0
module load SeqKit/2.6.1

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation
ORIG_PROT_FA=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation/protein.filtered.fasta
ORIG_TRANS_FA=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation/transcript.filtered.fasta

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
