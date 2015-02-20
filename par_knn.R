knnCVpar <- function(X, y, k_list, method = "kf", noCores = 2, nfolds = 3, split = 0.3, reps = 10){
  library(assertthat)
  library(parallel)
  assert_that(not_empty(k_list))
  assert_that(method %in% c("kf", "loo", "mc", "res"))
  assert_that(noCores <= detectCores())
  
  cl <- makeCluster(noCores, type="SOCK", outfile="") 
  registerDoSNOW(cl)
  
  if (method == "res"){
    results<- foreach(k = kList, 
                      .combine=rbind, .packages=c("class", "dplyr")) %dopar% {
                        
                        # some helpful debugging messages
                        
                        # subsetting the training phase data
                        Xtrain <- digits[,2:257]
                        Ytrain <- digits[,1]
                        
                        # kNN results
                        Predictions <- knn(train=Xtrain, test=Xtrain, cl=Ytrain, k=k)
                        Error <- mean(Predictions!=Ytrain)
                        
                        # last thing is returned
                        result <- c(k, Error)
                      }
    stop(cl)
  }
  
  else if (method == "mc"){
    trials <- rep(1:reps, length(k))
    kList <- rep(ks, reps)
    
    
    results<- foreach(trial = trials, k = kList, 
                      .combine=rbind, .packages=c("class", "dplyr")) %dopar% {
                        
                        digits <- digits[sample(1:nrow(digits), length(digits[,1]),replace=FALSE),]
                        n <- length(digits[,1])
                        Xtrain <- digits[1:floor(n*(1-0.3)),2:257]
                        Ytrain <- digits[1:floor(n*(1-0.3)),1]
                        
                        
                        # subsetting the test phase data
                        Xtest <- digits[(floor(n*(1-0.3))+1):n,2:257]
                        Ytest <- digits[(floor(n*(1-0.3))+1):n,1]
                        print(length(Ytest))
                        
                        # kNN results
                        testPredictions <- knn(train=Xtrain, test=Xtest, cl=Ytrain, k=k)
                        testError <- mean(testPredictions != Ytest)
                        
                        # last thing is returned
                        result <- c(trial, k, testError)
                      }
    
  }
  
}