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
Method = Args[10]
setwd(Dir)
outfile = paste0(file,'_corrected.norm.bin')
outfile2 = paste0(OUT,'_statistics.txt')


### Dist to oriC
Dist2oriC <- function(Location,RefL,oriC){
x = c()
for(c in oriC){
x = cbind(x,abs(Location-c))
x = cbind(x,abs(RefL - Location + c))
x = cbind(x,RefL + Location - c)
}
x = apply(x,1,min)
index = intersect(which(Location<= max(oriC)),which(Location>= min(oriC)))
x[index] = 0
return(x)
}

#### Correlation
DistCor <- function(norm.bin,oriC){
	BinLocation = ceiling((norm.bin$start+norm.bin$end)/2)
	RefL = max(norm.bin$end)
	x = c()
	for(c in oriC){
   	x = cbind(x,abs(BinLocation-c))
   	x = cbind(x,RefL - BinLocation + c)
   	x = cbind(x,RefL - c + BinLocation)
	}
	x = apply(x,1,min)
	y = log2((norm.bin$obs+0.01)/norm.bin$expected)
	return(cor.test(x,y,method='spearman'))
}

#### Correction
GuassianCorr <- function(norm.bin,oriC){
	require(mgcv)

	flag = DistCor(norm.bin,oriC)
	if(flag$p.value>0.05) return(norm.bin)
	
	## Remove outlier
	BinLocation = ceiling((norm.bin$start+norm.bin$end)/2)
	RefL = max(norm.bin$end)
	x = Dist2oriC(BinLocation,RefL,oriC)
	x = scale(x)
	y = log2((norm.bin$obs+0.01)/norm.bin$expected)
	fit = gam(y~s(x))
	residuals = fit$residuals
	iqr = IQR(residuals)
	index = which(residuals > quantile(residuals,0.25)-1.5*iqr & residuals < quantile(residuals,0.75)+1.5*iqr)

	## First fitting
	X = x[index]
	Y = y[index]
	fit = gam(Y~s(X)) 
	X = data.frame(X = x)
	pred = predict(fit,X)
	expected = 2^(log2(norm.bin$expected) + pred)

    ## Second fitting 
	y2 = log2((norm.bin$obs+0.01)/expected)
	IQR = quantile(y2,0.75)-quantile(y2,0.25)
	index2 = which(y2 > quantile(y2,0.25)-1.5*IQR & y2 < quantile(y2,0.75)+1.5*IQR)
	X = x[index2]
	Y = y[index2]
	fit = gam(Y~s(X)) 
	X = data.frame(X = x)
	pred = predict(fit,X)
	expected = 2^(log2(norm.bin$expected) + pred)
	norm.bin$expected = round(expected,2)
    return(norm.bin)
}

PoissonCorr <- function(norm.bin,oriC){
	require(mgcv)
	
	flag = DistCor(norm.bin,oriC)
	if(flag$p.value>0.05) return(norm.bin)
	
	## remove outlier
	BinLocation = ceiling((norm.bin$start+norm.bin$end)/2)
	RefL = max(norm.bin$end)
	x1 = Dist2oriC(BinLocation,RefL,oriC)
	x1 = scale(x1)
	x2 = norm.bin$expected
	y = norm.bin$obs
	fit = gam(y~s(x1)+x2,family=poisson())
	residuals = fit$residuals
	iqr = IQR(residuals)
	index = which(residuals > quantile(residuals,0.25)-1.5*iqr & residuals < quantile(residuals,0.75)+1.5*iqr)

	## First fitting
	X1 = x1[index]
	X2 = x2[index]
	Y = y[index]
	fit = gam(Y~s(X1)+X2,family=poisson())
	X = data.frame(X1 = x1, X2 = x2)
	pred = predict(fit,X)
	expected = exp(pred)

	## Second fitting
	y2 = log2((norm.bin$obs+0.01)/expected)
	IQR = quantile(y2,0.75)-quantile(y2,0.25)
	index2 = which(y2 > quantile(y2,0.25)-1.5*IQR & y2 < quantile(y2,0.75)+1.5*IQR)
	X1 = x1[index2]
	X2 = x2[index2]
	Y = y[index2]
	fit = gam(Y~s(X1)+X2,family=poisson())
	X = data.frame(X1 = x1, X2 = x2)
	pred = predict(fit,X)
	expected = exp(pred)
	norm.bin$expected = round(expected,2)
	return(norm.bin)
}

##### Guassian correction
if(Method == 'Gaussian'){
norm.bin = read.table(file,header = T)
norm.bin1 = GuassianCorr(norm.bin,oriC)
write.table(norm.bin1,file=outfile,quote=F,row.names=F,sep='\t')
r = DistCor(norm.bin,oriC)
r = c(r$estimate,r$p.value)
names(r) = c('SpearmanCorrelation','pvalue')
print(r)
write.table(r,file=outfile2,col.names=F,quote=F,sep='\t')
}

##### Poisson correcrion
if(Method == 'Poisson'){
norm.bin = read.table(file,header = T)
norm.bin1 = PoissonCorr(norm.bin,oriC)
write.table(norm.bin1,file=outfile,quote=F,row.names=F,sep='\t')
r = DistCor(norm.bin,oriC)
r = c(r$estimate,r$p.value)
names(r) = c('SpearmanCorrelation','pvalue')
print(r)
write.table(r,file=outfile2,col.names=F,quote=F,sep='\t')
}
