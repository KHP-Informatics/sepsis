rm(list = ls())
zerodays <- function(some.string){
  some.number = 0
  if (some.string == ''){
    some.number = 0
  }
  else{
    some.number = as.numeric(some.string)
  }
  return(some.number)
}


# Read all data
data.orig= read.csv(file='/Users/babylon/Documents/Sepsis/Data/data.orig.csv')
data.control= read.csv(file='/Users/babylon/Documents/Sepsis/Data/data.control.csv')

############################ A. PROCESS FULL FEATURES
# 1. convert length of stay to numeric
days <- substr(data.orig[,"los"], 1, regexpr(' day',data.orig[,"los"]))
days = sapply(X=days,FUN=zerodays)
hours <- as.numeric(substr(data.orig[,"los"], regexpr(':',data.orig[,"los"])-2, regexpr(':',data.orig[,"los"])-1))
los.numerical <- days+(hours/24)
data.orig[,"los"] = los.numerical



days <- substr(data.control[,"los"], 1, regexpr(' day',data.control[,"los"]))
days = sapply(X=days,FUN=zerodays)
hours <- as.numeric(substr(data.control[,"los"], regexpr(':',data.control[,"los"])-2, regexpr(':',data.control[,"los"])-1))
los.numerical <- days+(hours/24)
data.control[,"los"] = los.numerical



# 2. make wbc between 0 and 1
data.orig[,"whitebloodcellcount_min"] = data.orig[,"whitebloodcellcount_min"]/1000000
data.control[,"whitebloodcellcount_max"] = data.control[,"whitebloodcellcount_max"]/1000000


# 3. drop unneeded columns
drops <- c("adm","admittime","sbj","dob")

data.orig = data.orig[, !(colnames(data.orig)
                                        %in% drops)]

data.control = data.control[, !(colnames(data.control)
%in% drops)]

# 4. convert dead to numeric instead of boolean
data.orig$dead = as.numeric(data.orig$dead)
data.control$dead = as.numeric(data.control$dead)


# 5. convert gender from F/M to 1/0
data.orig$gender  = as.numeric(as.factor(data.orig$gender))   ###makes M = 2 and F = 1
data.orig$gender[data.orig$gender == 2] <- 0 ###makes M = 0

data.control$gender  = as.numeric(as.factor(data.control$gender))   ###makes M = 2 and F = 1
data.control$gender[data.control$gender == 2] <- 0 ###makes M = 0



# 6. Write Data
write.csv(data.orig, file='/Users/babylon/Documents/Sepsis/Data/data.orig.csv', row.names=FALSE)
write.csv(data.control, file='/Users/babylon/Documents/Sepsis/Data/data.control.csv', row.names=FALSE)



