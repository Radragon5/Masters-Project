library(data.table)

# Clear global environment
rm(list=ls())

# Define parameters
CADD_input_path  <- "CADD Chunks/CADD SNPs.vcf"
CADD_output_path <- "CADD Chunks/CADD_SNPs.vcf"
chunk_size <- 1000

# Read CADD data
cadd <- data.table::fread(CADD_input_path, stringsAsFactors = FALSE)
head (cadd)

# Write table into multiple files
num_chunks <- ceiling(nrow(cadd) / chunk_size)

for (i in 1:num_chunks) {
  start_row <- ((i - 1) * chunk_size) + 1
  end_row <- min(i * chunk_size, nrow(cadd))
  chunk <- cadd[start_row:end_row, ]
  
  chunk_file <- sprintf("%s_chunk_%03d.vcf", tools::file_path_sans_ext(CADD_output_path), i)
  write.table(chunk, file = chunk_file, quote = FALSE, sep = '\t', 
              row.names = FALSE, col.names = FALSE)}
