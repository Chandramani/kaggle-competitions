import numpy as np


class CorrMatrix():
    """
    creates and displays the correlation matrix for a data set in a
    memory efficient manner.

    additionally, allows the option to enable feature selection, cutting off
    highly correlated features at a given threshold.

    of the two highly correlated features, the feature with the highest average
    correlation is removed.

    returns a list of variables which have been removed from the matrix.
    """
    def __init__(self, correlation_threshold=.9):
        self.correlation_threshold = correlation_threshold

    def select_features(self, feature_data_set):
        corr_mat = create_correlation_matrix(feature_data_set)
        np.savetxt("corr_mat.csv", corr_mat, delimiter=",")
        print "Performing correlation based feature selection"

        #setting diagonals to 0
        most_correlated = []
        diags = corr_mat.shape[0]
        corr_mat[range(diags), range(diags)] = 0

        for i in xrange(corr_mat.shape[1]):
            if np.max(np.ma.masked_array(corr_mat[:, i], np.isnan(corr_mat[:, i]))) > self.correlation_threshold:
                j = corr_mat[:, i].argmax(axis=0)
                if np.mean(np.ma.masked_array(corr_mat[:, i], np.isnan(corr_mat[:, i]))) >= \
                        np.mean(np.ma.masked_array(corr_mat[:, j], np.isnan(corr_mat[:, j]))):
                    most_correlated.append(i)
                else:
                    most_correlated.append(j)

        corr_list = list(set(most_correlated))
        corr_list.sort()
        print "Highly Correlated Variables (consider removing):", corr_list
        non_correlated = [idx for idx in sorted(range(feature_data_set.shape[1])) if idx not in corr_list]
        return non_correlated


#helper function
def create_correlation_matrix(array):
    """
    creates correlation matrix iteratively as to be memory efficient
    """
    print "creating correlational matrix"
    corr_matrix = np.eye(array.shape[1])
    print "shape of matric =",corr_matrix
    for i in xrange(array.shape[1]):
        print "creating correlational matrix for column =",i
        for j in xrange(i, array.shape[1]):
            if i != j:
                corr_matrix[i, j] = np.corrcoef(
                    array[:, i].T,
                    array[:, j].T)[0, 1]
                corr_matrix[j, i] = corr_matrix[i, j]
            else:
                corr_matrix[i, j] = 0.0
                corr_matrix[j, i] = 0.0
    return corr_matrix

import pandas as pd
#
# train=np.loadtxt(open("training.csv","rb"),delimiter=",",skiprows=1)
# test=np.loadtxt(open("sorted_test.csv","rb"),delimiter=",",skiprows=1)



train=pd.read_csv("training.csv")
# test=pd.read_csv("sorted_test.csv")

train.drop(['Ca', 'P', 'pH', 'SOC', 'Sand', 'PIDN','Depth'], axis=1, inplace=True)

train= np.array(train)[:,:3593]


corObject = CorrMatrix()

non_correlated=corObject.select_features(train)
print non_correlated
np.savetxt("non_correlated_index.csv", non_correlated, delimiter=",")
