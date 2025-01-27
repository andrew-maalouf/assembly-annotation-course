#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=annotation_filt
#SBATCH --time=3-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_itol_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_itol_%j.e

# load modules


# set variables
WORK_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/maker
OUT_DIR=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
REXDB_COPIA=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Copia_sequences.fa.rexdb-plant.cls.tsv
REXDB_GIPSY=/data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Gypsy_sequences.fa.rexdb-plant.cls.tsv
SUMS=/data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation/hifiasm_output.fa.mod.EDTA.anno/hifiasm_output.fa.mod.EDTA.TEanno.sum
REXDB_BRASS_COPIA=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/brass_TEsorter/Brass_Copia_sequences.fa.rexdb-plant.cls.tsv
REXDB_BRASS_GYPSY=/data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/brass_TEsorter/Brass_Gypsy_sequences.fa.rexdb-plant.cls.tsv
GUIDE_COLORS=/data/users/amaalouf/transcriptome_assembly/annotation/output/filtering_refining_annotation/itol/color_guide.txt

# create directory and enter it
mkdir $OUT_DIR/itol
cd $OUT_DIR/itol


# load colors from guide_colors.txt file to assign each clade to a specifc color
declare -A COLORS
while read -r CLADE COLOR; do
    COLORS["$CLADE"]="$COLOR"
done < "$GUIDE_COLORS"

#########################
# STEP 7
#########################

# for Gypsy

# cut -f4 Gypsy_sequences.fa.rexdb-plant.cls.tsv | sort | uniq
# output: Athila; Clade (HEADER TO REMOVE) ; CRM; Reina; Retand; Tekay
# attention: the header "clade" will be included, so i will manually delete it

# extract unique clade names and generate annotations for Gypsy
cut -f4 $REXDB_GIPSY | sort | uniq | while read -r CLADE; do
    # get the color for the current clade from the colors guide array
    COLOR=${COLORS["$CLADE"]}
    
    # if no color is found, skip to the next clade
    if [[ -z "$COLOR" ]]; then
        echo "No color found for clade '$CLADE' in $GUIDE_COLORS."
        continue
    fi

    # add "RT" to the clade name
    CLADE_RT="${CLADE} RT"

    # extract all TE IDs for this clade and format for itol
    grep -e "$CLADE" $REXDB_GIPSY | cut -f1 | sed 's/:/_/' | sed 's/#.*//' | while read -r TE_ID; do
        echo "$TE_ID $COLOR $CLADE_RT" >> Gypsy_ID.txt
    done
done

# for gypsy brass
# cut -f4 /data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/brass_TEsorter/Brass_Gypsy_sequences.fa.rexdb-plant.cls.tsv | sort | uniq
# output:Athila; Clade; CRM; Galadriel; Reina; Retand; Tekay; unknown
# extract unique clade names and generate annotations for Gypsy
cut -f4 $REXDB_BRASS_GYPSY | sort | uniq | while read -r CLADE; do
    # get the color for the current clade from the colors guide array
    COLOR=${COLORS["$CLADE"]}
    
    # if no color is found, skip to the next clade
    if [[ -z "$COLOR" ]]; then
        echo "No color found for clade '$CLADE' in $GUIDE_COLORS."
        continue
    fi

    # add "RT" to the clade name
    CLADE_RT="${CLADE} RT"

    # extract all TE IDs for this clade and format for itol
    grep -e "$CLADE" $REXDB_BRASS_GYPSY | cut -f1 | sed 's/:/_/' | sed 's/#.*//' | while read -r TE_ID; do
        echo "$TE_ID $COLOR $CLADE_RT" >> Brass_Gypsy_ID.txt
    done
done

# for Copia

# cut -f4 Copia_sequences.fa.rexdb-plant.cls.tsv | sort | uniq
# output : Ale; Alesia; Bianca; Clade (HEADER TO REMOVE); Ivana; SIRE ;Tork

# extract unique clade names and generate annotations for Gypsy
cut -f4 $REXDB_COPIA | sort | uniq | while read -r CLADE; do
    # get the color for the current clade from the colors guide array
    COLOR=${COLORS["$CLADE"]}
    
    # if no color is found, skip to the next clade
    if [[ -z "$COLOR" ]]; then
        echo "No color found for clade '$CLADE' in $GUIDE_COLORS."
        continue
    fi

    # add "RT" to the clade name
    CLADE_RT="${CLADE} RT"

    # extract all TE IDs for this clade and format for itol
    grep -e "$CLADE" $REXDB_COPIA | cut -f1 | sed 's/:/_/' | sed 's/#.*//' | while read -r TE_ID; do
        echo "$TE_ID $COLOR $CLADE_RT" >> Copia_ID.txt
    done
done

# for copia brass
# cut -f4 /data/users/amaalouf/transcriptome_assembly/annotation/output/phylogenetic_analysis/brass_TEsorter/Brass_Copia_sequences.fa.rexdb-plant.cls.tsv | sort | uniq
# output: Ale, Alesia;Angela;Bianca;Clade (REMOVE);Ikeros; Ivana; SIRE; TAR;Tork
# extract unique clade names and generate annotations for Gypsy
cut -f4 $REXDB_BRASS_COPIA | sort | uniq | while read -r CLADE; do
    # get the color for the current clade from the colors guide array
    COLOR=${COLORS["$CLADE"]}
    
    # if no color is found, skip to the next clade
    if [[ -z "$COLOR" ]]; then
        echo "No color found for clade '$CLADE' in $GUIDE_COLORS."
        continue
    fi

    # add "RT" to the clade name
    CLADE_RT="${CLADE} RT"

    # extract all TE IDs for this clade and format for itol
    grep -e "$CLADE" $REXDB_BRASS_COPIA | cut -f1 | sed 's/:/_/' | sed 's/#.*//' | while read -r TE_ID; do
        echo "$TE_ID $COLOR $CLADE_RT" >> Brass_Copia_ID.txt
    done
done

#########################
# STEP 8
#########################
# for gypsy

# Extract the TE IDs (first column) from the ID_FILE
cut -d ' ' -f1 Gypsy_ID.txt | sort | uniq | while read TE_ID; do
    # search for each TE ID in the TEanno summary file and get the abundance/count column
    ABUNDANCE=$(grep -Fw "$TE_ID" $SUMS | awk '{print $2}')
    
    # if abundance data is found, add it to the output file
    if [[ ! -z "$ABUNDANCE" ]]; then
        echo "${TE_ID},${ABUNDANCE}" >> abundance_gypsy.txt
    else
        echo "Abundance not found for Gypsy TE_ID $TE_ID"
    fi
done

# for copia

# extract the TE IDs (first column) from the ID text file
cut -d ' ' -f1 Copia_ID.txt | sort | uniq | while read TE_ID; do
    # search for each TE ID in the TEanno summary file and get the abundance/count column
    ABUNDANCE=$(grep -Fw "$TE_ID" $SUMS | awk '{print $2}')
    
    # if abundance data is found, add it to the output file
    if [[ ! -z "$ABUNDANCE" ]]; then
        echo "${TE_ID},${ABUNDANCE}" >> abundance_copia.txt
    else
        echo "Abundance not found for Copia TE_ID $TE_ID"
    fi
done