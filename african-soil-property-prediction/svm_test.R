#test_data<-read.csv('/home/ctiwary/Documents/data/kaggle/soil/sorted_test.csv',header=T,stringsAsFactor=F)
#save(test_data,file="test_data_withoutFactor.Rda")
test_data<-NULL
if(exists('test_data') && is.data.frame(get('test_data')))
{
  print("test_data exists")
} else
{
  print("loading test_data")
  load("test_data_withoutFactor.Rda") 
}

test_data['Depth'][test_data['Depth']=='Topsoil']<-'0'
test_data['Depth'][test_data['Depth']=='Subsoil']<-'1'
test_data['Depth']<-as.factor(test_data$Depth)

nrows<-nrow(test_data)
ncols<-ncol(test_data)

#prediction_frame<-train_data[c("SOC", "pH", "Ca", "P", "Sand")]

#summary(prediction_frame)

predictor_variable<-test_data[,2:3578]

PIDN_Frame<-test_data['PIDN']

pca30_predictor_variable<-scale(predictor_variable,center=T,scale=T)
pca30_predictor_variable<-cbind(pca30_predictor_variable,train_data$depth)

# load('pca.model.obj')
# 
# pca_predictor_variable<-predict(res,predictor_variable)
# 
# 
# pca30_predictor_variable<-pca_predictor_variable[,1:50]

pred_p<-predict(svm.fit_p,pca30_predictor_variable)
pred_ca<-predict(svm.fit_ca,pca30_predictor_variable)
pred_sand<-predict(svm.fit_sand,pca30_predictor_variable)
pred_ph<-predict(svm.fit_ph,pca30_predictor_variable)
pred_soc<-predict(svm.fit_soc,pca30_predictor_variable)

result<-cbind(PIDN_Frame,pred_ca,pred_p,pred_ph,pred_soc,pred_sand)

colnames(result)<-c('PIDN','Ca','P','pH','SOC','Sand')

write.csv(result,file='result_submission.csv',row.names = FALSE)
