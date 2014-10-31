import pandas as pd
import numpy as np
from sklearn import svm, cross_validation
from sklearn.metrics import mean_squared_error
from math import sqrt
from sklearn import preprocessing

train = pd.read_csv('training.csv')
test = pd.read_csv('sorted_test.csv')
labels = train[['Ca','P','pH','SOC','Sand']].values
train_labels = train[['Ca','P','pH','SOC','Sand']]

train.drop(['Ca', 'P', 'pH', 'SOC', 'Sand', 'PIDN'], axis=1, inplace=True)
test.drop('PIDN', axis=1, inplace=True)

xtrain, xtest = np.array(train)[:,:2655], np.array(test)[:,:2655]

xtrain1, xtest1 = np.array(train)[:,:3578], np.array(test)[:,:3578]

sup_vec = svm.SVR(C=10000.0, verbose = 0)

preds = np.zeros((xtest.shape[0], 5))
train_pred = np.zeros((xtrain.shape[0], 5))
for i in range(5):
    sup_vec.fit(xtrain, labels[:,i])
    preds[:,i] = sup_vec.predict(xtest).astype(float)
    train_pred[:,i] = sup_vec.predict(xtrain).astype(float)
    

sample = pd.read_csv('sample_submission.csv')
sample['Ca'] = preds[:,0]
sample['P'] = preds[:,1]
sample['pH'] = preds[:,2]
sample['SOC'] = preds[:,3]
sample['Sand'] = preds[:,4]

sample.to_csv('beating_benchmark.csv', index = False)

rms_ca = sqrt(mean_squared_error(train_labels['Ca'], train_pred[:,0]))
rms_p = sqrt(mean_squared_error(train_labels['P'], train_pred[:,1]))
rms_ph = sqrt(mean_squared_error(train_labels['pH'], train_pred[:,2]))
rms_soc = sqrt(mean_squared_error(train_labels['SOC'], train_pred[:,3]))
rms_sand = sqrt(mean_squared_error(train_labels['Sand'], train_pred[:,4]))

rmse_avg=(rms_ca+rms_p+rms_sand+rms_soc+rms_ph)/5
print rms_ca,rms_p,rms_ph,rms_soc,rms_sand
print rmse_avg
