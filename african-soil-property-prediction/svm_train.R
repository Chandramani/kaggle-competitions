library(e1071)

#load('pca.model.obj')

if(exists('train_data') && is.data.frame(get('train_data')))
{
  print("train_data_withoutFactor exists")
} else
{
  print("loading train data")
  load("train_data_withoutFactor.Rda") 
}

train_data['Depth'][train_data['Depth']=='Topsoil']<-'0'
train_data['Depth'][train_data['Depth']=='Subsoil']<-'1'
train_data['Depth']<-as.factor(train_data$Depth)

nrows<-nrow(train_data)
ncols<-ncol(train_data)

prediction_frame<-train_data[c("SOC", "pH", "Ca", "P", "Sand")]

#summary(prediction_frame)

predictor_variable<-train_data[,2:3578]

#pca_predictor_variable<-predict(res,predictor_variable)

#pca30_predictor_variable<-pca_predictor_variable[,1:50]

pca30_predictor_variable<-scale(predictor_variable,center=T,scale=T)
pca30_predictor_variable<-cbind(pca30_predictor_variable,train_data$depth)
#pca30_predictor_variable<-cbind(train_data['Depth'],pca30_predictor_variable)

svm.fit_p<-svm(x=pca30_predictor_variable,y=prediction_frame$P, type="eps-regression", kernel="polynomial"
               ,gamma=0.02,cost=50,degree=2)
svm.fit_ca<-svm(x=pca30_predictor_variable,y=prediction_frame$Ca, type="eps-regression", kernel="polynomial"
                ,gamma=0.02,cost=50,degree=2)
svm.fit_sand<-svm(x=pca30_predictor_variable,y=prediction_frame$Sand, type="eps-regression", kernel="polynomial"
                  ,gamma=0.02,cost=50,degree=2)
svm.fit_ph<-svm(x=pca30_predictor_variable,y=prediction_frame$pH, type="eps-regression", kernel="polynomial"
                ,gamma=0.02,cost=50,degree=2)
svm.fit_soc<-svm(x=pca30_predictor_variable,y=prediction_frame$SOC, type="eps-regression", kernel="polynomial"
                 ,gamma=0.02,cost=50,degree=2)

pred_p<-predict(svm.fit_p,pca30_predictor_variable)
pred_ca<-predict(svm.fit_ca,pca30_predictor_variable)
pred_sand<-predict(svm.fit_sand,pca30_predictor_variable)
pred_ph<-predict(svm.fit_ph,pca30_predictor_variable)
pred_soc<-predict(svm.fit_soc,pca30_predictor_variable)

RMSE_p <- sqrt(mean((prediction_frame$P - pred_p)^2))
RMSE_ca <- sqrt(mean((prediction_frame$Ca - pred_ca)^2))
RMSE_soc <- sqrt(mean((prediction_frame$pH - pred_ph)^2))
RMSE_ph <- sqrt(mean((prediction_frame$SOC - pred_soc)^2))
RMSE_sand <- sqrt(mean((prediction_frame$Sand - pred_sand)^2))

print((RMSE_p+RMSE_ph+RMSE_soc+RMSE_sand+RMSE_ca)/5)
