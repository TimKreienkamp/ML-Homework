setwd("/Users/timkreienkamp/documents/studium/data_science/machine_learning/problem_sets/ML-Homework/model_selection/")

interval_selection <- function(bias = 0.2, n_train = 1000, n_val=500, n_intervals = 100, shortest_k = 3){
  
  if (!require("ggplot2")) install.packages("ggplot2")
  if (!require("rPython")) install.packages("rPython")
  library(ggplot2)
  library(rPython)
  
  
  ##########################################
  #python function definitions
  ###########################################
  
  
  python.exec('import numpy as np')
  python.exec('from collections import deque')
  python.exec('from copy import copy')
  python.load("struct.py")
  python.load("algo.py")
  python.load("extract_intervals.py")
  
  #variable assignments
  python.assign("bias", bias)
  python.assign("n_train", n_train)
  python.assign("n_val", n_train)
  python.assign("shortest_k", shortest_k)
  
  partition_size = 1/n_intervals
  python.assign("partition_size", partition_size)
  
  python.exec("true_intervals = _get_true_intervals(partition_size)")
  python.exec("x_train,y_train = _sim_data(true_intervals, n_train, bias)")
  python.exec("x_val,y_val = _sim_data(true_intervals, n_val, bias)")
  python.exec("y = y_train")
  python.exec("p = Partition(y_train)")
  python.exec("classifiers_even = p.select(3,save = True)")
  python.exec(("p = Partition(y_train)"))
  python.exec("classifiers_odd = p.select(4,save = True)")
  python.exec("classifiers = _zip_lists(classifiers_odd, classifiers_even)")
  python.exec("all_intervals = _get_all_intervals(classifiers, x_train)")
  python.exec("validation_error, training_error, complexity = _get_all_errors(all_intervals, x_val, x_train, y_val,y_train, classifiers, shortest_k)")
  validation_error = python.get("validation_error")
  training_error = python.get("training_error")
  complexity = python.get("complexity")
  error_type <- c((rep("Training", length(training_error))), rep("Validation", length(validation_error)))
  error <- c(training_error, validation_error)
  complexity <- c(complexity, complexity)
  results <- data.frame(error_type,complexity, error,stringsAsFactors=FALSE)
  plot <- ggplot(data = results, aes(x = complexity, y= error, colour = error_type, group = error_type)) +  geom_line()  + ggtitle("Validation/Training Error vs Complexity")
  return(list(results=results, plot=plot))
}

ggplot(data = results$results, aes(x = complexity, y= Error, colour = error_type, group = error_type)) +  geom_line()

results <- interval_selection(n_train = 10000, shortest_k = 70)
plot1 <- results$plot + ggtitle ("Validation /Training Error vs Complexity (Bias = 0.2)")
results_2 <- interval_selection(n_train = 10000, shortest_k = 70, bias = 0.4)

plot2 <- results_2$plot + ggtitle ("Validation /Training Error vs Complexity (Bias = 0.4)")




