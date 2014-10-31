require(e1071)
require(caret)

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

svms <- lapply(1:ncol(labels),
               function(i)
               {
                 obj <- tune.svm(train_num, labels[,i],gamma = 10^(-6:-1), cost = 10^(1:2))
                 print("the tuned object values" )
                 summary(obj)
                 #                  svm(train_num,labels[,i],cost=10000,scale=FALSE)
               })


predictions <- sapply(svms,predict,newdata=test_num)
predictions_train <- sapply(svms,predict,newdata=train_num)

colnames(predictions) <- c("Ca","P","pH","SOC","Sand")
submission <- cbind(PIDN=submission,predictions)

write.csv(submission,"beating_benchmark_extended_2.0.csv",row.names=FALSE,quote=FALSE)

RMSE_ca <- sqrt(mean((labels$Ca - predictions_train[,1])^2))
RMSE_p <- sqrt(mean((labels$P - predictions_train[,2])^2))
RMSE_ph <- sqrt(mean((labels$pH - predictions_train[,3])^2))
RMSE_soc <- sqrt(mean((labels$SOC - predictions_train[,4])^2))
RMSE_sand <- sqrt(mean((labels$Sand - predictions_train[,5])^2))

print((RMSE_p+RMSE_ph+RMSE_soc+RMSE_sand+RMSE_ca)/5)
