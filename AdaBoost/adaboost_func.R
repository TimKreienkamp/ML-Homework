

adaPredict <- function(X, tree_list, alpha_vec){
  noObs <- dim(X)[1]
  preds <- rep(0, noObs)
  n_components <- length(tree_list)
  
  for (j in 1:n_components){
    h_1 <- ifelse(predict(tree_list[[j]], type = "class")  == "1", 1, -1)
    preds = preds + alpha_vec[j]*h_1
    
  }
  preds <- sign(preds)
  return(preds)
}



adaTrain <- function(formula, input, depth = 1, iter =5 ){
  
  error_vec <- rep(0, iter)
  ###rpart can only cope with formulas which force me to do some messy hacking here
  
  #make sure the formula is actually a formula
  formula <- as.formula(formula)
 
  # subset y, we need it later 
  y <- get_all_vars(formula[-length(formula)],input)
  
  #get the index of y in the input data frame
  y_ind <- grep(names(y), colnames(input))
  
  # get the names of the features
  X_cols <- setdiff(names(input), names(y))
  
  #convert the Class column to a factor so rpart can actually do classification and won't jump to regression
  input[names(y)] <- as.factor(input[, y_ind])
  
  iter = iter
  
  n <- dim(input)[1]
  #initialize the weight vector
  w <- rep((1/n), n)
  #initialize the sequence of alphas that control the importance of each classifier
  alpha_vec <- rep(NA, iter)
  #and the list of classifiers (trees)
  tree_list <- list()
  
  # make sure w and the formula are in the same environment
  
  environment(formula) = sys.frame(sys.nframe())
  
  y <- as.numeric(y[,1])
  #start boosting
  for (i in 1:iter){

    #train a stump
    tree <- rpart(formula, input, control = c(maxdepth = depth), weights = w, method = "class")
   
    # make predictions
    
    h <- predict(tree, type = "class")
    
    # working around R's "factor" BS
    h <- ifelse(h == "1", 1, -1)
    #obtain the weighted error
    weighted_error <- 0.5-(0.5*(sum(w*y*h)))
    print(weighted_error)
    #obtain the contribution factor
    alpha <- 0.5*log((1-weighted_error)/weighted_error)
    #update weights and re-normalize
    w <- w * exp ( (-y) * alpha * h) 
    w <- w * 1/sum(w)
    
    #store the contrubtion factor and the classifier 
    alpha_vec[i] <- alpha
    tree_list[[i]] <- tree
    
    #obtain in-sample predictions and error
    train_preds <- adaPredict(input[X_cols], tree_list, alpha_vec)
    error <- mean(train_preds != y)
    
    if (error == 0){
      error_vec[i] <- error
      error_vec <- error_vec[1:i]
      alpha_vec <- alpha_vec[1:i]
      break
    }
    error_vec[i] <- error
   
  }
  error <- error_vec[i]
  return(list(error = error, error_vec = error_vec, tree_list = tree_list, alpha_vec = alpha_vec))
}

