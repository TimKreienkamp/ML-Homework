knnCVpar <- function(X, y, k_list, method = "kf", noCores = 2, nfolds = 3, holdout = 0.3, reps = 10){
  library(assertthat)
  library(parallel)
  assert_that(not_empty(k_list))
  assert_that(method %in% c("kf", "loo", "mc", "res"))
  assert_that(noCores <= detectCores())
  assert_that(not_empty(X))
  assert_that(not_empty(y))
  cl <- makeCluster(noCores, type="SOCK", outfile="") 
  registerDoSNOW(cl)
  
  noObs <- dim(X)[1]
  noFeats <- dim(X)[2]
  
  if (method == "res"){
    kList <- k_list
    results<- foreach(k = kList, 
                      .combine=rbind, .packages=c("class", "dplyr")) %dopar% {
                        
                        # some helpful debugging messages
                        
                        # subsetting the training phase data
                        Xtrain <- X
                        Ytrain <- y
                        
                        # kNN results
                        Predictions <- knn(train=Xtrain, test=Xtrain, cl=Ytrain, k=k)
                        Error <- mean(Predictions!=Ytrain)
                        
                        # last thing is returned
                        result <- c(k, Error)
                      }
    stopCluster(cl)
  }
  
  else if (method == "mc"){
    trials <- rep(1:reps, length(k_list))
    kList <- rep(k_list, reps)
    
    
results<- foreach(trial = trials, k = kList, 
                      .combine=rbind, .packages=c("class", "dplyr")) %dopar% {
                        
                        data <- cbind(X,y)
                        data <- data[sample(1:noObs, length(data[,1]),replace=FALSE),]
                        Xtrain <- data[1:floor(noObs*(1-holdout)),1:noFeats]
                        Ytrain <- data[1:floor(noObs*(1-holdout)),(noFeats+1)]
                        
                        # subsetting the test phase data
                        Xtest <- data[(floor(noObs*(1-holdout))+1):noObs,1:noFeats]
                        Ytest <- data[(floor(noObs*(1-holdout))+1):noObs,(noFeats+1)]
                        
                        
                        # kNN results
                        testPredictions <- knn(train=Xtrain, test=Xtest, cl=Ytrain, k=k)
                        testError <- mean(testPredictions != Ytest)
                        
                        # last thing is returned
                        result <- c(trial, k, Error)
                      }
    stopCluster(cl)
  }
  else {
    if (method == "loo"){
      noBuckets <- noObs
    }
    else{
      noBuckets <- nfolds
    }
    # bucket indicator
    idx <- rep(1:noBuckets, each=ceiling(noObs/noBuckets))  
    idx <- idx[sample(1:noObs)]
    idx <- idx[1:noObs]  # if it is an odd number
    
    # adding the variable
    data <- cbind(y,X)
    data <- data %>% mutate(bucketId=idx)
    colnames(data)[1] <- "Y"
    bucketList <- rep(1:noBuckets, length(k_list))
    kList <- rep(k_list, noBuckets)
    results<- foreach(bucket = bucketList, k = kList, 
                      .combine=rbind, .packages=c("class", "dplyr")) %dopar% {
                        
                        # some helpful debugging messages
                        cat("Bucket", bucket, "is the current test set! k=", k, "\n")
                        
                        # subsetting the training phase data
                        Xtrain <- data %>% filter(bucketId != bucket) %>% select(-bucket, -Y)
                        Ytrain <- data %>% filter(bucketId != bucket) %>% select(Y)
                        
                        # subsetting the test phase data
                        Xtest <- data %>% filter(bucketId == bucket) %>% select(-bucket, -Y)
                        Ytest <- data %>% filter(bucketId == bucket) %>% select(Y)
                        
                        # kNN results
                        testPredictions <- knn(train=Xtrain, test=Xtest, cl=Ytrain$Y, k=k)
                        testError <- mean(testPredictions != Ytest$Y)
                        
                        # last thing is returned
                        result <- c(bucket, k, Error)
                      }
    stopCluster(cl)
  }
  return(results)
}