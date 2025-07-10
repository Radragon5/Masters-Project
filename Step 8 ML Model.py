# Import libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import statistics as stat
import xgboost as xgb
import shap
import lightgbm as lgb

from sklearn.decomposition import PCA 
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from sklearn import svm
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay, classification_report
from sklearn.metrics import accuracy_score, precision_recall_fscore_support
from sklearn.tree import DecisionTreeClassifier
from random import shuffle
from xgboost import XGBClassifier
from sklearn.preprocessing import StandardScaler
from pulearn import BaggingPuClassifier, ElkanotoPuClassifier
from catboost import CatBoostClassifier
from scipy.stats import norm

#
# DEFINE PARAMETERS
#
# Set Model Parameter
model_name = 'CatBoost'
model_name_lowercase = 'catboost'
model_date = '2025-05-19'
num_iterations = 100
num_estimators = 15
shap_plot_needed = True

# Set base path and input file name
data_path = '/data/home/bt24981/{}/{}'.format(model_name_lowercase,model_date)
#data_path = 'C:/Users/mihai/OneDrive - Queen Mary, University of London/Research Project/HPC/{}/{}'.format(model_name_lowercase,model_date)
input_file  = '{}/model_data.csv'.format(data_path)
output_file = '{}/model_results.csv'.format(data_path)

# Select Model
#clf=RandomForestClassifier()                                                           # Random Forest
#clf = XGBClassifier(objective="binary:logistic", eval_metric="logloss")                # XGBoost
#clf = lgb.LGBMClassifier(objective="binary", metric="binary_logloss", verbose=0)       # lightgbm
clf = CatBoostClassifier(loss_function="Logloss", eval_metric="Logloss", verbose=0)    # CatBoost
#clf = AdaBoostClassifier(estimator=DecisionTreeClassifier(max_depth=1),n_estimators=15,learning_rate=1.0,algorithm='SAMME.R') # AdaBoost
#clf=svm.SVC()                                                                          # SVM Model

# Get data
df_input = pd.read_csv(input_file, sep=',', na_values='NA')

# Extract Causal List remove unimportant columns
labels = (df_input['Causal_SNP'] | df_input['Drugable_SNP']).tolist()
df = df_input.drop(['SNP', 'RSID', 'Source', 'Causal_SNP', 'Drugable_SNP'], axis=1)

# Standardise the features
scaler = StandardScaler()
df_scaled = scaler.fit_transform(df)
df = pd.DataFrame(df_scaled, columns=df.columns, index=df.index)

# Run Model

# Create empty lists for recording results of cross validation and recording the best model
precisionlist = []
recalllist = []
acclist = []
f1scorelist = []
all_train = []
all_pred = []

best_f1_score = 0
best_model = None
best_predictions = None
best_y_test = None

# Bootstrap loop
for iter in range(0,num_iterations):
    print('Iteration: {}'.format(iter), flush=True)
    x_train, x_test, y_train, y_test = train_test_split(df, labels, test_size=0.3, random_state=iter) # 70% training and 30% test                                         
    pu_model = BaggingPuClassifier(estimator=clf, n_estimators=num_estimators)  # Bagging ensemble
    pu_model.fit(x_train,y_train)                                               # Fit the data
    predictions = pu_model.predict_proba(x_test)                                # Get predictions
    predictions = predictions[:,1]                                              # Extract prediction data
    predictions = [1 if x > 0.5 else 0 for x in predictions]                    # Convert predictions to binary 1 or 0
    precision, recall, f1_score, _ = precision_recall_fscore_support(y_test,predictions,average='binary') # Get model precision, recall and f1 score
    accuracy = accuracy_score(y_test,predictions)                               # Get model accuracy
    
    precisionlist.append(precision)     # Record precisionrecall, f1 score and accuracy
    recalllist.append(recall)           # Record recall
    acclist.append(accuracy)            # record accuracy
    f1scorelist.append(f1_score)        # Record f1 score

    all_train.extend(y_test)            # record training data
    all_pred.extend(predictions)        # record prediction data

    if ( f1_score > best_f1_score):     # record the best model
        best_f1_score = f1_score
        best_model = pu_model
        best_predictions = predictions
        best_y_test = y_test

# Report statistics across all models
mean_precision = np.mean(precisionlist) # Calculate statistics
mean_recall    = np.mean(recalllist)
mean_accuracy  = np.mean(acclist)
mean_f1        = np.mean(f1scorelist)
median_f1      = np.median(f1scorelist)
std_f1         = np.std(f1scorelist)
print('\nSummary Statistics across all {} Iterations:'.format(num_iterations))
print('Mean Precision: {}'.format(mean_precision))
print('Mean Recall: {}'.format(mean_recall))
print('Mean Accuracy: {}'.format(mean_accuracy))
print('Mean F1 Score: {}'.format(mean_f1))
print('Median F1 Score: {}'.format(median_f1))
print('Standard Deviation F1 Score: {}'.format(std_f1))
print('Best F1 Score: {}'.format(best_f1_score))

# Apply Model to the whole dataframe and save results
print('\nRunning best model on full data and saving.')
full_predictions = best_model.predict_proba(df)
df_output = df_input.copy()
df_output.insert(3, 'Prioritisation', full_predictions[:,1])
df_output.to_csv(output_file,index=False,sep=',')

# Report Model Parameters
print('\nModel Parameters:')
print(clf.get_params())

# Classification Report
print('\nClassification Report:')
print(classification_report(best_y_test,best_predictions))

# Histogram of F1 Score
print('\nCreating Histogram:')
f1score_percentage = [ x * 100 for x in f1scorelist]
f1mean_percentage = np.mean(f1score_percentage)
f1median_percentage = np.mean(f1score_percentage)
f1std_percentage = np.std(f1score_percentage)
plt.figure()
count, bins, ignored = plt.hist(f1score_percentage,bins=20,align='mid')
xmin, xmax = min(bins), max(bins)
x = np.linspace(xmin, xmax, 100)
pdf = norm.pdf(x, f1mean_percentage, f1std_percentage)
pdf_scaled = pdf * np.diff(bins)[0] * len(f1score_percentage)
plt.plot(x, pdf_scaled, color='red', label='Normal Distribution')
plt.axvline(f1mean_percentage, color='green', linestyle='solid', linewidth=2, label='Mean {:.1f}%'.format(f1mean_percentage))
plt.axvline(f1median_percentage, color='orange', linestyle='dashed', linewidth=2, label='Median {:.1f}%'.format(f1median_percentage))
plt.xlabel('F1 Score (%)')
plt.ylabel('Frequency ({} Iterations)'.format(num_iterations))
plt.title('F1 Score Distribution for {} Model)'.format(model_name))
plt.legend()
plt.savefig('{}_f1_score_distribution.png'.format(model_name_lowercase))

# Confusion matrix 
print('Creating Confusion Matrix:')
cm = confusion_matrix(all_train, all_pred, labels=pu_model.classes_)
cm_percentage = cm.astype('float') / cm.sum() * 100
disp = ConfusionMatrixDisplay(confusion_matrix=cm_percentage,display_labels=pu_model.classes_)
disp.plot(values_format='.1f')
for text in disp.text_.ravel():
    text.set_text(text.get_text() + '%')
plt.title('Confusion Matrix for {} Model'.format(model_name))
plt.savefig('{}_confusion_matrix.png'.format(model_name_lowercase))

# Heat map of precision, recall, F1 Score and accuracy
print('Creating Heat Map of Scores:')
precision = np.linspace(1, 100, 100)  # define parameters for heatmap. Avoid zero to prevent division by zero
recall = np.linspace(1, 100, 100)
P, R = np.meshgrid(precision, recall)
F1 = 2 * (P * R) / (P + R)

precision_val = mean_precision * 100  # Convert to precentages
recall_val = mean_recall * 100
f1_val = mean_f1 * 100
acc_val = mean_accuracy * 100

plt.figure() # Plot the heatmap
heatmap = plt.contourf(P, R, F1, levels=50, cmap='viridis')
cbar = plt.colorbar(heatmap)
cbar.set_label('F1 Score %')

#plt.axvline(x=precision_val, color='red', linestyle='dashed', label=f'Precision = {precision_val:.1f}%') # Add lines and annotation
#plt.axhline(y=recall_val, color='blue', linestyle='dashed', label=f'Recall = {recall_val:.1f}%')
plt.axvline(x=precision_val, color='red', linestyle='dashed', label='Precision = {:.1f}%'.format(precision_val)) # Add lines and annotation
plt.axhline(y=recall_val, color='blue', linestyle='dashed', label='Recall = {:.1f}%'.format(recall_val))
plt.plot([], [], 'ko', label=f'F1 Score = {f1_val:.1f}%')
plt.plot([], [], ' ', label=f'Accuracy = {acc_val:.1f}%')  
plt.plot(precision_val, recall_val, 'o', color='black', markersize=8)
plt.text(precision_val + 2, recall_val - 5, f'F1 ', color='black', fontsize=12)

plt.xlabel('Precision (%)') # Add labels and plot
plt.ylabel('Recall (%)')
plt.title('F1 Score Heatmap with Precision and Recall Lines')
plt.grid(True, linestyle='--', alpha=0.3)
plt.legend()
plt.title('Precision, Recall and F1 Score for {} Model'.format(model_name))
plt.savefig('{}_precision_recall_f1score.png'.format(model_name_lowercase))

# SHAP Plot
if ( shap_plot_needed ) :
    print('Creating SHAP Plot:')
    explainer = shap.TreeExplainer(best_model.estimators_[0])
    shap_values = explainer.shap_values(df)
    plt.figure()
    shap.summary_plot(shap_values, df, show=False)
    plt.title('SHAP Summary for {} Model'.format(model_name))
    plt.subplots_adjust(top=0.95)
    plt.savefig('{}_shap_summary.png'.format(model_name_lowercase))