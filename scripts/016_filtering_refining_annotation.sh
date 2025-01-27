#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=annotation_filt
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_filt_ref_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_filt_ref_%j.e

# load modules
module load SeqKit/2.6.1
module load UCSC-Utils/448-foss-2021a
module load BioPerl/1.7.8-GCCcore-10.3.0
module load MariaDB/10.6.4-GCC-10.3.0

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker
FINAL_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
CONTAINER_SIF=/containers/apptainer/interProScan-5.67-99.0.sif
PROTEIN=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/protein.fasta
MAKERBIN=/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin
GFF=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/assembly.gff
IPR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/output.iprscan
TRANSCRIPT=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/transcript.fasta
PYTHON=/data/users/amaalouf/transcriptome_assembly/scripts/faSomeRecords.py

# create directory and enter it
mkdir $OUT_DIR $OUT_DIR/interproscan

cd $OUT_DIR/interproscan
# step 1: Run InterProScan on the Protein File
#  -appl,--applications <ANALYSES>: Optional, comma separated list of analyses.  If this option is not set, ALL analyses will be run.
# -dp,--disable-precalc: Optional.  Disables use of the precalculated match lookup service.  All match calculations will be run locally.
# -f,--formats <OUTPUT-FORMATS>: Optional, case-insensitive, comma separated list of output formats. Supported formats are TSV, XML, JSON, and GFF3. Default for protein sequences are TSV, XML and GFF3, or for nucleotide sequences GFF3 and XML.
# -goterms,--goterms: Optional, switch on lookup of corresponding Gene Ontology annotation (IMPLIES -iprlookup option)
# -i,--input <INPUT-FILE-PATH>: Optional, path to fasta file that should be loaded on Master startup. Alternatively, in CONVERT mode, the InterProScan 5 XML file to convert.
#  -o,--outfile <EXPLICIT_OUTPUT_FILENAME>: Optional explicit output file name
# -pa,--pathways: Optional, switch on lookup of corresponding Pathway annotation (IMPLIES -iprlookup option)
# -t,--seqtype <SEQUENCE-TYPE>: Optional, the type of the input sequences (dna/rna (n) or protein (p)).  The default sequence type is protein. 
#apptainer exec\
# --bind /data\
#  $CONTAINER_SIF\
#    interproscan.sh\
#   -appl pfam\
#    --disable-precalc \
#     -f TSV\
#      --goterms \
#       --iprlookup \
#        --pathways \
#         --seqtype p\
#         -i $PROTEIN\
#           -o output.iprscan

# step 2: Calculate AED Values
# AED (Annotation Edit Distance) values are essential for evaluating how well gene models are supported by the evidence. Use MAKER’s AED_cdf_generator.pl to generate AED values for all annotations.
cd $OUT_DIR
#perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 $GFF > assembly.all.maker.renamed.gff.AED.txt


# step 3: Update GFF with InterProScan Results
$MAKERBIN/ipr_update_gff $GFF $IPR > gff_iprscan.gff


# step 4: Filter the GFF File for Quality
# Filter the GFF file based on the AED values <= 0.5 using Custom AED Threshold "-a"
perl $MAKERBIN/quality_filter.pl -a 0.5 gff_iprscan.gff > gff_filtered_AED.gff

# METHOD 1 for the rest:
# filter by functional annotations from interproscan
# select entries with specific functional term by extracting IDs associated with the "Pfam" term
grep "Pfam" $IPR | cut -f1 > functional_ids.txt
# use the list of IDs to filter the GFF
awk 'NR==FNR {ids[$1]; next} 
{
    if ($9 ~ /ID=/) {
        split($9, a, ";");
        for (i in a) {
            if (a[i] ~ /^ID=/) {
                id = substr(a[i], 4);  # Extract ID after "ID="
                if (id in ids) {
                    print "Matched ID:", id;  # Print matched IDs for debugging
                    print $0;  # Print the entire line if the ID is found in the ids array
                    break;  # Exit the loop once a match is found
                }
            }
        }
    }
}' functional_ids.txt gff_filtered_AED.gff > gff_final_filtered.gff

# step 5: Extract mRNA Sequences and Filter FASTA Files
grep -P "\tmRNA\t" gff_final_filtered.gff | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > list.txt
# Remove any potential carriage returns or hidden characters in list.txt
#sed -i 's/\r$//' list.txt

# extract mRNA sequences
#$PYTHON --fasta ${TRANSCRIPT} --list list.txt --outfile transcript.filtered.fasta
# extract protein seq
#$PYTHON --fasta ${PROTEIN} --list list.txt --outfile protein.filtered.fasta
seqkit grep -f list.txt ${TRANSCRIPT} -o transcript.filtered.fasta

seqkit grep -f list.txt ${PROTEIN} -o protein.filtered.fasta


# METHOD 2 for the rest:
# The gff also contains other features like Repeats, and match hints from different sources of evidence
# Let's see what are the different types of features in the gff file
cut -f3 gff_filtered_AED.gff | sort | uniq

# We only want to keep gene features in the third column of the gff file
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" gff_filtered_AED.gff > filtered.genes.renamed.gff3
cut -f3 filtered.genes.renamed.gff3 | sort | uniq

# We need to add back the gff3 header to the filtered gff file so that it can be used by other tools
grep "^#" gff_filtered_AED.gff > header.txt
cat header.txt filtered.genes.renamed.gff3 > filtered.genes.renamed.final.gff3

# Get the names of remaining mRNAs and extract them from the transcript and and their proteins from the protein files
grep -P "\tmRNA\t" filtered.genes.renamed.final.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' >mRNA_list.txt
faSomeRecords ${TRANSCRIPT} mRNA_list.txt transcript.filtered.2.fasta
faSomeRecords ${PROTEIN} mRNA_list.txt protein.filtered.2.fasta


# different outputs:
# METHOD 1 is the best 
# seqkit stats annotation/output/filtering_refining_annotation/protein.filtered.fasta 
#file                                                                    format  type     num_seqs     sum_len  min_len  avg_len  max_len
#annotation/output/filtering_refining_annotation/protein.filtered.fasta  FASTA   Protein    35,361  14,116,705       20    399.2    5,425

# MEthod 2 does not filter "pfam"
# seqkit stats annotation/output/filtering_refining_annotation/protein.filtered.2.fasta 
#file                                                                      format  type     num_seqs     sum_len  min_len  avg_len  max_len
#annotation/output/filtering_refining_annotation/protein.filtered.2.fasta  FASTA   Protein    44,071  15,865,062        1      360   11,546

#seqkit stats annotation/output/maker/final/protein.fasta 
#file                                         format  type     num_seqs     sum_len  min_len  avg_len  max_len
#annotation/output/maker/final/protein.fasta  FASTA   Protein    47,519  16,642,042        1    350.2   22,873

# check how many genes i have:
# grep "gene" /data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation/gff_final_filtered.gff | awk '{print $9}' |cut -d ';' -f1 | cut -d '-' -f2 | sort | uniq | wc -l
# 28112


#seqkit stats transcriptome_assembly/annotation/output/filtering_refining_annotation/transcript.filtered.fasta
#file                                                                                              format  type  num_seqs     sum_len  min_len  avg_len  max_len
#transcriptome_assembly/annotation/output/filtering_refining_annotation/transcript.filtered.fasta  FASTA   DNA     35,361  48,022,856       63  1,358.1   16,527

# number of proteins 35K > number of genes 28K because of alternative splicing
# for the next steps, the longest protein will be considered for each gene so total number of proteins will be reduced to 28K
