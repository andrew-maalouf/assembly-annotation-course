#!/usr/bin/env bash

#SBATCH --partition=pibu_el8

# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation
GFF3_FILE=/data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation/hifiasm_output.fa.mod.EDTA.raw/hifiasm_output.fa.mod.LTR.intact.raw.gff3
CLADE_FILE=/data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation/hifiasm_output.fa.mod.EDTA.raw/LTR/hifiasm_output.fa.mod.LTR.intact.fa.ori.dusted.cln.rexdb.cls.tsv
OUT_PERC=/data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation/step1.txt

# step 1
# Extract Percent identity of two LTRs from full length LTR-RTs
# needed information is found on column 9 ($9) on lines where 'LRT' is found
# column 9 consists of different attributes separated by ";"
# attribute of interest looks like this: "...;ltr_identity=XX.XX%;..."
# split attributes in column 9 separated by semicolon
# go over each each attribute to find exact attribute where 'ltr_identity' is present
# when present, split this attribute on "="
# the right part will be the percentage
# at the end, print name (also from column 9) and the percent identity value
awk -F'\t' '/LTR/ {
    split($9, attributes, ";")
    ltr_identity = ""
    name_value = ""
    for (i in attributes) {
        if (attributes[i] ~ /ltr_identity=/) {
            split(attributes[i], percent_identity, "=")
            ltr_identity = percent_identity[2]
        }
        if (attributes[i] ~ /Name=/) {
            split(attributes[i], name_attr, "=")
            name_value = name_attr[2]
        }
    }
    if (ltr_identity != "" && name_value != "") {
        print name_value "\t" ltr_identity
    }
}' $GFF3_FILE > $OUT_PERC

#step 2
# split them into clades
