library(reshape2)
library(hrbrthemes)
library(tidyverse)
library(data.table)


# get data from parameter in EDTA_output assembly.fasta.mod.EDTA.anno/assembly.fasta.mod.out.landscape.Div.Rname.tab
data="hifiasm_output.fa.mod.out.landscape.Div.Rname.tab"

rep_table <- fread(data, header = FALSE, sep = "\t")
rep_table %>% head()
# How does the data look like?

colnames(rep_table) <- c("Rname", "Rclass", "Rfam", 1:50)
rep_table <- rep_table%>%filter(Rfam!="unknown")
rep_table$fam <- paste(rep_table$Rclass, rep_table$Rfam, sep = "/")

table(rep_table$fam)
# How many elements are there in each Superfamily?

rep_table.m <- melt(rep_table)

rep_table.m <- rep_table.m[-c(which(rep_table.m$variable == 1)), ] # remove the peak at 1, as the library sequences are copies in the genome, they inflate this low divergence peak

# Arrange the data so that they are in the following order:
# LTR/Copia, LTR/Gypsy, all types of DNA transposons (TIR transposons), DNA/Helitron, all types of MITES
rep_table.m$fam <- factor(rep_table.m$fam, levels = c(
  "LTR/Copia", "LTR/Gypsy", "DNA/DTA", "DNA/DTC", "DNA/DTH", "DNA/DTM", "DNA/DTT", "DNA/Helitron",
  "MITE/DTA", "MITE/DTC", "MITE/DTH", "MITE/DTM", "LINE/L1"
))

# NOTE: Check that all the superfamilies in your dataset are included above

rep_table.m$distance <- as.numeric(rep_table.m$variable)  / 100 # as it is percent divergence

# Question:
# rep_table.m$age <- ??? # Calculate using the substitution rate and the formula provided in the tutorial
r <- 8.22 * 10^(-9)
rep_table.m$age <- rep_table.m$distance / (2*r)

# options(scipen = 999)

# remove helitrons as EDTA is not able to annotate them properly (https://github.com/oushujun/EDTA/wiki/Making-sense-of-EDTA-usage-and-outputs---Q&A)
rep_table.m <- rep_table.m %>% filter(fam != "DNA/Helitron")

ggplot(rep_table.m, aes(fill = fam, x = distance, weight = value/1000000)) +
  geom_bar() +
  cowplot::theme_cowplot() +
  scale_fill_brewer(palette = "Paired") +
  xlab("Distance") +
  ylab("Sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), plot.title = element_text(hjust = 0.5))

ggsave(filename = "plot_div.pdf", width = 10, height = 5, useDingbats = F)

# plot age
aa <- rep_table.m[rep_table.m$Rfam=="Copia",]

aap <- ggplot(aa, aes(x = age)) +
  geom_histogram(binwidth = 500000, color = "#faf5f5", fill = "#e8736b") +  # Smaller bin width for more bins
  geom_vline(aes(xintercept = mean(age)), color = "black", size = 0.5) +    # Mean line
  geom_vline(aes(xintercept = median(age)), color = "black", linetype = "dashed", size = 0.3) +  # Median line
  geom_density(aes(y = after_stat(count)), linetype = "dashed", alpha = 0.4, fill = "#FF6666") +  # Match density to count
  xlim(0, NA) +                                                             # Start x-axis at 0
  ylim(0, 5.0e-08) +                                                        # Set y-axis limit
  theme_light() +                                                           # Apply light theme
  labs(
    title = "LTR Copia Insertion Time",
    x = "Years",
    y = "Number of Elements"
  )

aap=ggplot(aa,aes(age))+geom_histogram(aes(age, ..density..),binwidth = 1000, color = "#faf5f5", fill = "#e8736b") + 
  geom_vline(aes(xintercept=mean(age)), col = "black", size=0.5)+
  geom_vline(aes(xintercept=median(age)), col = "black",linetype="dashed", size=0.3)+
  geom_density (linetype="dashed", alpha=.4, fill="#FF6666")+xlim(0,NA)+ylim(0, 5.0e-08) +theme_light()+
  labs(title="LTR Copia insertion time",x="Years", y = "Number of Elements", alpha=.6, hjust = 0.5)

pdf(file="AGE-Copia.pdf",width=5,height=3)
aap
dev.off()

bin_width <- (max(aa$age) - min(aa$age)) / 30  # Adjust the number of bins (e.g., 30)

# Define breaks using the calculated bin width
breaks <- seq(0, max(aa$age) + bin_width, by = bin_width)

# Create a histogram with density scaling
pdf(file = "AGE-Copia_BaseR.pdf", width = 5, height = 3)

hist(
  aa$age,
  breaks = breaks,
  col = "#e8736b",      # Fill color
  border = "#faf5f5",   # Border color
  xlim = c(0, max(aa$age)), # Set x-axis limits
  ylim = c(0, 5e-8),    # Set y-axis limits (adjust as needed)
  main = "LTR Copia Insertion Time", # Title
  xlab = "Years",       # X-axis label
  ylab = "Density",     # Y-axis label
  freq = FALSE          # Normalize the histogram to density
)

# Add mean and median lines
abline(v = mean(aa$age), col = "black", lwd = 2)               # Mean
abline(v = median(aa$age), col = "black", lty = 2, lwd = 2)    # Median

dev.off()


# Question: Now can you get separate plots for each superfamily? Use violin plots for this
# Create a violin plot for each superfamily (facet by 'fam')
# Convert fam to a factor to ensure they appear in order on the x-axis
rep_table.m$fam <- factor(rep_table.m$fam, levels = c(
  "LTR/Copia", "LTR/Gypsy", "DNA/DTA", "DNA/DTC", "DNA/DTH", "DNA/DTM", "DNA/DTT", "DNA/Helitron",
  "MITE/DTA", "MITE/DTC", "MITE/DTH", "MITE/DTM", "LINE/L1"
))

# Remove rows where distance is NA or less than 0 to avoid issues with geom_violin
rep_table.m <- rep_table.m %>% filter(!is.na(distance) & distance >= 0)

# Remove rows where distance is NA or less than 0 to avoid issues with geom_violin
rep_table.m <- rep_table.m %>% filter(!is.na(distance) & distance >= 0)

# Create a violin plot for each superfamily, ensuring all are on the same x-axis
ggplot(rep_table.m, aes(x = fam, y = distance, fill = fam)) +
  # Adjust violin plot width based on the count of points at each distance (scale = "count")
  geom_violin(trim = FALSE, scale = "area", width = 0.7) +  # Violins reflect data density
  # Add jitter with fixed dot size for visual representation
  geom_jitter(size = 0.2, color = "black", alpha = 0.5, width = 0.2) +  # Fixed dot size
  scale_fill_brewer(palette = "Paired") +
  scale_color_brewer(palette = "Paired") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), 
        plot.title = element_text(hjust = 0.5),
        axis.title.x = element_blank()) +
  xlab("Superfamily") +
  ylab("Divergence (%)") +
  ggtitle("Divergence Distribution by Superfamily") +
  # Set y-axis limits to start at 0
  ylim(0, NA) +  # This sets the lower bound of y-axis to 0
  theme(axis.text.x = element_text(angle = 90, hjust = 1))  # Ensure labels are readable

ggsave(filename = "violinplot_div.pdf", width = 10, height = 5, useDingbats = F)




# Calculate mean distance per clade
mean_distance <- rep_table.m %>%
  group_by(fam) %>%
  summarise(mean_distance = mean(distance, na.rm = TRUE))

# Create a violin plot with a vertical line for the mean distance for each clade
ggplot(rep_table.m, aes(x = fam, y = distance, fill = fam)) +
  geom_violin(trim = FALSE, scale = "area", width = 0.7) +  # Adjust width for density
  geom_jitter(aes(size = 0.2), color = "black", alpha = 0.5, width = 0.2) +  # Add jitter for dots
  geom_vline(data = mean_distance, aes(xintercept = mean_distance, color = fam), 
             linetype = "dashed", size = 1) +  # Add dashed line for mean
  scale_fill_brewer(palette = "Paired") +
  scale_color_brewer(palette = "Paired") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 9, hjust = 1), 
        plot.title = element_text(hjust = 0.5),
        axis.title.x = element_blank()) +
  xlab("Superfamily") +
  ylab("Divergence (%)") +
  ggtitle("Divergence Distribution by Superfamily with Mean Line") +
  ylim(0, NA)  # Cut y-axis at 0 to avoid negative values

# Question: Do you have other clades of LTR-RTs not present in the full length elements? 
# You have to use the TEsorter output to answer this question


# use formula for age
# substitution rate r
r <- 8.22 * 10^(-9)
T <- unique(rep_table.m$distance) / (2*r)
plot(x=unique(rep_table.m$distance), 
     y=T, 
     type="l",
     xlab = "Distance",
     ylab="T")
