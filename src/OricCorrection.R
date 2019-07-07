###########################################################
#####       Remove the effects of distance to oriC
##### Input 1: norm.bin file
##### Input 2: start of oriC Regions (Seperated by comma)
##### Linjie Wu 2019.6.21
###########################################################
require('mgcv')
Args = commandArgs()
file = Args[6]
oriC = as.numeric(strsplit(Args[7],',')[[1]])
Dir = Args[8]
OUT = Args[9]
setwd(Dir)
outfile = paste0(file,'_corrected.norm.bin')
outfile2 = paste0(OUT,'_GR.txt')

### load
norm.bin = read.table(file,header = T)
BinLocation = ceiling((norm.bin$start+norm.bin$end)/2)
RefL = max(norm.bin$end)+1
x = c()
for(c in oriC){
   x = cbind(x,abs(BinLocation-c))
   x = cbind(x,RefL - BinLocation + c)
   x = cbind(x,RefL - c + BinLocation)
}
x = apply(x,1,min)
y = log2((norm.bin$obs+0.01)/norm.bin$expected)

## GAM
x = scale(x)
index = intersect(which(y<quantile(y,0.95)),which(y>quantile(y,0.05)))
X = x[index]
Y = y[index]
fit = gam(Y~s(X))
X = data.frame(X = x)
pred = predict(fit,X)
expected = 2^(log2(norm.bin$expected) + pred)
norm.bin$expected = round(expected,2)
write.table(norm.bin,file=outfile,quote=F,row.names=F,sep='\t')

## Correlation
r = c(cor(x,y,method='spearman'),cor(x,y,method='pearson'))
r = round(r,3)
names(r) = c('SpearmanCorrelation','pearsonCorrelation')
print(r)
print(paste0('The length of reference sequences is ',as.character(RefL)))
write.table(r,file=outfile2,col.names=F,quote=F,sep='\t')
