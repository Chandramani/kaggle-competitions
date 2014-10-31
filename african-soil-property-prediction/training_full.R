require('randomForest')

# train_data<-read.csv('/home/ctiwary/Documents/data/kaggle/soil/training.csv',header=T)
# 
# save(train_data,file="train_data.Rda")
# unlink('test_data.Rda')

if(exists('train_data') && is.data.frame(get('train_data')))
{
  print("train_data exists")
} else
{
  print("loading train data")
  load("train_data.Rda") 
}
nrows<-nrow(train_data)
ncols<-ncol(train_data)

prediction_frame<-train_data[c("Ca","P","pH","SOC","Sand")]

predictor_variable<-train_data[,2:(ncols-5)]

PIDN_Frame<-train_data['PIDN']

pca30_predictor_variable<-predictor_variable


train_data_p<-train_data
train_data_p$PIDN<-NULL
train_data_p$P<-NULL
# bestmtry <- tuneRF(pca30_predictor_variable,prediction_frame$Sand, ntreeTry=1500, 
#                    stepFactor=1.5,improve=0.01, trace=TRUE, plot=TRUE, dobest=FALSE)
# print(bestmtry)
bestmtry=1200

sand.rf <-randomForest(pca30_predictor_variable,prediction_frame$Sand, mtry=bestmtry, ntree=1500, 
                       keep.forest=TRUE, importance=TRUE,replace=T)
ph.rf <-randomForest(pca30_predictor_variable,prediction_frame$pH, mtry=bestmtry, ntree=1500, 
                     keep.forest=TRUE, importance=TRUE,replace=T)

soc.rf <-randomForest(pca30_predictor_variable,prediction_frame$SOC, mtry=bestmtry, ntree=1500, 
                      keep.forest=TRUE, importance=TRUE,replace=T)

ca.rf <-randomForest(pca30_predictor_variable,prediction_frame$Ca, mtry=bestmtry, ntree=1500, 
                     keep.forest=TRUE, importance=TRUE,replace=T)

p.rf <-randomForest(train_data_p,prediction_frame$P, mtry=bestmtry, ntree=1500, 
                    keep.forest=TRUE, importance=TRUE,replace=T)

save(sand.rf,file="sand_full.rf.obj")
save(ph.rf,file='ph_full.rf.obj')
save(soc.rf,file='soc_full.rf.obj')
save(ca.rf,file='ca_full.rf.obj')
save(p.rf,file='p_full.rf.obj')


load("sand_full.rf.obj")
load('ph_full.rf.obj')
load('soc_full.rf.obj')
load('ca_full.rf.obj')
load('p_full.rf.obj')

pred_sand<-predict(sand.rf,pca30_predictor_variable)
pred_ph<-predict(ph.rf,pca30_predictor_variable)
pred_soc<-predict(soc.rf,pca30_predictor_variable)
pred_ca<-predict(ca.rf,pca30_predictor_variable)
pred_p<-predict(p.rf,train_data_p)


result_predicted<-cbind(pred_ca,pred_p,pred_ph,pred_soc,pred_sand)

result_predicted<-as.data.frame(result_predicted)

RMSE_ca <- sqrt(mean((prediction_frame$Ca - result_predicted$pred_ca)^2))
RMSE_p <- sqrt(mean((prediction_frame$P - result_predicted$pred_p)^2))
RMSE_ph <- sqrt(mean((prediction_frame$pH - result_predicted$pred_ph)^2))
RMSE_soc <- sqrt(mean((prediction_frame$SOC - result_predicted$pred_soc)^2))
RMSE_sand <- sqrt(mean((prediction_frame$Sand - result_predicted$pred_sand)^2))







