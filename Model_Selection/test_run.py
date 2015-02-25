# -*- coding: utf-8 -*-
"""
Created on Tue Feb 24 22:55:01 2015

@author: timkreienkamp
"""
import numpy as np
import matplotlib.pyplot as plt


true_intervals = _get_true_intervals(0.02)
x,y = _sim_data(true_intervals, 10000, 0.2)
x_val, y_val = _sim_data(true_intervals, 3000, 0.2)

p = Partition(y)
odd_classifiers = p.select(3, save = True)
p = Partition(y)
even_classifiers = p.select(4, save = True)

classifiers = _zip_lists(odd_classifiers, even_classifiers)

all_intervals = _get_all_intervals(classifiers, x)

validation_error, training_error, complexity = _get_all_errors(all_intervals, x_val, x, y_val,y, classifiers, shortest_k = 60)


plt.plot(complexity, training_error, 'k--', label = "Training Error")
plt.plot(complexity, validation_error,  label = "Validation Error")
plt.title("Complexity Vs Error (Bias = 0.2, n_train = 10^4, n_val = 3*10^3)")
plt.savefig("Plot1.png", dpi = 120, figsize = (2,2))

true_intervals = _get_true_intervals(0.02)
x,y = _sim_data(true_intervals, 10000, 0.3)
x_val, y_val = _sim_data(true_intervals, 3000, 0.3)

p = Partition(y)
odd_classifiers = p.select(3, save = True)
p = Partition(y)
even_classifiers = p.select(4, save = True)

classifiers = _zip_lists(odd_classifiers, even_classifiers)

all_intervals = _get_all_intervals(classifiers, x)

validation_error, training_error, complexity = _get_all_errors(all_intervals, x_val, x, y_val,y, classifiers, shortest_k = 60)

plt.plot(complexity, training_error, 'k--', label = "Training Error")
plt.plot(complexity, validation_error,  label = "Validation Error")
plt.title("Complexity Vs Error (Bias = 0.3, n_train = 10^4, n_val = 3*10^3)")
plt.savefig("Plot2.png", dpi = 120, figsize = (2,2))


true_intervals = _get_true_intervals(0.02)
x,y = _sim_data(true_intervals, 1000, 0.3)
x_val, y_val = _sim_data(true_intervals, 3000, 0.3)

p = Partition(y)
odd_classifiers = p.select(3, save = True)
p = Partition(y)
even_classifiers = p.select(4, save = True)

classifiers = _zip_lists(odd_classifiers, even_classifiers)

all_intervals = _get_all_intervals(classifiers, x)

validation_error, training_error, complexity = _get_all_errors(all_intervals, x_val, x, y_val,y, classifiers, shortest_k = 55)

plt.plot(complexity, training_error, 'k--', label = "Training Error")
plt.plot(complexity, validation_error,  label = "Validation Error")
plt.title("Complexity Vs Error (Bias = 0.3, n_train = 10^3, n_val = 3*10^3)")
plt.savefig("Plot3.png", dpi = 120, figsize = (2,2))




