library(dplyr)
library(data.table)

# Clear global environment
rm(list=ls())

# Define all paths
full_gwas_path <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/GCST90002247 MAGIC/MAGIC1000G_HbA1c_TA.tsv"
lead_snps_path <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/Lead SNPs.csv"
output_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/Result Data/SNP Within 500kb.csv"

# Set the window size 500kb
window_size <- 500000

# Read input data - recommend using data.table package functions in R for large data
lead_snps <- fread(lead_snps_path)
# Format of lead snps:
# head(lead_snps)
# chromosome position
# 1 3691727 
# 1 25529038 
# 1 25703156 

full_gwas <- fread(full_gwas_path)

# Ensure chromosome columns are integers
lead_snps$chromosome <- as.integer(lead_snps$chromosome)
full_gwas$chromosome <- as.integer(full_gwas$chromosome)

# Adding p-value filter depending on output results size
full_gwas <- filter(full_gwas, het_p_value < 0.01)

# Filter SNPs within the window
results <- data.frame()

results <- lapply(1:nrow(lead_snps), function(i) {
  lead <- lead_snps[i, ]
  lead_chr <- lead$chromosome
  lead_pos <- lead$position
  cat("Processing lead SNP", i, "out of", nrow(lead_snps), "on chr", lead_chr, "at position", lead_pos, "\n")
  
  # Filter the GWAS data based on the chromosome and the ±500kb window
  nearby <- full_gwas %>%
    filter(
      chromosome == lead_chr,  # Same chromosome
      base_pair_location >= (lead_pos - window_size),  # Within the lower bound
      base_pair_location <= (lead_pos + window_size)   # Within the upper bound
    ) %>%
    mutate(
      lead_chr = lead_chr,
      lead_pos = lead_pos
    )

  cat("  SNPs found in locus:", nrow(nearby), "\n")
  
  return(nearby)
})

# Combine all the results
final_results <- do.call(rbind, results)
final_results$SNP <- paste0(final_results$chromosome, ":", final_results$base_pair_location, ":", final_results$other_allele, ":", final_results$effect_allele)
all_snps_in_loci <- dplyr::select(final_results, SNP)
all_snps_in_loci <- distinct(all_snps_in_loci)                    # Remove Duplicates
all_snps_in_loci <- filter(all_snps_in_loci, !grepl("I:D", SNP))  # Remove Indels

# Write output
data.table::fwrite(all_snps_in_loci, output_path)
