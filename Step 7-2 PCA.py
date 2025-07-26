# Import libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches   
from sklearn.decomposition import PCA 
from sklearn.preprocessing import StandardScaler
from mpl_toolkits.mplot3d import Axes3D
from scipy.spatial import distance
import seaborn as sns
from scipy.stats import chi2

# Set base path
#data_path = '/data/home/bt24981/pca/2025-05-13'
data_path = 'C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/HPC/pca/2025-07-26'

# set file paths
input_file  = f'{data_path}/model_data.csv'
output_file = f'{data_path}/pca_loadings.csv'

# Get data
df = pd.read_csv(input_file, sep=',', na_values='NA')

# Create a colour index
samplecolours = df.apply(lambda row: 'Red' if row['Causal_SNP'] == 1 or row['Drugable_SNP'] == 1 else 'Blue', axis=1).tolist()

# Combine Cauual and druggable columns and remove unimportant
#df.insert(0, 'Causal', df['Causal_SNP'] | df['Drugable_SNP'])
sample_names = df['SNP'].tolist()
df = df.drop(['SNP', 'RSID', 'Source', 'Causal_SNP', 'Drugable_SNP'], axis=1)

# Standardise the features
scaler = StandardScaler()
dfscalar = scaler.fit_transform(df)

# perform PCA using sklearn
n_components = 10
pca = PCA(n_components)
pca.fit(dfscalar) 
print('Proportion of variance captured by each PC:')
print(pca.explained_variance_ratio_)

# Create a DataFrame showing the component loadings
loadings = pd.DataFrame(
    pca.components_.T,  # transpose so rows = features
    index=df.columns,   # use original feature names
    columns=[f'PC{i+1}' for i in range(pca.n_components_)]
)
print('PC Loadings:')
print(loadings)
print(loadings[['PC1', 'PC2', 'PC3']])

# Save Loadings
loadings.to_csv(output_file, sep=',', index=True)

# Plot PCA Results
plt.plot(range(1,11),pca.explained_variance_ratio_)
plt.xlabel('Principal component')
plt.ylabel('Explained variance')
plt.xticks(np.arange(1, 11, 1))
#plt.title('Principal Components Analysis')
plt.savefig('pca_variance.png')

# generate scores matrix
X_scores = pd.DataFrame(pca.transform((df)), index=sample_names)
print(X_scores)

# Draw a scatter diagram of the PCA scores
plt.scatter(X_scores[0], X_scores[1], c=samplecolours)
plt.xlabel('PC1 ('+str(round(pca.explained_variance_ratio_[0]*100))+'%)')
plt.ylabel('PC2 ('+str(round(pca.explained_variance_ratio_[1]*100))+'%)')
ctrlpatch = mpatches.Patch(color='red',label='Causable')
crohnspatch = mpatches.Patch(color='blue',label='Unlabelled')
plt.legend(handles=[ctrlpatch,crohnspatch],loc='upper right',ncol=2)
#plt.title('First and Second Principal Components')
plt.savefig('pca_1and2.png')

# Draw a 3-D scatter diagram
fig = plt.figure(figsize=(8, 6))
ax = fig.add_subplot(111, projection='3d')
ax.scatter(X_scores[0], X_scores[1], X_scores[2], c=samplecolours)
ax.set_xlabel('PC1 ('+str(round(pca.explained_variance_ratio_[0]*100))+'%)')
ax.set_ylabel('PC2 ('+str(round(pca.explained_variance_ratio_[1]*100))+'%)')
ax.set_zlabel('PC3 ('+str(round(pca.explained_variance_ratio_[2]*100))+'%)')
ctrlpatch = mpatches.Patch(color='red',label='Causable')
crohnspatch = mpatches.Patch(color='blue',label='Unlabelled')
plt.legend(handles=[ctrlpatch,crohnspatch],loc='upper right',ncol=2)
#plt.title('First, Second and Third Principal Components')
plt.savefig('pca_1and2and3.png')

# Use 3 PCs for Mahalanobis distance
pcs_used = X_scores[[0, 1, 2]]
cov_matrix = np.cov(pcs_used, rowvar=False)
inv_cov_matrix = np.linalg.inv(cov_matrix)
mean_vec = pcs_used.mean().values

# Calculate Mahalanobis distances
mahal = pcs_used.apply(lambda row: distance.mahalanobis(row, mean_vec, inv_cov_matrix), axis=1)
X_scores['mahalanobis'] = mahal

# Outliers at 99.9th percentile 
threshold_mahal = np.percentile(mahal, 99.9)
outliers_mahal = X_scores[X_scores['mahalanobis'] > threshold_mahal]

print("Outliers based on Mahalanobis distance:")
print(outliers_mahal)
outliers_mahal.to_csv(f'{data_path}/pca_mahal_outliers.csv')

# Draw Histogram of Mahalanobis distribution
plt.figure(figsize=(10, 6))

# Generate histogram manually to access bar data
counts, bins, patches = plt.hist(X_scores['mahalanobis'], bins=30, color='skyblue', edgecolor='black')

# Add labels on top of each bar
for count, bin_edge in zip(counts, bins):
    if count > 0:
        plt.text(
            x=bin_edge + (bins[1] - bins[0]) / 2,  # center of the bar
            y=count + 0.5,  # slight offset above the bar
            s=str(int(count)),
            ha='center',
            fontsize=8
        )

# Add vertical threshold line
plt.axvline(x=threshold_mahal, color='red', linestyle='--', label=f'99.9th percentile ({round(threshold_mahal, 2)})')

# Axis labels and title
#plt.title('Distribution of Mahalanobis Distances in PCA Space')
plt.xlabel('Mahalanobis Distance')
plt.ylabel('Frequency')
plt.legend()
#plt.tight_layout()
plt.savefig(f'{data_path}/mahalanobis_histogram.png')

# Calcualte p-values of top 5
n_pcs = pcs_used.shape[1]
X_scores['mahalanobis_sq'] = X_scores['mahalanobis'] ** 2
X_scores['mahalanobis_chi2_p'] = 1 - chi2.cdf(X_scores['mahalanobis_sq'], df=n_pcs)

# Show worst 5 outliers with p-values
worst_outliers = X_scores.sort_values('mahalanobis', ascending=False).head(5)
print(worst_outliers[['mahalanobis', 'mahalanobis_chi2_p']])
worst_outliers.to_csv(f'{data_path}/pca_mahal_worst_outliers.csv')