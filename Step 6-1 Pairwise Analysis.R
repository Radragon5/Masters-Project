library(corrr)
library(corrplot)
library(data.table)

# Clear global environment
rm(list=ls())

# Define all paths
vep_input_path  <- "Combined Model Parameters Before Cleaning.csv"
vep_output_path <- "Combined Model Parameters After Pairwise Regression.csv"

# Read in the input file
vepinput <- data.table::fread(vep_input_path, header = TRUE, stringsAsFactors = FALSE)
print (ncol(vepinput))
head(vepinput)

# Get the first and last feature columns
first_feature_column = 6
last_feature_column = ncol(vepinput)-1

# Create a plot
cor_matrix <- cor(vepinput[, first_feature_column:last_feature_column], method="pearson", use = "pairwise.complete.obs")
png("correlation_plot.png", width = 2000, height = 2000, res = 300)
corrplot(cor_matrix, method = "color", type = "upper", tl.col = "black", tl.cex = 0.6)
title(main = "Pearson Feature Correlation\nMatrix")
dev.off()

# Initialise correlation pairs and sums
correlation_pairs <- data.frame(x=numeric(0),y=numeric(0))
print (correlation_pairs)
correlation_sums <- rep(0,last_feature_column)

# Perform pairwise pearson correlation, recording accumulated correlation and the pairs
for ( col1 in first_feature_column:(last_feature_column-1) )
  {
  for (col2 in (col1+1):last_feature_column)
    {
    R <- cor(vepinput[[col1]],vepinput[[col2]], method="pearson", use = "pairwise.complete.obs")
    if ( R > 0.9 )
      {
      correlation_pairs <- rbind(correlation_pairs, data.frame(x=col1,y=col2))
      correlation_sums[col1] = correlation_sums[col1] + R
      correlation_sums[col2] = correlation_sums[col2] + R
      print(paste("Pearson Correlation between ", colnames(vepinput)[col1], " and ", colnames(vepinput)[col2], " is ", R) )
      }
    }
  }
print (correlation_sums)
print (correlation_pairs)

# Find which columns to drop
dropped_columns<- c()
for ( i in 1:nrow(correlation_pairs) )
  {
  first = correlation_pairs[i,"x"]
  second = correlation_pairs[i,"y"]
  if ( !any(c(first,second) %in% dropped_columns) )
    {
    firstcorrelationsum = correlation_sums[first]
    secondcorrelationsum = correlation_sums[second]
    if ( firstcorrelationsum > secondcorrelationsum )
      {
      dropped_columns <- c(dropped_columns,first)
      }
    else
      {
      dropped_columns <- c(dropped_columns,second) 
      }
    }
  }

# drop the columns
print (dropped_columns)
vepoutput <- vepinput[,-dropped_columns, with=FALSE ]
#head (vepoutput)

# Write result
write.table(vepoutput, file=vep_output_path, quote=FALSE, sep=',', row.names = FALSE)
