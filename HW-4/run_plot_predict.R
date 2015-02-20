

#source function
source("par_knn.R")


#read in training data
train <- read.csv("training.csv")
#subset
k_list <- c(1,2)
X <- train[1:500,2:257]
Y <- train[1:500,1]

#compute results for different methods
results_loo <- knnCVpar(X=X, y=Y,k_list = k_list, method = "loo", noCores = 3)
results_kf <- knnCVpar(X=X, y=Y,k_list = k_list, method = "kf", noCores = 3, nfold = 10)
results_mc <- knnCVpar(X=X, y=Y,k_list = k_list, method = "mc", noCores = 3, holdout = .10)
results_res <- knnCVpar(X=X, y=Y,k_list = k_list, method = "res", noCores = 3, holdout = .10)
results_res <-  as.data.frame(results_res)
results_mc <-  as.data.frame(results_mc)
results_kf <-  as.data.frame(results_kf)
results_loo <-  as.data.frame(results_loo)
names(results_res) <- c("k", "Error")
names(results_mc) <- c("trial", "k", "Error")
names(results_kf) <- c("Bucket", "k", "Error")
names(results_loo) <- c("Bucket", "k", "Error")


#aggregate results
mean_results_res <- (as.data.frame(results_res) %>% group_by(k) %>% summarize(Error=mean(Error)))
mean_results_mc <- (as.data.frame(results_mc) %>% group_by(k) %>% summarize(Error=mean(Error)))
mean_results_kf <- (as.data.frame(results_kf) %>% group_by(k) %>% summarize(Error=mean(Error)))
mean_results_loo <- (as.data.frame(results_loo) %>% group_by(k) %>% summarize(Error=mean(Error)))
mean_results_res <- cbind(rep("Resubstitution", length(mean_results_res[,1])), mean_results_res)
mean_results_kf<- cbind(rep("KFold-Blocks", length(mean_results_kf[,1])), mean_results_kf)
mean_results_mc <- cbind(rep("KFold MonteCarlo", length(mean_results_mc[,1])), mean_results_mc)
mean_results_loo <- cbind(rep("Leave-One-Out", length(mean_results_loo[,1])), mean_results_loo)

names(mean_results_res) <- c("Method", "k", "Error")
names(mean_results_loo)<- c("Method", "k", "Error")
names(mean_results_kf)<- c("Method", "k", "Error")
names(mean_results_mc) <- c("Method", "k", "Error")

AllResults <- rbind(mean_results_res, mean_results_loo, mean_results_kf, mean_results_mc)






