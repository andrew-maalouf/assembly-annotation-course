# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)

# function to read file and add tag
read_add_accession_column <- function(file_path, tag) {
 
  # Read the CSV file without the header (skip the first line)
  df <- read.delim(file_path, header = TRUE, stringsAsFactors = TRUE, sep = "\t", fill = TRUE, comment.char = "")
  
  # Append the 'Accession' column with the tag value
  df$Accession <- tag
  
  # Return the modified dataframe with the added 'Accession' column
  return(df[,c(1,4,8,9)])
}



copia_lu <- read_add_accession_column("copia_Lu_1.tsv", "Lu-1")
copia_o <- read_add_accession_column("copia_Kar1.tsv", "Kar-1")
copia_l <- read_add_accession_column("copia_Leo.tsv", "St-0")
copia <- rbind(copia_lu, copia_o, copia_l)

gypsy_lu <- read_add_accession_column("gypsy_Lu_1.tsv", "Lu-1")
gypsy_o <- read_add_accession_column("gypsy_Kar1.tsv", "Kar-1")
gypsy_l <- read_add_accession_column("gypsy_Leo.tsv", "St-0")
gypsy <- rbind(gypsy_lu, gypsy_o, gypsy_l)


# Step 1: Summing up the numbers for each clade by accession
copia_summarized <- copia %>%
  group_by(Accession, Clade) %>%
  summarise(total_number = sum(abundance_count), .groups = "drop")

gypsy_summarized <- gypsy %>%
  group_by(Accession, Clade) %>%
  summarise(total_number = sum(abundance_count), .groups = "drop")

# Create a complete list of all combinations of Accession and Clade
all_combinations <- expand.grid(
  Accession = unique(copia$Accession),
  Clade = unique(copia$Clade)
)

# Merge the summarized data with all possible combinations of Accession and Clade
copia_summarized_complete <- all_combinations %>%
  left_join(copia_summarized, by = c("Accession", "Clade")) %>%
  replace_na(list(total_number = 0))  # Replace NAs with 0s where data is missing

# Create a complete list of all combinations of Accession and Clade
all_combinations <- expand.grid(
  Accession = unique(gypsy$Accession),
  Clade = unique(gypsy$Clade)
)

gypsy_summarized_complete <- all_combinations %>%
  left_join(gypsy_summarized, by = c("Accession", "Clade")) %>%
  replace_na(list(total_number = 0))  # Replace NAs with 0s where data is missing

# Step 2: Create a boxplot
barplot_copia_clade <- ggplot(copia_summarized_complete, aes(x = Clade, y = total_number, fill = Accession)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.7) +  # Create bar plot with dodged bars for each Accession
  scale_fill_brewer(palette = "Set2") +  # Set color palette for bars
  scale_color_brewer(palette = "Set2") +  # Optional, for color customization
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  ) +
  labs(
    title = "Summed TE Clade Abundance Across Accessions",
    x = "TE Clade",
    y = "Total Count of TEs",
    fill = "Accession",
    color = "Accession"
  )

barplot_gypsy_clade <- ggplot(gypsy_summarized_complete, aes(x = Clade, y = total_number, fill = Accession)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.7) +  # Create bar plot with dodged bars for each Accession
  scale_fill_brewer(palette = "Set2") +  # Set color palette for bars
  scale_color_brewer(palette = "Set2") +  # Optional, for color customization
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  ) +
  labs(
    title = "Summed TE Clade Abundance Across Accessions",
    x = "TE Clade",
    y = "Total Count of TEs",
    fill = "Accession",
    color = "Accession"
  )



# Print the plot
print(barplot_copia_clade)
print(barplot_gypsy_clade)
