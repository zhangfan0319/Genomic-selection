library(asreml)
library(dyplr)
library(data.table)
setwd("/storage-01/poultrylab1/zhangfan/work/VcfDataBase/density")
##读取数据
data<-asreml.read.table("pheno.txt",header=TRUE,na.strings='NA')
##提取特定表型数据
data %>% drop_na(c(IID2,Batch,Year)) %>% filter(Year == "2014" | Year == "2019" | Year =="2020" ) %>% select(c(IID2,Sex,Batch,Year,trait)) %>% drop_na(trait) -> datag
##G逆矩阵
id <- read.table("ID.txt",header = T," ")
test <- fread("Ginv.csv",header=TRUE,sep=",")
rownames(test) <-test$V1
test <- as.matrix(test)
Ginv <- test[,-1]
attr(Ginv,"rowNames")<-as.character(id$IID)
attr(Ginv,"colNames")<-as.character(id$IID)
attr(Ginv,"INVERSE")<-TRUE
head(Ginv)
##表型数据正态化
#source("/storage-01/poultrylab1/zhangfan/Genome/rntransform.R")
#source("/storage-01/poultrylab1/zhangfan/Genome/ztransform.R")
#ntra <- rntransform(datag[,5],datag,family=gaussian)
##构建参考群和验证群
k = 5 #Folds
datag$id <- sample(1:k, nrow(datag), replace = TRUE)
list <- 1:k

for (i in 1:k){
  ref_id <- subset(datag, id %in% list[-i])
  test_id <- subset(datag, id %in% c(i))

  test_NA <- test_id
  test_NA[,5] <- NA

  refset <- rbind(ref_id,test_NA)
#  valset <- valset[order(valset$sort),]
####构建模型(固定效应里不能有缺失)
modelGBLUP <- asreml(fixed=trait ~ 1 + Batch + Sex,
               random=~vm(IID2,Ginv),residual = ~idv(units),
               workspace=128e06,
               data=refset)

dir.create("/storage-01/poultrylab1/zhangfan/work/VcfDataBase/density/100kb/Ginv")
var <- summary(modelGBLUP)$varcomp
write.table(var,"/storage-01/poultrylab1/zhangfan/work/VcfDataBase/density/100kb/Ginv/trait_var.txt",append=T,col.names=FALSE,row.names=FALSE)
h2<-vpredict(modelGBLUP,h2~V1/(V1+V2))
write.table(h2,"/storage-01/poultrylab1/zhangfan/work/VcfDataBase/density/100kb/Ginv/trait_h2.txt",append=T,col.names=FALSE,row.names=FALSE)
BLUP <- summary(modelGBLUP,coef=TRUE)$coef.random
write.csv(BLUP,"/storage-01/poultrylab1/zhangfan/work/VcfDataBase/density/100kb/Ginv/GEBV_trait.csv")
####查看准确度
GEBV <- BLUP[grep(paste0(test_id$IID2,collapse = "|"),rownames(BLUP),),]
IID2 <- matrix(unlist(strsplit(as.character(rownames(GEBV)), ')_')), ncol=2,byrow=TRUE)[,2]
solution <- as.data.frame(GEBV)[,1]
after <- cbind(IID2,solution)
after <- as.data.frame(after)
final <- left_join(after,test_id,by="IID2")
final <- as.data.frame(final)
a <- as.numeric(final$solution)
b <- as.numeric(final$trait)
cor <- cor(a,b,method='pearson',use="complete.obs")
write.table(cor,"/storage-01/poultrylab1/zhangfan/work/VcfDataBase/density/100kb/Ginv/trait_cor.txt",append=T,row.names = FALSE, col.names=FALSE)
}
