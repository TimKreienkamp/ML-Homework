library(mvtnorm)

sigmaXY <- function(rho, sdX, sdY) {
  covTerm <- rho * sdX * sdY
  VCmatrix <- matrix(c(sdX^2, covTerm, covTerm, sdY^2), 
                     2, 2, byrow = TRUE)
  return(VCmatrix)
}

genBVN <- function(n = 1, seed = NA, muXY=c(0,1), sigmaXY=diag(2)) {
  if(!is.na(seed)) set.seed(seed)
  rdraws <- rmvnorm(n, mean = muXY, sigma = sigmaXY)
  return(rdraws)
}



catsAndDogs <- function(noCats, noDogs, muCats, muDogs, sdCats, 
                        sdDogs, rhoCats, rhoDogs, seed=1111) {
  sigmaCats <- sigmaXY(rho=rhoCats, sdX=sdCats[1], sdY=sdCats[2])
  sigmaDogs <- sigmaXY(rho=rhoDogs, sdX=sdDogs[1], sdY=sdDogs[2])
  cats <- genBVN(noCats, muCats, sigmaCats, seed = seed)
  dogs <- genBVN(noDogs, muDogs, sigmaDogs, seed = seed+1)
  animalsDf <- as.data.frame(rbind(cats,dogs))
  Animal <- c(rep("Cats", noCats), rep("Dogs", noDogs))
  animalsDf <- cbind(animalsDf, Animal)
  colnames(animalsDf) <- c("weight", "height", "Animal")
  return(animalsDf)
}

