###########################################################
#####       Remove the effects of distance to oriC
##### Input 1: norm.bin file
##### Input 2: start of oriC Regions (Seperated by comma)
##### Linjie Wu 2019.3.26
###########################################################
require(quantreg)
Args = commandArgs()
file = Args[6]
oriC = as.numeric(strsplit(Args[7],',')[[1]])
Dir = Args[8]
OUT = Args[9]
setwd(Dir)
outfile = file
outfile2 = paste0(OUT,'_GR.txt')

### load
norm.bin = read.table(file,header = T)
BinLocation = ceiling((norm.bin$start+norm.bin$end)/2)
RefL = max(norm.bin$end)+1
x = c()
for(c in oriC){
   x = cbind(x,abs(BinLocation-c))
   x = cbind(x,abs(RefL - BinLocation + c))
}
x = apply(x,1,min)
y = log2((norm.bin$obs+0.01)/norm.bin$expected)

## Median regression
fit = rq(y~scale(x),tau = 0.5)
expected = 2^(log2(norm.bin$expected) + scale(x)*fit$coefficients[2])
norm.bin$expected = round(expected,3)
write.table(norm.bin,file=outfile,quote=F,row.names=F,sep='\t')

## Correlation
r = c(cor(x,y,method='spearman'),cor(x,y,method='pearson'),fit$coefficients[2])
r = round(r,3)
names(r) = c('SpearmanCorrelation','pearsonCorrelation', 'QuantileRegression')
print(r)
print(paste0('The length of reference sequences is ',as.character(RefL)))
write.table(r,file=outfile2,col.names=F,quote=F,sep='\t')
