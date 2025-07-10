library(data.table)
library(ggplot2)

# Clear global environment
rm(list=ls())

# Define all paths
vep_input_path  <- "Combined Model Parameters After Pairwise Regression.csv"
vep_output_path <- "Combined Model Parameters After Missingness Test.csv"

# Read in the input file
modeldata <- data.table::fread(vep_input_path, header = TRUE, stringsAsFactors = FALSE)

# Get the first and last feature columns
first_feature_column = 6
last_feature_column = ncol(modeldata)

# Get missing counts
missing_percentage <- sapply(modeldata[,first_feature_column:last_feature_column], function(x) sum(is.na(x)) / nrow(modeldata) * 100)
head(missing_percentage)

# Bar plot of missing percentage per feature
df_missing <- data.frame(
  Feature = names(missing_percentage),
  MissingPercentage = missing_percentage
)

ggplot(df_missing, aes(x = reorder(Feature, -MissingPercentage), y = MissingPercentage)) +
  geom_bar(stat = "identity", fill = "skyblue", color = "black") +
  labs(title = "Missing Data Percentage by Feature", x = "Feature", y = "Missing Percentage (%)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1), plot.title = element_text(hjust = 0.5), plot.title.position = "plot", panel.grid = element_blank())
ggsave("missingness.png", width = 10, height = 6, dpi = 600)

# drop columns where missingness is > 25%
cols_to_drop <- names(missing_percentage[missing_percentage > 25])
print(paste("Dropping Colums: ",cols_to_drop))
modeldata <- modeldata[, -..cols_to_drop]

# Write result
write.table(modeldata, file=vep_output_path, quote=FALSE, sep=',', row.names = FALSE)