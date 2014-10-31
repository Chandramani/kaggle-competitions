require(e1071)

train <- read.csv("./training.csv",header=TRUE,stringsAsFactors=FALSE)
test <- read.csv("./sorted_test.csv",header=TRUE,stringsAsFactors=FALSE)

submission <- test[,1]

labels <- train[,c("Ca","P","pH","SOC","Sand")]

# Exclude CO2
train <- train[,c(2:2655,2671:(ncol(train)-5))]
test <- test[,c(2:2655,2671:ncol(test))]

idx_to_use <- read.csv("./non_correlated_index.csv",header=F,stringsAsFactors=FALSE)
idx_to_use <- t(idx_to_use)

##Handle depth as a 0/1 variable
train$Depth <-  with ( train, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )
test$Depth <-  with ( test, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) ) 



svms <- lapply(1:ncol(labels),
               function(i)
               {
                 svm(train,labels[,i],cost=10000,scale=FALSE)
               })

predictions <- sapply(svms,predict,newdata=test)

colnames(predictions) <- c("Ca","P","pH","SOC","Sand")
submission <- cbind(PIDN=submission,predictions)

write.csv(submission,"beating_benchmark_extended_2.0.csv",row.names=FALSE,quote=FALSE)


print("So far so good")
