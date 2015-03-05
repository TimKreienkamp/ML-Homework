setwd("/users/timkreienkamp/documents/studium/data_science/machine_learning/problem_sets/ML-Homework/Perceptron")
library(ggplot2)
source("Perceptron_Clean_2.R")
source("generate_cats_dogs_data.R")





########seperable case#######
#generate lineraly seperable data first
noCats <- 50; noDogs <- 50; muCats <- c(4, 150); muDogs <- c(10, 80); 
sdCats <- c(1,20); sdDogs <- c(2,30);
rhoCats= -0.1; rhoDogs = 0.8; 

animalsDf <- catsAndDogs(noCats, noDogs, muCats, muDogs, sdCats, 
                          sdDogs, rhoCats, rhoDogs, seed=1111)
                         
        

animalsDf$Label <- ifelse(animalsDf$Animal == "Cats", 1, -1)
y <- animalsDf$Label
X <- animalsDf[,1:2]

results <- perceptron(X=X, y=y, trace = T)

# compute the seperating hyperplane
b <- results$b
w <- results$w
xx <- sort(X[,1])
a <- -w[1]/w[2]
hyperplane <- (a*xx)-(b/w[1])


boundaryDf <- data.frame(cbind(xx,hyperplane))
boundaryDf$Animal <- rep("Boundary", 100)
names(boundaryDf) <- c("weight", "height", "Animal")
boundaryAnimalsDf <- rbind(animalsDf, boundaryDf)



seperable <- ggplot(data = animalsDf, aes(x = height, y = weight, 
                             colour=Animal, fill=Animal)) + 
  geom_point() +
  xlab("Height") +
  ylab("Weight") +
  theme_bw(base_size = 14, base_family = "Helvetica") + 
  geom_line(data=boundaryDf) + 
  scale_color_manual("Animal", 
                     values = c("Boundary" = "grey", "Cats" = "blue", "Dogs" = "red"))

convergence_1 <- ggplot(data = results$trace_frame, aes (x= Iter, y=Error)) + geom_line()


############### higer radius #######




noCats <- 50; noDogs <- 50; muCats <- c(4, 150); muDogs <- c(10, 80); 
sdCats <- c(1,20); sdDogs <- c(2,30);
rhoCats= -0.1; rhoDogs = 0.8; 

animalsDf <- catsAndDogs(noCats, noDogs, muCats, muDogs, sdCats, 
                         sdDogs, rhoCats, rhoDogs, seed=1111)



animalsDf$Label <- ifelse(animalsDf$Animal == "Cats", 1, -1)
y <- animalsDf$Label
X <- animalsDf[,1:2]

results <- perceptron(X=X, y=y, trace = T)

xx <- sort(X[,1])
b <- results$b
w <- results$w

a <- -w[1]/w[2]

hyperplane <- (a*xx)-(b/w[1])

boundaryDf <- data.frame(cbind(xx,hyperplane))
boundaryDf$Animal <- rep("Boundary", 100)
names(boundaryDf) <- c("weight", "height", "Animal")
boundaryAnimalsDf <- rbind(animalsDf, boundaryDf)



# illustrating the data
seperable_higher_radius <- ggplot(data = animalsDf, aes(x = height, y = weight, 
                                          colour=Animal, fill=Animal)) + 
  geom_point() +
  xlab("Height") +
  ylab("Weight") +
  theme_bw(base_size = 14, base_family = "Helvetica") + 
  geom_line(data=boundaryDf) + 
  scale_color_manual("Animal", 
                     values = c("Boundary" = "grey", "Cats" = "blue", "Dogs" = "red"))
convergence_2 <- ggplot(data = results$trace_frame, aes (x= Iter, y=Error)) + geom_line()

####non seperable case####


noCats <- 50; noDogs <- 50; muCats <- c(10, 150); muDogs <- c(8, 130); 
sdCats <- c(1,20); sdDogs <- c(2,30);
rhoCats= -0.1; rhoDogs = 0.8; 



animalsDf <- catsAndDogs(noCats, noDogs, muCats, muDogs, sdCats, 
                         sdDogs, rhoCats, rhoDogs, seed=1111)



animalsDf$Label <- ifelse(animalsDf$Animal == "Cats", 1, -1)
y <- animalsDf$Label
X <- animalsDf[,1:2]

results <- perceptron(X=X, y=y, trace = T, max_epochs = 20)

xx <- sort(X[,1])
b <- results$b
w <- results$w

a <- -w[1]/w[2]

hyperplane <- (a*xx)-(b/w[1])

boundaryDf <- data.frame(cbind(xx,hyperplane))
boundaryDf$Animal <- rep("Boundary", 100)
names(boundaryDf) <- c("weight", "height", "Animal")
boundaryAnimalsDf <- rbind(animalsDf, boundaryDf)



# illustrating the data
non_seperable <- ggplot(data = animalsDf, aes(x = height, y = weight, 
                                                        colour=Animal, fill=Animal)) + 
  geom_point() +
  xlab("Height") +
  ylab("Weight") +
  theme_bw(base_size = 14, base_family = "Helvetica") + 
  geom_line(data=boundaryDf) + 
  scale_color_manual("Animal", 
                     values = c("Boundary" = "grey", "Cats" = "blue", "Dogs" = "red"))

convergence_3 <- ggplot(data = results$trace_frame, aes (x= Iter, y=Error)) + geom_line()
