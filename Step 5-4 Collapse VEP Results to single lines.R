library(dplyr)
library(data.table)        

# Clear global environment
rm(list=ls())

# Define all paths
vep_input_path  <- "VCF Results/DeepSEA_Upload_File_FEATURE_seqclass.csv"
vep_output_path <- "Results - Collapsed.csv"

# Read in the input file and rename pesky chrom column
vepinput <- data.table::fread(vep_input_path, stringsAsFactors = FALSE)
names(vepinput)[names(vepinput) == '#chrom'] <- 'chrom'
print(nrow(vepinput))
print(ncol(vepinput))

# Construct SNP Column and remove unwanted columns
vepinput$SNP <- paste(sub("^chr","",vepinput$chrom), vepinput$position, vepinput$ref_allele,vepinput$alt_allele,sep=":")
setcolorder(vepinput, c("SNP", setdiff(names(vepinput),"SNP")))
vepoutput <- vepinput[,-c("chrom","position","id","ref_allele","alt_allele","strand","max_seq_class")]
print(colnames(vepoutput))

# Write result
write.table(vepoutput, file=vep_output_path, quote=FALSE, sep=',', row.names = FALSE)
print(ncol(vepoutput))