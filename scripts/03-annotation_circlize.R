# Load necessary libraries

library(circlize)
library(tidyverse)
library(ComplexHeatmap)
library(stringr)

setwd("C:/Users/user/OneDrive - Universitaet Bern/UniBe/Semester_3/Fribourg/Annotation/scripts")


# Load GFF3 and clade data files
gff_file <- "hifiasm_output.fa.mod.EDTA.TEanno.gff3"
gff_data <- read.table(gff_file, header = FALSE, sep = "\t", stringsAsFactors = FALSE)
cls_file <- "Gypsy_sequences.fa.rexdb-plant.cls.tsv"
cls_data <- read.table(cls_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE, comment.char = "")
cls_file2 <- "Copia_sequences.fa.rexdb-plant.cls.tsv"
cls_data2 <- read.table(cls_file2, header = TRUE, sep = "\t", stringsAsFactors = FALSE, comment.char = "")

# Load and prepare the custom ideogram data from the `.fai` file
fai_file <- "hifiasm_output.fa.fai"
custom_ideogram <- read.table(fai_file, header = FALSE, stringsAsFactors = FALSE) %>%
  rename(chr = V1, end = V2) %>%
  mutate(start = 1) %>%
  select(chr, start, end) %>%
  arrange(desc(end)) %>%
  slice(1:10)  # Use top 10 longest scaffolds

custom_ideogram$chr <- paste0("chr", custom_ideogram$chr)
gff_data$V1 <- paste0("chr", gff_data$V1)

# Start PDF
pdf("circlize_plot.pdf", width = 10, height = 10)

# Initialize the circos plot with the custom ideogram
circos.genomicInitialize(custom_ideogram, plotType = c("axis", "labels"))

# Define superfamilies and clades with corresponding colors
superfamilies <- c("Gypsy_LTR_retrotransposon", "Copia_LTR_retrotransposon", 
                   "Mutator_TIR_transposon")# "CACTA_TIR_transposon", "L1_LINE_retrotransposon")
clades <- c("CRM", "Athila", "Ale")

superfamily_colors <- c("cornflowerblue", "chartreuse3", "darkred") #, "darkorange", "coral4")
clade_colors <- c("darkorchid4", "deeppink2", "darkorange")

# Function to filter GFF data by superfamily
filter_superfamily <- function(data, superfamily, ideogram) {
  data %>%
    filter(V3 == superfamily) %>%
    transmute(chrom = V1, start = V4, end = V5) %>%
    filter(chrom %in% ideogram$chr)
}

# Prepare density data for each superfamily and plot for each of them
for (i in seq_along(superfamilies)) {
  track_data <- filter_superfamily(gff_data, superfamilies[i], custom_ideogram)
  circos.genomicDensity(track_data, col = superfamily_colors[i], track.height = 0.1, window.size = 5e4)
}

# Extract TE IDs from gff_data based on "Name="
gff_data <- gff_data %>%
  mutate(TE_ID = str_extract(V9, "(?<=Name=)[^;]+"))

# Extract TE name from cls_data
cls_data <- cls_data %>%
  mutate(TE_ID = str_extract(X.TE, "^[^#]+"))

# Extract TE name from cls_data
cls_data2 <- cls_data2 %>%
  mutate(TE_ID = str_extract(X.TE, "^[^#]+"))

# Function to filter and plot density for specified clade
plot_clade_density <- function(clade, color, cls_data) {
  cls_data <- cls_data
  clade_cls_data <- cls_data %>%
    filter(Clade == clade) %>%
    pull(TE_ID)
  
  clade_gff_data <- gff_data %>%
    filter(TE_ID %in% clade_cls_data) %>%
    transmute(chrom = V1, start = V4, end = V5) %>%
    filter(chrom %in% custom_ideogram$chr) %>%
    na.omit()
  
  if (nrow(clade_gff_data) > 0) {
    circos.genomicDensity(clade_gff_data, count_by = "number", col = color, track.height = 0.07, window.size = 1e5)
  } else {
    message(paste("No data found for", clade, "clade in gff_data."))
  }
}

# Plot density for each clade with corresponding colors
plot_clade_density("CRM", clade_colors[1], cls_data)
plot_clade_density("Athila", clade_colors[2], cls_data)
plot_clade_density("Ale", clade_colors[3], cls_data2)

# Add legend for colors without a box outline
legend("topright", legend = c(superfamilies, clades), 
       fill = c(superfamily_colors, clade_colors), 
       title = "", cex = 0.8, bty = "n")

# Clear the circos plot after use
circos.clear()

# Close PDF output
dev.off()
