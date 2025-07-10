library(corrr)
library(corrplot)

# Clear global environment
rm(list=ls())

# Define all paths
snp_input_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/VEP Search Combined/SNP Causal and Drug Relationahips with extras added.csv"
vep_input_path    <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/VEP Search Combined/Results - Uncorrelated.csv"
model_output_path <- "C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/Data/VEP Search Combined/Model Parameters Before Cleaning.csv"

# Read in the input files
snpinput <- data.table::fread(snp_input_path, header = TRUE, stringsAsFactors = FALSE)
vepinput <- data.table::fread(vep_input_path, header = TRUE, stringsAsFactors = FALSE)
head(snpinput)
head(vepinput)

# merge snp and vep data
modeldata <- merge(snpinput,vepinput, by="SNP", all.x=TRUE)
print(names(modeldata))
columnstocheck <- names(modeldata)
columnstocheck <- columnstocheck[columnstocheck!="SNP" & columnstocheck!="RSID" & columnstocheck!="Source" & columnstocheck!="Causal_SNP" & columnstocheck!="Drugable_SNP"]
print(columnstocheck)

#modeldata <- modeldata[rowSums(!is.na(.SD))>0,, .SDcols = columnstocheck]
modeldata <- modeldata[rowSums(!is.na(modeldata[, ..columnstocheck])) > 0]
# Write result
write.table(modeldata, file=model_output_path, quote=FALSE, sep=',', row.names = FALSE)