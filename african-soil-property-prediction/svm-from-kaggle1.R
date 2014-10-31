require(e1071)

train <- read.csv("./training.csv",header=TRUE,stringsAsFactors=FALSE)
test <- read.csv("./sorted_test.csv",header=TRUE,stringsAsFactors=FALSE)

submission <- test[,1]

labels <- train[,c("Ca","P","pH","SOC","Sand")]

# Exclude CO2
train_num <- train[,c(2:2655,2671:(ncol(train)-6))]
test_num <- test[,c(2:2655,2671:(ncol(test)-1))]

train_num <- as.data.frame(scale(train_num,scale=T,center=T))
test_num <- as.data.frame(scale(test_num,scale=T,center=T))

##Handle depth as a 0/1 variable
train_num$Depth <-  with ( train, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )
test_num$Depth <-  with ( test, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )

# svms <- lapply(1:ncol(labels),
#                function(i)
#                {
#                  obj <- tune.svm(train_num, labels[,i],gamma = 10^(-6:-1), cost = 10^(1:2))
#                  print("the tuned object values" )
#                  summary(obj)
#                  svm(train_num,labels[,i],cost=10000,scale=FALSE)
#                })

svm_ca <-svm(train_num,labels[,1],cost=100,gamma=0.0001,scale=FALSE)
svm_p <-svm(train_num,labels[,2],cost=10,gamma=0.05,scale=FALSE)
svm_ph <-svm(train_num,labels[,3],cost=100,gamma=0.0001,scale=FALSE)
svm_soc <-svm(train_num,labels[,4],cost=100,gamma=0.0001,scale=FALSE)
svm_sand <-svm(train_num,labels[,5],cost=100,gamma=0.0001,scale=FALSE)

# options("scipen"=100, "digits"=4)
# for(obj in svms)
# {
#   print(obj$best.parameters$cost)
#   print(obj$best.parameters$gamma)
# }

predictions_ca <- predict(svm_ca,newdata=test_num)
predictions_p <- predict(svm_p,newdata=test_num)
predictions_ph <- predict(svm_ph,newdata=test_num)
predictions_soc <- predict(svm_soc,newdata=test_num)
predictions_sand <- predict(svm_sand,newdata=test_num)
predictions<-cbind(predictions_ca,predictions_p,predictions_ph,predictions_soc,predictions_sand)

predictions_train_ca <- predict(svm_ca,newdata=train_num)
predictions_train_p <- predict(svm_p,newdata=train_num)
predictions_train_ph <- predict(svm_ph,newdata=train_num)
predictions_train_soc <- predict(svm_soc,newdata=train_num)
predictions_train_sand <- predict(svm_sand,newdata=train_num)

colnames(predictions) <- c("Ca","P","pH","SOC","Sand")
submission <- cbind(PIDN=submission,predictions)

write.csv(submission,"beating_benchmark_extended_2.0.csv",row.names=FALSE,quote=FALSE)

RMSE_ca <- sqrt(mean((labels$Ca - predictions_train_ca)^2))
RMSE_p <- sqrt(mean((labels$P - predictions_train_p)^2))
RMSE_ph <- sqrt(mean((labels$pH - predictions_train_ph)^2))
RMSE_soc <- sqrt(mean((labels$SOC - predictions_train_soc)^2))
RMSE_sand <- sqrt(mean((labels$Sand - predictions_train_sand)^2))

print((RMSE_p+RMSE_ph+RMSE_soc+RMSE_sand+RMSE_ca)/5)



