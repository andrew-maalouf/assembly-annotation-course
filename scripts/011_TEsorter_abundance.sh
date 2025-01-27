#!/usr/bin/env bash

#SBATCH --partition=pibu_el8
#SBATCH --job-name=tesorter_comp
#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --output=/data/users/amaalouf/transcriptome_assembly/output_error/output_tesorter_comp_%j.o
#SBATCH --error=/data/users/amaalouf/transcriptome_assembly/output_error/error_tesorter_comp_%j.e

# this script allows to add the count to each copia or gypsy sequence
# it requires $1: TEsorter tsv file; $2: assembly.mod.EDTA.TEanno.sum; $3: path/to/output_file.tsv

# get input arguments
tsv_file=$1
edta_sum_file=$2
output_file=$3

# check input files
if [[ ! -f $tsv_file ]]; then
    echo "Error: TSV file '$tsv_file' not found."
    exit 1
fi

if [[ ! -f $edta_sum_file ]]; then
    echo "Error: EDTA summary file '$edta_sum_file' not found."
    exit 1
fi

# create output directory if it doesn't exist
output_dir=$(dirname "$output_file")
mkdir -p "$output_dir"

# step 1: Preprocess EDTA summary file to extract main TE families and their abundances
lookup_file=$(mktemp)
grep -E '^\s*TE_' "$edta_sum_file" | awk '{print $1 "\t" $2}' > "$lookup_file"

# step 2: create associative array from the lookup file
declare -A abundance_map
while IFS=$'\t' read -r main_family abundance; do
    abundance_map["$main_family"]=$abundance
done < "$lookup_file"

# function to add abundance column
add_abundance_column() {
    # create a temporary file
    tmp_file=$(mktemp)

    # add header with the new column
    echo -e "$(head -1 "$tsv_file")\tabundance_count" > "$tmp_file"
    
    # process the TSV file line by line
    tail -n +2 "$tsv_file" | while IFS=$'\t' read -r line; do
        # extract TE family and main TE family
        te_family=$(echo "$line" | cut -f1)
        main_te_family=$(echo "$te_family" | cut -d '#' -f1)

        # check if the main TE family exists in the abundance_map
        abundance="${abundance_map[$main_te_family]:-0}"

        # append the line with abundance
        echo -e "$line\t$abundance" >> "$tmp_file"
    done

    # move the temp file to the output file
    mv "$tmp_file" "$output_file"
    echo "Output written to $output_file"
}

# run the function
add_abundance_column

# cleanup
rm -f "$lookup_file"


# example usage
# sbatch 011_TEsorter_abundance.sh /data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/Copia_sequences.fa.rexdb-plant.cls.tsv /data/users/amaalouf/transcriptome_assembly/annotation/output/EDTA_annotation/hifiasm_output.fa.mod.EDTA.anno/hifiasm_output.fa.mod.EDTA.TEanno.sum /data/users/amaalouf/transcriptome_assembly/annotation/output/TE_sorter/compare/copia_Lu_1.tsv