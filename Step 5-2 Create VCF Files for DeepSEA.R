library(data.table)

# Clear global environment
rm(list=ls())

# Define parameters
SNP_input_path <- "SNP Causal and Drug Relationahips with extras added.csv"
VCF_output_path <- "DeepSEA Upload File.vcf"
chunk_size <- 1000

# Read SNP data
snps <- data.table::fread(SNP_input_path, header = TRUE, stringsAsFactors = FALSE)

# Create separate columns for chromosome, position and Allele
vcf <- snps[,c("CHROM","POSITION","REF","ALT") := tstrsplit(SNP,":",fixed=TRUE)]
vcf$GENE <- "."
vcf$CHROM <- paste0("chr",snps$CHROM)
vcf <- vcf[,c("CHROM","POSITION","GENE","REF","ALT")]
head (vcf)

# Write table into multiple files
num_chunks <- ceiling(nrow(vcf) / chunk_size)

for (i in 1:num_chunks) {
  start_row <- ((i - 1) * chunk_size) + 1
  end_row <- min(i * chunk_size, nrow(vcf))
  chunk <- vcf[start_row:end_row, ]
  
  chunk_file <- sprintf("%s_chunk_%03d.vcf", tools::file_path_sans_ext(VCF_output_path), i)
  write.table(chunk, file = chunk_file, quote = FALSE, sep = '\t', 
              row.names = FALSE, col.names = FALSE)
}