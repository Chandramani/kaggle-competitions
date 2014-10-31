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

prediction_frame<-train_data[c("SOC", "pH", "Ca", "P", "Sand")]

#summary(prediction_frame)

predictor_variable<-train_data[,2:(ncols-6)]

#predictor_variable<-scale(predictor_variable,center=T,scale=T)

PIDN_Frame<-train_data['PIDN']

res <- prcomp(predictor_variable, center = TRUE, scale = TRUE)
pca_predictor_variable<-predict(res,predictor_variable)

# summary(res)
# loadings(res)
# plot(res,type="lines")
# res$scores
# biplot(res)
# names(res)

pca30_predictor_variable<-pca_predictor_variable[,1:1000]

# pc30_predictor_variable<-res$x[,1:30]
# pc30_predictor_variable<-NULL

pca30_predictor_variable<-as.data.frame(pca30_predictor_variable)

pca30_predictor_variable<-cbind(train_data['Depth'],pca30_predictor_variable)

# bestmtry <- tuneRF(pc30_predictor_variable,prediction_frame$SAND, ntreeTry=1000, 
#                    stepFactor=1.5,improve=0.01, trace=TRUE, plot=TRUE, dobest=FALSE)

sand.rf <-randomForest(pca30_predictor_variable,prediction_frame$Sand, mtry=10, ntree=1000, 
                        keep.forest=TRUE, importance=TRUE)
ph.rf <-randomForest(pca30_predictor_variable,prediction_frame$pH, mtry=10, ntree=1000, 
                     keep.forest=TRUE, importance=TRUE)

soc.rf <-randomForest(pca30_predictor_variable,prediction_frame$SOC, mtry=10, ntree=1000, 
                     keep.forest=TRUE, importance=TRUE)

ca.rf <-randomForest(pca30_predictor_variable,prediction_frame$Ca, mtry=10, ntree=1000, 
                      keep.forest=TRUE, importance=TRUE)

p.rf <-randomForest(pca30_predictor_variable,prediction_frame$P, mtry=10, ntree=1000, 
                      keep.forest=TRUE, importance=TRUE)

save(sand.rf,file="sand.rf.obj")
save(ph.rf,file='ph.rf.obj')
save(soc.rf,file='soc.rf.obj')
save(ca.rf,file='ca.rf.obj')
save(p.rf,file='p.rf.obj')

save(res,file='pca.model.obj')

pred_sand<-predict(sand.rf,pca30_predictor_variable)
pred_ph<-predict(ph.rf,pca30_predictor_variable)
pred_soc<-predict(soc.rf,pca30_predictor_variable)
pred_ca<-predict(ca.rf,pca30_predictor_variable)
pred_p<-predict(p.rf,pca30_predictor_variable)


result_predicted<-cbind(pred_ca,pred_p,pred_ph,pred_soc,pred_sand)

result_predicted<-as.data.frame(result_predicted)

RMSE_ca <- sqrt(mean((prediction_frame$Ca - result_predicted$pred_ca)^2))
RMSE_p <- sqrt(mean((prediction_frame$P - result_predicted$pred_p)^2))
RMSE_ph <- sqrt(mean((prediction_frame$pH - result_predicted$pred_ph)^2))
RMSE_soc <- sqrt(mean((prediction_frame$SOC - result_predicted$pred_soc)^2))
RMSE_sand <- sqrt(mean((prediction_frame$Sand - result_predicted$pred_sand)^2))


