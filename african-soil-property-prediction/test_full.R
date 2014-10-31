require('randomForest')
require('ROCR')
# test_data<-read.csv('/home/ctiwary/Documents/data/kaggle/soil/sorted_test.csv',header=T)
# 
# save(test_data,file="test_data.Rda")
# unlink('test_data.Rda')

if(exists('test_data') && is.data.frame(get('test_data')))
{
  print("test_data exists")
} else
{
  print("loading test_data")
  load("test_data.Rda") 
}
nrows<-nrow(test_data)
ncols<-ncol(test_data)

#prediction_frame<-train_data[c("SOC", "pH", "Ca", "P", "Sand")]

#summary(prediction_frame)

predictor_variable<-test_data[,2:ncols]

PIDN_Frame<-test_data['PIDN']

# load('pca.model.obj')
# 
# pca_predictor_variable<-predict(res,predictor_variable)
# 
# 
# pca30_predictor_variable<-pca_predictor_variable[,1:30]
# 
# pca30_predictor_variable<-as.data.frame(pca30_predictor_variable)

pca30_predictor_variable<-predictor_variable

load("sand_full.rf.obj")
load('ph_full.rf.obj')
load('soc_full.rf.obj')
load('ca_full.rf.obj')
load('p_full.rf.obj')

pred_sand<-predict(sand.rf,pca30_predictor_variable)
pred_ph<-predict(ph.rf,pca30_predictor_variable)
pred_soc<-predict(soc.rf,pca30_predictor_variable)
pred_ca<-predict(ca.rf,pca30_predictor_variable)
pred_p<-predict(p.rf,pca30_predictor_variable)


result<-cbind(PIDN_Frame,pred_ca,pred_p,pred_ph,pred_soc,pred_sand)

colnames(result)<-c('PIDN','Ca','P','pH','SOC','Sand')

write.csv(result,file='result_submission.csv',row.names = FALSE)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      