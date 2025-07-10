library(dplyr)
library(data.table)        

# Clear global environment
rm(list=ls())

# Define all paths
vep_input_path  <- "CADD Results/CADD Results.csv"
vep_output_path <- "Results - Reformatted.csv"

# Read in the input file and rename pesky chrom column
vepinput <- data.table::fread(vep_input_path, stringsAsFactors = FALSE)
names(vepinput)[names(vepinput) == '#Chrom'] <- 'Chrom'
head(vepinput)

# Construct SNP Column and remove unwanted columns
vepinput$SNP <- paste(vepinput$Chrom, vepinput$Pos, vepinput$Ref,vepinput$Alt,sep=":")
setcolorder(vepinput, c("SNP", setdiff(names(vepinput),"SNP")))
vepoutput <- vepinput[,-c("Chrom","Pos","Ref","Alt","RawScore")]
head(vepoutput)

# Write result
write.table(vepoutput, file=vep_output_path, quote=FALSE, sep=',', row.names = FALSE)