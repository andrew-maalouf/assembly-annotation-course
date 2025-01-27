library(data.table)
library(tidyverse)


# Load the annotation
print(1+1)
annotation <- fread("/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/filtered.genes.renamed.final.gff3", header = FALSE, sep = "\t")
bed_genes <- annotation %>%
    filter(V3 == "gene") %>%
    select(V1, V4, V5, V9) %>%
    mutate(gene_id = as.character(str_extract(V9, "ID=[^;]*"))) %>%
    mutate(gene_id = as.character(str_replace(gene_id, "ID=", ""))) %>%
    select(-V9)

top20_scaff <- fread("/data/users/amaalouf/transcriptome_assembly/assemblies/hifiasm_assembly/hifiasm_output.fa.fai", header = FALSE, sep = "\t") %>%
    select(V1, V2) %>%
    arrange(desc(V2)) %>%
    head(20)

# Write the bed file
bed_genes <- bed_genes %>%
    filter(V1 %in% top20_scaff$V1)

gene_id <- bed_genes$gene_id
write.table(gene_id, "genespace_genes.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)
# Load the longest protein sequences
longest_proteins <- "/data/users/amaalouf/transcriptome_assembly/annotation/output/maker/final/longest_proteins.fasta"

# make a genespace specific directory
if (!dir.exists("genespace")) {
    dir.create("genespace")
}
if (!dir.exists("genespace/bed")) {
    dir.create("genespace/bed")
}
if (!dir.exists("genespace/peptide")) {
    dir.create("genespace/peptide")
}

write.table(bed_genes, "genespace/bed/genome1.bed", sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)

# remove "-R.*" from fasta headers of proteins, to get only gene IDs
system(paste("sed 's/-R.*//' ", longest_proteins, " > genome1_peptide.fa", sep = ""))
# filter to select only proteins of the top 20 scaffolds
system("faSomeRecords genome1_peptide.fa genespace_genes.txt genespace/peptide/genome1.fa")

system("cp /data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10.bed genespace/bed/")
system("cp /data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10.fa genespace/peptide/")
