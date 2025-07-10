# Clear global environment
rm(list=ls())

count_genes_by_score <- function(gwas) {
  thresholds <- seq(0, 1, by = 0.05)
  result <- data.frame(Threshold = numeric(), Unique_Genes = integer())
  
  for (t in thresholds) {
    count <- length(unique(gwas$Gene_Symbol[gwas$Variant_Score > t]))
    result <- rbind(result, data.frame(Threshold = t, Unique_Genes = count))
  }
  
  return(result)
}

process_gwas_file <- function(input_file1, threshold = 0.75) {
  # Read the file
  gwas <- data.table::fread(input_file1)
  gwas <- gwas[!(is.na(Gene_Symbol) | Gene_Symbol == "")] # remove blank gene names
  
  # Print the input file name
  print(input_file1)
  
  # Run the summary count function
  print(count_genes_by_score(gwas))
  
  # Extract known genes above threshold
  known_genes <- unique(gwas$Gene_Symbol[gwas$Variant_Score > threshold])
  known_genes <- known_genes[known_genes != "" & !is.na(known_genes)]
  known_genes <- sort(known_genes)
  
  return(known_genes)
}

# Define File names
input_file1  <- "known_variants_annotated_to_genes.csv"
input_file2  <- "novel_variants_annotated_to_genes.csv"
output_file1 <- "known_variants_unique_genes.csv"
output_file2 <- "novel_variants_unique_genes.csv"

# Read known variants and analyse
known_genes = process_gwas_file(input_file1,-1.0) # Get all of them

# Read novel variants and analyse
novel_genes = process_gwas_file(input_file2,0.7)

# Save results
write.table(known_genes, file = output_file1, sep=",", row.names = FALSE, col.names = FALSE)
write.table(novel_genes, file = output_file2, sep=",", row.names = FALSE, col.names = FALSE)
