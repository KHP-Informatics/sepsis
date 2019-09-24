
#Read Data

rm(list = ls())

sumit <- function(x){
  s = sum(x)
  return(s)
}


normalise.feature <- function(feature.vector) {
  feature.vector <- feature.vector[!is.na(feature.vector)]
  
  feature.mean = mean(feature.vector)
  #print(paste(" feature mean is: ", feature.mean))
  # mad: mean absolute deviation
  mad = sum(sapply(feature.vector, absolute.mean.difference, mean=feature.mean))/length(feature.vector)
  #print(paste(" mad is: ", mad))
  #robust.z: robust variants of the z-score
  robust.z = sapply(feature.vector, mean.difference, mean=feature.mean)/mad
  return(robust.z)
}

mean.difference <- function(point, mean) {
  diff = point - mean
  return(diff)
}

absolute.mean.difference <- function(point, mean) {
  diff = abs(point - mean)
  return(diff)
}

#1. Read data - has NAs
data.orig = read.csv(file='/Users/babylon/Documents/Sepsis/Data/data.orig.csv')
data.control = read.csv(file='/Users/babylon/Documents/Sepsis/Data/data.control.csv')

#2. only complete sofa scores and age
data.orig <- data.orig[complete.cases(data.orig[,c(69:75,79)]),]
data.control <- data.control[complete.cases(data.control[,c(69:75,79)]),]


#3. Remove spurious/erroneous records:
    #5.1 remove records with no heartrate - records with no administrative data have been removed at the SQL level.
    data.orig = data.orig[which(!(is.na(data.orig$heartrate_min)),]
    data.control =  data.control[which(!(is.na(data.control$heartrate_min))),]

    #5.2 remove all admissions with length of stay less than 24 hours
    data.orig = data.orig[which(data.orig$los >= 1),]
    data.control = data.control[which(data.control$los >= 1),]

    #5.3 remove admissions less than 15 years of age
    data.orig = data.orig[which(data.orig$age > 15),]
    data.control = data.control[which(data.control$age > 15),]

     #5.4 remove columns with more than 15% missingness from all data & controls
    data.orig =  data.orig[ -which(rowMeans(is.na(data.orig)) > 0.15),]

    data.control =  data.control[ -which(rowMeans(is.na(data.control)) > 0.15),]


#6.write to files
write.csv(data.orig, file='/Users/babylon/Documents/Sepsis/Data/data.orig.csv', row.names=FALSE)
write.csv(data.control, file='/Users/babylon/Documents/Sepsis/Data/data.control.csv', row.names=FALSE)


#-----------------
