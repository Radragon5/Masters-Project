library(data.table)
library(moments)

# Clear global environment
rm(list=ls())

#
# Function to plot histogram and density line of data to examine Skewness and Kurtosis
#
skweness_kurtosis_plot <- function (data, maintitle, xtitle ) {
  
  # Calcualte skewness and kurtosis
  sk = skewness(data)
  ku = kurtosis(data)
  
  # Plot histogram
  hist_data <- hist(data, plot = FALSE) # Do not plot, use to calculate ymax
  x_vals <- seq(min(data, na.rm = TRUE), max(data, na.rm = TRUE), length.out = 100)
  normal_curve <- dnorm(x_vals, mean = mean(data, na.rm = TRUE), sd = sd(data, na.rm = TRUE))
  ymax <- max(max(hist_data$density), max(normal_curve))
  #hist(data, xlab=xtitle, ylab="Density", ylim = c(0, ymax * 1.1), prob=TRUE, main=paste0(maintitle,"\nSkewness: ", round(sk,2)," Kurtosis: ",round(ku,2)))
  hist(data, xlab=xtitle, ylab="Density", ylim = c(0, ymax * 1.1), prob=TRUE, main=maintitle)
  
  mtext(paste0("Skewness: ", round(sk,2)," Kurtosis: ",round(ku,2)), side = 3, line = -0.5, cex = 0.5, font = 1)
  lines(x_vals, normal_curve, col = "darkblue", lwd = 2)
  }

#
# PNG Helper
#
png_helper <- function(indices, filename)
  {
  png(filename = filename, width = 4000, height = 6000, res = 600)
  par(mfrow = c(6, 3), mar = c(2, 2, 2, 1))
  for (i in indices)
    {
    column_name <- names(modeldata)[i]
    column_data <- modeldata[[i]]
    if (all(is.na(column_data))) next
    skweness_kurtosis_plot(data = column_data, maintitle = paste(column_name), xtitle = column_name)
    }
  dev.off()
  }

# Define all paths
vep_input_path  <- "Combined Model Parameters After KNN.csv"

# Read in the input file
modeldata <- data.table::fread(vep_input_path, header = TRUE, stringsAsFactors = FALSE)

# Get the first and last feature columns and the split over the plots
first_feature_column = 7
last_feature_column = ncol(modeldata)
feature_indices <- first_feature_column:last_feature_column
total_features <- length(feature_indices)
group1_indices <- feature_indices[1:min(18, total_features)]
group2_indices <- feature_indices[(min(19, total_features)):total_features]

# Create skewness/kurtosis plots
png_helper(group1_indices, "Distribution Plots1.png")
png_helper(group2_indices, "Distribution Plots2.png")