require(e1071)

train <- read.csv("./training.csv",header=TRUE,stringsAsFactors=FALSE)
test <- read.csv("./sorted_test.csv",header=TRUE,stringsAsFactors=FALSE)

submission <- test[,1]

labels <- train[,c("Ca","P","pH","SOC","Sand")]

idx_to_use <- read.csv("./non_correlated_index.csv",header=F,stringsAsFactors=FALSE)
idx_to_use <- t(idx_to_use)

idx_to_use<-idx_to_use[!(idx_to_use>2655 & idx_to_use<2671)]

train_smo<-train[,-1]
test_smo<-test[,-1]
# Exclude CO2
train_smo <- train_smo[idx_to_use]
test_smo <- test_smo[idx_to_use]

##Handle depth as a 0/1 variable
train_smo$Depth <-  with ( train, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )
test_smo$Depth <-  with ( test, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) ) 



svms <- lapply(1:ncol(labels),
               function(i)
               {
                 svm(train_smo,labels[,i],cost=10000,scale=FALSE)
               })

predictions <- sapply(svms,predict,newdata=test_smo)

colnames(predictions) <- c("Ca","P","pH","SOC","Sand")
submission <- cbind(PIDN=submission,predictions)

write.csv(submission,"beating_benchmark_extended_2.0.csv",row.names=FALSE,quote=FALSE)


print("So far so good")
