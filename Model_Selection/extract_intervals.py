# -*- coding: utf-8 -*-
"""
Created on Tue Feb 24 18:22:48 2015

@author: timkreienkamp
"""                
import numpy as np

def _get_all_intervals(classifiers,x):
    all_intervals = []
    for i in range(0,len(classifiers)):
        label_list = []
        cutoff_list_start = [0.0]
        cutoff_list_end = []
        j = 0
        while j < len(classifiers[i])-1:
            cutoff_list_end.append(x[classifiers[i][j]["cutoff"]])
            cutoff_list_start.append(x[classifiers[i][j]["cutoff"]+1])
            label_list.append(classifiers[i][j]["label"])
            j += 1
        label_list.append(classifiers[i][j]["label"])
        cutoff_list_end.append(1.0)
        cutoff_start = np.asarray(cutoff_list_start)
        cutoff_end = np.asarray(cutoff_list_end)
        labels = np.asarray(label_list)
        labels = labels.astype(bool)
        cutoff_start = cutoff_start[labels]
        cutoff_end = cutoff_end[labels]
        intvs = np.column_stack((cutoff_start, cutoff_end))
        all_intervals.append(intvs)
    return all_intervals  


def predict(pred_intervals, x_val):
    is_in_int = np.vectorize(lambda x:
         np.any(np.apply_along_axis(lambda int: int[0] <= x <= int[1], 1, pred_intervals)))
    y_pred = is_in_int(x_val)
    y_pred = y_pred.astype(np.float32, copy=False)
    return y_pred


def _get_all_errors(all_intervals, x_val, x_train, y_val,ytrain):
    error = []
    complexity = []
    for interval in all_intervals:
        y_pred = predict(interval, x_val)
        train_preds = predict(interval, y_train)
        val_error = test_error(y_val, y_pred)
        error.append(val_error)
        if interval[(interval.shape[1]-1],1] = 1.0:
            complexity.append((intervals.shape[1])*2)
        else:
            complexity.append((intervals.shape[1])*2+1)
    retur
    
    