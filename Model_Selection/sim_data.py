# -*- coding: utf-8 -*-
"""
Created on Sun Feb 22 15:38:55 2015

@author: timkreienkamp
"""

import numpy as np

intervals = np.array([[0.1,0.5],[0.9,1.0]])

def create_pos_biased(x):
    for row in xrange(0,len(intervals[:,1])): 
        bool_1 = (x > intervals[row,0] and x <= intervals[row,1])
    return bool_1
create_pos_biased = np.vectorize(create_pos_biased)

                     
def apply_bias(x):
    if x:
        x = 0.5+bias
    else:
        x = 0.5-bias
    return x    
apply_bias = np.vectorize(apply_bias)
       
def apply_binom(x):
    y = numpy.random.binomial(1, x)
    return y   
apply_binom = np.vectorize(apply_binom)
  

def sim_data(intervals, ndraws, bias):
     x = numpy.random.uniform(0,1,ndraws)
     pos_biased = create_pos_biased(x)
     eta_x = apply_bias(pos_biased)
     y = apply_binom(eta_x)
     return (y,x)
     
y, x = sim_data(intervals, 10**8, 0.3)
    
print(y)