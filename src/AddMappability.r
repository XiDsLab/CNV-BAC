### Add mappability
Args = commandArgs()
file = Args[6]
binL = as.numeric(Args[7])

CNVs = read.table(file,header=T,sep='\t') 
CNVs$Mappability = (CNVs$end-CNVs$start + 1)/binL/CNVs$binNum
write.table(CNVs,file=file,sep='\t',quote=F,row.names=F)
