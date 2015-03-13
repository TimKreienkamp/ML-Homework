setwd("/Users/timkreienkamp/documents/studium/data_science/machine_learning/problem_sets/ML-Homework")

source("./adaboost/adaboost_func.R")

if(!require(mlbench)) install.packages("mlbench")
if(!require(randomForest)) install.packages("randomForest")
if(!require(ggplot2)) install.packages("ggplot2")
library(mlbench)
library(randomForest)
library(ggplot2)




#split data in training and prediction part
set.seed(40)
X <- c((rnorm(500) -2), (rnorm(500)+2))
Y <- c(rep(1, 500), rep(-1, 500))

set.seed(50)
X_test <- c((rnorm(100) -2), (rnorm(100)+2))
Y_test <- c(rep(1, 100), rep(-1, 100))

#set sequence of iterations to perform

iter_seq <- c(1, 5, 10, 20, 50)

# compute the adaboost training and validation error
results_ada <- matrix(rep(NA, 2*length(iter_seq)), ncol = 2)

train <- data.frame(cbind(X, Y))
test <- data.frame(cbind(X_test,Y_test))
names(test) <- names(train)


for (i in 1:length(iter_seq)){
  fit <- adaTrain(Y ~ ., input = train, iter_seq[i])
  predictions <- adaPredict(test, fit$tree_list, fit$alpha_vec)
  train_error <- fit$error
  test_error <- mean(predictions !=test[,2])
  results_ada [i, 1] <- train_error
  results_ada [i, 2] <- test_error
}



train$Y <- as.factor(train$Y)
test$Y <- as.factor(test$Y)



tree_seq <- c(5, 10, 20, 40, 80)

results_rf <- matrix(rep(NA, 2*length(tree_seq)), ncol = 2)

for (i in 1:length(tree_seq)){
  rf_fit <- randomForest(Y ~., data = train, n.tree = tree_seq[i])
  train_error <- mean(predict(rf_fit)!=train$Y)
  test_error <- mean(predict(rf_fit, newdata = test) != test$Y)
  results_rf [i, 1] <- train_error
  results_rf [i, 2] <- test_error
}

error_ada <- c(results_ada[,1], results_ada[,2])
error_type <- c(rep("Training", length(results_ada[,1])), rep("Test", length(results_ada[,2])))

results_ada <- data.frame(error_type, error_ada, iter_seq)
names(results_ada) = c("Error_Type", "Error", "Iterations")

plot_ada <- ggplot(data = results_ada, aes(x = Iterations, y = Error, color = Error_Type)) + geom_line()

error_rf <- c(results_rf[,1], results_rf[,2])
error_type <- c(rep("Training", length(results_rf[,1])), rep("Test", length(results_rf[,2])))

results_rf <- data.frame(error_type, error_rf, iter_seq)
names(results_rf) = c("Error_Type", "Error", "Trees")

plot_rf <- ggplot(data = results_rf, aes(x = Trees, y = Error, color = Error_Type)) + geom_line() 

plot_ada
plot_rf
