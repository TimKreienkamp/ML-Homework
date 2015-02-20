source("par_knn.R")

k_list <- c(1,2)
train <- read.csv("training.csv")
X <- train[1:2000,2:257]
Y <- train[1:2000,1]
results_loo <- knnCVpar(X=X, y=Y,k_list = k_list, method = "loo", noCores = 3)
results_kf <- knnCVpar(X=X, y=Y,k_list = k_list, method = "kf", noCores = 3, nfold = 10)
results_mc <- knnCVpar(X=X, y=Y,k_list = k_list, method = "mc", noCores = 3, holdout = .10)
results_res <- knnCVpar(X=X, y=Y,k_list = k_list, method = "res", noCores = 3, holdout = .10)
results_res <-  as.data.frame(results_res)
names(results_res) <- c("k", "Error")


mean_results_res <- (as.data.frame(results_res) %>% group_by(k) %>% summarize(Error=mean(Error)))
mean_results_mc <- 



