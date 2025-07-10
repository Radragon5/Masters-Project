library(data.table)

# Clear global environment
rm(list=ls())

# Define Parameters
deepsea_input_path    <- "../DeepSEA/Model Parameters Before Cleaning.csv"
revel_input_path <- "../REVEL/revel values.csv"
loeuf_input_path <- "../LOEUF/LOEUF from VEP.csv"
cadd_input_path <- "../CADD/Results - Reformatted.csv"
model_output_path <- "../Combined Result/Combined Model Parameters Before Cleaning.csv"
FirstColumnList <- c("SNP", "RSID", "Source", "Causal_SNP", "Drugable_SNP", "REVEL", "LOEUF", "CADD_PHRED")

# Read in the input files
deepsea <- data.table::fread(deepsea_input_path, header = TRUE, stringsAsFactors = FALSE)
revel <- data.table::fread(revel_input_path, header = TRUE, stringsAsFactors = FALSE)
loeuf <- data.table::fread(loeuf_input_path, header = TRUE, stringsAsFactors = FALSE)
cadd <- data.table::fread(cadd_input_path, header = TRUE, stringsAsFactors = FALSE)

# merge data
modeldata <- merge(deepsea, revel, by="SNP", all.x=TRUE)
modeldata <- merge(modeldata, loeuf[,c("SNP","LOEUF","CADD_PHRED")], by="SNP", all.x=TRUE)
modeldata <- merge(modeldata, cadd, by="SNP", all.x=TRUE)  # Data from VEP provides better coverage than data from CADD

# Sort Results
modeldata <- setcolorder(modeldata, c(FirstColumnList, sort(setdiff(names(modeldata), FirstColumnList))))
setorder(modeldata,"SNP")
head(modeldata)

# Write result
write.table(modeldata, file=model_output_path, quote=FALSE, sep=',', row.names = FALSE)