perceptron <- function(type = "train", X, y = NULL, max_epochs = 5, w = NULL, b = 0, trace = F){
  library(assertthat)
  assert_that(not_empty(X))
  if (type == "train"){
    assert_that(length(y) == length(X[,1]))
    # if y is a dataframe convert to double
    if (typeof(y) != "double") {
      y <- as.numeric(y)
    }
  }
  if (type == "predict"){
    assert_that(w != NULL)
    assert_that(typeof(w) == "double")
  }
  
  
  #make sure y is a vector, not a matrix
  assert_that(is.null(dim(y)) )
  
  if (typeof(X) == "list"){
    X <- as.matrix(X)
  }
  noCols <- length(X[1,])
  noObs <- length(X[,1])
  #shuffle
  data <- cbind(X, y)
  
  data <- data[sample(1:length(data[,1]), length(data[,1]),replace=FALSE),]
  X <- data[, 1:noCols]
  y <- data[, (noCols+1)]
  
  #holding two copies could be troublesome with large datasets so discard "data" by making it an empty vector
  data <- c()
  
  # now we are ready to go - make the magic happen
  if (type == "train" & trace == F){
    for ( i in 1:max_epochs){
      # initialize weigths 
      if (i == 1){
        w = rep(0, noCols)
      }
      
      
      
      for(j in 1:noObs){
        activation <- (w %*% as.numeric(X[j,]))+b
        
        activation <- activation[1]
        if ((y[j]*activation) <= 0){
          w <- w + (y[j]*as.numeric(X[j,]))
          b <- b + y[j]
          
        }
      }
      #compute the training predictions and the training error
      preds <- w %*% t(X)+b
      preds <- ifelse(preds <= 0,-1,1)
      error <- 1- (mean(preds == y))
      # stop if error is zero
      if (error == 0) break
    }
    trace_frame <- NA
  }
  else if(type == "train" & trace == T){
    error_vec <- c()
    for ( i in 1:max_epochs){
      # initialize weigths 
      if (i == 1){
        w = rep(0, noCols)
        preds <- w %*% t(X)+b
        preds <- ifelse(preds <= 0,-1,1)
        error <- 1- (mean(preds == y))
        error_vec <- c(error_vec, error)
      }
      
      
      
      
      
      for(j in 1:noObs){
        activation <- (w %*% as.numeric(X[j,]))+b
        
        activation <- activation[1]
        
        if ((y[j]*activation) <= 0){
          w <- w + (y[j]*as.numeric(X[j,]))
          b <- b + y[j]
          
        }
        #compute the training predictions and the training error
        preds <- w %*% t(X)+b
        preds <- ifelse(preds <= 0,-1,1)
        error <- 1- (mean(preds == y))
        error_vec <- c(error_vec, error)
      }
      
      # stop if error is zero
      if (error == 0) break
    }
    iter <- seq(1,length(error_vec),1)
    trace_frame <- data.frame(cbind(iter, error_vec))
    names(trace_frame) <- c("Iter", "Error")
  }
  
  else {
    preds <- w %*% t(X)+b
    preds <- ifelse(preds <= 0,-1,1)
    error <- NA
    trace_frame <- NA
  }
  

  return(list(error = error, trace_frame = trace_frame, preds = preds, w= w, b = b))
  
}