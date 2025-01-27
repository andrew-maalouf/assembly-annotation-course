#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=count_kmers
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=50G
#SBATCH --cpus-per-task=2
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_kmers_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_kmers_%j.e

# load module
module load Jellyfish/2.3.0-GCC-10.3.0

# set variables
R1=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp/trimmed/RNAseq_Sha/R1_trimmed.fastq.gz
R2=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp/trimmed/RNAseq_Sha/R2_trimmed.fastq.gz
ACCESSION=/data/users/amaalouf/transcriptome_assembly/read_QC/fastp/trimmed/Lu-1/Lu-1_trimmed.fastq.gz
OUTPUT_DIR=/data/users/amaalouf/transcriptome_assembly/read_QC/jellyfish

# create directories
mkdir -p $OUTPUT_DIR

# count kmers
# -C: count canonical k-mers (only consider the lexicographically smallest of a k-mer and its reverse complement)
# -m: choose the k-mer size (the length of the subsequences to count)
# -s: estimated memory usage (adjust based on your dataset size and available memory)
# -t: number of threads to use for parallel processing (more threads can speed up the process on multi-core machines)
# -o: output file for the k-mer count table (in JSON format)
jellyfish count -C \
   -m 21\
    -s 5G\
     -t 4\
       -o $OUTPUT_DIR/results_R.jf <(zcat $R1) <(zcat $R2)

jellyfish count -C \
   -m 21\
    -s 5G\
     -t 4\
       -o $OUTPUT_DIR/results_acc.jf <(zcat $ACCESSION)

# generate histogram of results
jellyfish histo -t 4 $OUTPUT_DIR/results_R.jf > $OUTPUT_DIR/results_R.histo
jellyfish histo -t 4 $OUTPUT_DIR/results_acc.jf > $OUTPUT_DIR/results_acc.histo