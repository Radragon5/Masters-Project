#library(dplyr)
library(data.table)        

# Clear global environment
rm(list=ls())

# Define all paths
revel_input_path  <- "revel_with_transcript_ids"
revel_output_path <- "revel values.csv"

# Read in the input file 
revelinput <- data.table::fread(revel_input_path, stringsAsFactors = FALSE)
head(revelinput)

# Create output file
revelinput$SNP <- paste(revelinput$chr, revelinput$hg19_pos, revelinput$ref, revelinput$alt, sep=":")
reveloutput <- revelinput[,c("SNP", "REVEL")]
head(reveloutput)

# Write result
write.table(reveloutput, file=revel_output_path, quote=FALSE, sep=',', row.names = FALSE)