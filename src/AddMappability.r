### Add mappability
Args = commandArgs()
file = Args[6]
binL = as.numeric(Args[7])

CNVs = read.table(file,header=T,sep='\t') 
CNVs$Mappability = binL*CNVs$binNum/(CNVs$end-CNVs$start + 1)
write.table(CNVs,file=file,sep='\t',quote=F,row.names=F)
