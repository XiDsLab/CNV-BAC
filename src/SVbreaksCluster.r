#####################################################################
############        Cluster SV break BreakPoints        #############
#####################################################################
## load
Args = commandArgs()
SV.file = Args[6]
norm.file = Args[7]
seg.file = Args[8]
OutDir = Args[9]
Software = Args[10]
Out_prex = Args[11]
PT = as.numeric(Args[12])
RT = as.numeric(Args[13])

## Extract CNVs
FilterBICseqResult <- function(file,mark='Coverage',pThreshold=0.001,ratioThreshold=0.2){
    SEG = read.table(file,header=T)
    SEG$pvalue = SEG$pvalue*length(SEG$pvalue)/order(SEG$pvalue)
    SEG = SEG[SEG$pvalue < pThreshold,]
    SEG = SEG[abs(SEG$log2.copyRatio) > ratioThreshold,]
    SEG$mark = rep(mark,dim(SEG)[1])
    return(SEG)
}

SVClusterAndTest <- function(SV.file,norm.file,seg.file,OutDir,Software,Out_prex,PT,RT){
    require(graph)
    # preprocessing SV file
    if(file.info(SV.file)$size == 0 || SV.file == 'FALSE'){
        seg = FilterBICseqResult(seg.file,mark='Coverage',pThreshold=PT,ratioThreshold=RT)
        write.table(seg,paste0(OutDir,'/',Out_prex,'.CNVs'),quote=F,row.names=F,sep='\t')
        q(save='no')
    }else{
        SV = read.table(SV.file)
        refL = max(read.table(norm.file,header=T)$end)
        Length = SV$V2 - SV$V1 + 1
        index = intersect(which(Length>200),which(Length<refL/2))
        SV = SV[index,]
        SVpoints = sort(unique(c(SV$V1,SV$V2)))
    }

    # connect graph
    if(dim(SV)[1]>0){
        g <- new("graphNEL", nodes=as.character(SVpoints), edgemode="undirected")
        for(i in 1 : length(SVpoints)){
            for(j in i : length(SVpoints)){
                if(abs(SVpoints[i]-SVpoints[j])>100) next
                S = as.character(SVpoints[i])
                E = as.character(SVpoints[j])
                g <- addEdge(S,E,g)
            }
        }
        temp = connComp(g)
        BreakPoints = c()
        for(i in 1 : length(temp)) BreakPoints = c(BreakPoints,median(as.numeric(temp[[i]])))
        BreakPoints = sort(BreakPoints)
        BreakPoints = BreakPoints[BreakPoints < refL]
        n = length(BreakPoints)
        BreakPoints = data.frame(chrName=rep('chr',n+1),start=c(1,BreakPoints),
            end=c(BreakPoints,refL))
        write.table(BreakPoints,file=paste0(OutDir,'/SVcandidateRegions_',Out_prex,'.txt'),
            quote=F,row.names=F,sep='\t')
    }else{
        seg = FilterBICseqResult(seg.file,mark='Coverage',pThreshold=PT,ratioThreshold=RT)
        write.table(seg,paste0(OutDir,'/',Out_prex,'.CNVs'),quote=F,row.names=F,sep='\t')
        q(save='no')
    }

    # permuation test
    config = data.frame(chrName='chr',Location=norm.file)
    write.table(config,file=paste0(OutDir,'/config_sv_',Out_prex),sep='\t',quote=F,row.names=F)
    cmd = paste(Software,paste0(OutDir,'/config_sv_',Out_prex),paste0(OutDir,'/SVcandidateRegions_',Out_prex,'.txt'),
        paste0(OutDir,'/SVRegionsPvalue_',Out_prex,'.txt'))
    system(cmd)

    # Combine SV segments with CNV detected by coverage method
    seg = FilterBICseqResult(seg.file,mark='Coverage',pThreshold=PT,ratioThreshold=RT)
    SVseg = FilterBICseqResult(paste0(OutDir,'/SVRegionsPvalue_',Out_prex,'.txt'),mark='Pair-end',pThreshold=PT,ratioThreshold=RT)
    n_sv = dim(SVseg)[1]
    n_cov = dim(seg)[1]
    if(n_sv >0 && n_cov >0){
        for(i in 1 : n_sv){
            s1 = SVseg$start[i]
            e1 = SVseg$end[i]
            for(j in 1 : n_cov){
            flag = min(seg$end[j],e1)-max(seg$start[j],s1)
            flag = flag/(seg$end[j] - seg$start[j] + 1)
            if(flag > 0.5){
                seg$mark[j] = 'Coverage & Pair-end'
                break
                }
            }
            if(flag > 0.5) next else seg = rbind(seg,SVseg[i,])
        }
        write.table(seg,paste0(OutDir,'/',Out_prex,'.CNVs'),quote=F,row.names=F,sep='\t')
    }
    if(n_sv > 0 && n_cov == 0) write.table(SVseg,paste0(OutDir,'/',Out_prex,'.CNVs'),quote=F,row.names=F,sep='\t')
    if(n_sv == 0 && n_cov >=0) write.table(seg,paste0(OutDir,'/',Out_prex,'.CNVs'),quote=F,row.names=F,sep='\t')

    # remove temporary files
    system(paste('rm',paste0(OutDir,'/SVRegionsPvalue_',Out_prex,'.txt')))
    system(paste('rm',paste0(OutDir,'/config_sv_',Out_prex)))
    system(paste('rm',paste0(OutDir,'/SVcandidateRegions_',Out_prex,'.txt')))
    q(save='no')
}
SVClusterAndTest(SV.file,norm.file,seg.file,OutDir,Software,Out_prex,PT,RT)


