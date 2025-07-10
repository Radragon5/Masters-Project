library(data.table)

# Clear global environment
rm(list=ls())

# Define all paths
snp_input_path    <- "SNP Causal and Drug Relationahips with extras added.csv"
vep_input_path    <- "Results - Uncorrelated.csv"
model_output_path <- "Model Parameters Before Cleaning.csv"

# Read in the input files
snpinput <- data.table::fread(snp_input_path, header = TRUE, stringsAsFactors = FALSE)
vepinput <- data.table::fread(vep_input_path, header = TRUE, stringsAsFactors = FALSE)
print(ncol(vepinput))
print(nrow(vepinput))

# Change any "," in columna names to "_" so that we can use a csv file for output
setnames(vepinput, gsub(",", "_", names(vepinput)))

# merge snp and vep data
modeldata <- merge(snpinput,vepinput, by="SNP", all.x=TRUE)
#print(names(modeldata))
#print(columnstocheck)

# Remove any rows that have no data
columnstocheck <- names(modeldata)
columnstocheck <- columnstocheck[columnstocheck!="SNP" & columnstocheck!="RSID" & columnstocheck!="Source" & columnstocheck!="Causal_SNP" & columnstocheck!="Drugable_SNP"]
modeldata <- modeldata[rowSums(!is.na(modeldata[, ..columnstocheck])) > 0]
modeldata <- modeldata[rowSums(modeldata[, ..columnstocheck] != 0) > 0]
print(ncol(modeldata))
print(nrow(modeldata))

# Write result
write.table(modeldata, file=model_output_path, quote=FALSE, sep=',', row.names = FALSE)