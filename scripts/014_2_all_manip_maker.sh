#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=maker
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_maker_all_manip_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_maker_all_manip_%j.e

# load modules
module load UCSC-Utils/448-foss-2021a
module load BioPerl/1.7.8-GCCcore-10.3.0
module load MariaDB/10.6.4-GCC-10.3.0

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker
FINAL_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
MAKERBIN=/data/courses/assembly-annotation-course/CDS_annotation/softwares/Maker_v3.01.03/src/bin
CONTAINER_SIF=/containers/apptainer/interProScan-5.67-99.0.sif
IPR=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation/interproscan/output.iprscan
gff=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/assembly.all.maker.gff
protein=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/assembly.all.maker.fasta.all.maker.proteins.fasta
transcript=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/assembly.all.maker.fasta.all.maker.transcripts.fasta
prefix="Lu-1"
PROTEIN_FILE=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/protein.fasta
GFF_FILE=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/assembly.gff
IPR_FILE=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/output.iprscan
TRANSCRIPT_FILE=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/transcript.fasta
# create directoriy for interproscan
mkdir -p $WORK_DIR/interproscan

cd $WORK_DIR

# merge the individual GFF files
$MAKERBIN/gff3_merge -s -d hifiasm_output.maker.output/hifiasm_output_master_datastore_index.log > assembly.all.maker.gff
$MAKERBIN/gff3_merge -n -s -d hifiasm_output.maker.output/hifiasm_output_master_datastore_index.log > $gff
$MAKERBIN/fasta_merge -d hifiasm_output.maker.output/hifiasm_output_master_datastore_index.log -o assembly.all.maker.fasta

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


$MAKERBIN/maker_map_ids --prefix $prefix --justify 7 assembly.gff > id.map
$MAKERBIN/map_gff_ids id.map assembly.gff
$MAKERBIN/map_fasta_ids id.map protein.fasta
$MAKERBIN/map_fasta_ids id.map transcript.fasta

# cd $OUT_DIR/interproscan
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
perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 $GFF_FILE > assembly.all.maker.renamed.gff.AED.txt
# plot the AED values. 
# Question: Are most of your genes in the range 0-0.5 AED?

# Update the gff file with InterProScan results and filter it for quality
$MAKERBIN/ipr_update_gff $GFF_FILE $IPR_FILE > ${GFF_FILE}.renamed.iprscan.gff

# step 4: Filter the GFF File for Quality
# Filter the GFF file based on the AED values <= 0.5 using Custom AED Threshold "-a"
perl $MAKERBIN/quality_filter.pl -a 0.5 ${GFF_FILE}.renamed.iprscan.gff > ${GFF_FILE}_iprscan_quality_filtered.gff

# In the above command: -s  Prints transcripts with an AED <1 and/or Pfam domain if in gff3 
# -a which was used print transcripts with AED below 0.5
## Note: When you do QC of your gene models, you will see that AED <1 is not sufficient. We should rather have a script with AED <0.5


# The gff also contains other features like Repeats, and match hints from different sources of evidence
# Let's see what are the different types of features in the gff file
cut -f3 ${GFF_FILE}_iprscan_quality_filtered.gff | sort | uniq

# We only want to keep gene features in the third column of the gff file
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" ${GFF_FILE}_iprscan_quality_filtered.gff > filtered.genes.renamed.gff3
cut -f3 filtered.genes.renamed.gff3 | sort | uniq

# We need to add back the gff3 header to the filtered gff file so that it can be used by other tools
grep "^#" ${GFF_FILE}_iprscan_quality_filtered.gff > header.txt
cat header.txt filtered.genes.renamed.gff3 > filtered.genes.renamed.final.gff3

# Get the names of remaining mRNAs and extract them from the transcript and and their proteins from the protein files
grep -P "\tmRNA\t" filtered.genes.renamed.final.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//g' > mRNA_list.txt
faSomeRecords $TRANSCRIPT_FILE mRNA_list.txt transcript.filtered.fasta
faSomeRecords $PROTEIN_FILE mRNA_list.txt protein.filtered.fasta