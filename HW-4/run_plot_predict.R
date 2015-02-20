#load libraries

if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("snow")) install.packages("snow")
if (!require("foreach")) install.packages("foreach")
if (!require("doSNOW")) install.packages("doSNOW")
if (!require("class")) install.packages("class")
if (!require("parallel")) install.packages("parallel")
if (!require("assertthat")) install.packages("assertthat")
library("ggplot2")
library("class")
library("parallel")
library("dplyr")
library("doSNOW")
library("foreach")
library("snow")

#source function
source("par_knn.R")

#read in training data
train <- read.csv("training.csv", header = F)
X <- train[,2:257]
Y <- train[,1]


#set k List
k_list <- c(1,2,3,5,7,15,19,25,30,40,50)


#compute results for different methods
results_loo <- knnCVpar(X=X, y=Y,k_list = k_list, method = "loo", noCores = 16)
results_kf <- knnCVpar(X=X, y=Y,k_list = k_list, method = "kf", noCores = 16, nfold = 10)
results_mc <- knnCVpar(X=X, y=Y,k_list = k_list, method = "mc", noCores = 16, holdout = .10, reps = 20)
results_res <- knnCVpar(X=X, y=Y,k_list = k_list, method = "res", noCores = 16, holdout = .10)
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

#create a ggplot2 compatible dataframe
AllResults <- rbind(mean_results_res, mean_results_loo, mean_results_kf, mean_results_mc)

#plot
plot <- ggplot(data = AllResults, aes(x = k, y= Error, colour = Method)) + geom_line() + ggtitle("Validation Methods Comparison")
plot

#read in test data
test <- read.csv("test.csv", header = F)

#make predictions, one file for each "best k" chosen by each method

#kfold blocks
kf_best_k <- mean_results_kf$k[which.min(mean_results_kf$Error)]
preds_kf <- as.data.frame(knn(train=X, test=test, cl=Y, k=kf_best_k))
names(preds_kf) <- c("Predicted Label")
write.csv(preds_kf, "predictions_k_fold_blocks.csv", row.names = F)

#kfold montecarlo
mc_best_k <- mean_results_mc$k[which.min(mean_results_mc$Error)]
preds_mc <- as.data.frame(knn(train=X, test=test, cl=Y, k=mc_best_k))
names(preds_mc) <- c("Predicted Label")
write.csv(preds_kf, "predictions_k_fold_montecarlo.csv", row.names = F)

#loo 
loo_best_k <- mean_results_loo$k[which.min(mean_results_loo$Error)]
preds_loo <- as.data.frame(knn(train=X, test=test, cl=Y, k=loo_best_k))
names(preds_loo) <- c("Predicted Label")
write.csv(preds_loo, "predictions_loo.csv", row.names = F)

#resubsitution
res_best_k <- mean_results_res$k[which.min(mean_results_res$Error)]
preds_res <- as.data.frame(knn(train=X, test=test, cl=Y, k=res_best_k))
names(preds_res) <- c("Predicted Label")
write.csv(preds_loo, "predictions_resubstitution.csv", row.names = F)





