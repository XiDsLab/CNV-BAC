######################################################################
####   CNV-BAC: Call copy number variations for bacteria
####   Aurthor: Linjie Wu
####   Date: 20190926
######################################################################
import os,sys,getopt

#### Set paths
SoftwareDir="/home/ruibinxi_pkuhpc/lustre1/ljwu/software/CNV-BAC"

def usage(SoftwareDir):
    print "Program: CNV-BAC (Call copy number variations for prokaryote.)"
    print "Usage: CNV-BAC [options]"
    print "      -h  display help info."
    print "      -i  bam file generate by BWA. (required)"
    print "      -s  Location of origin of replications seperated by comma (required), one can get this information from DoriC database http://tubic.org/doric/public/index.php/index."
    print "      -r  fasta file of reference file. (required)"
    print "      -m  Mappability file (required)"
    print "      -l  penalty for BIC-seq2 (Default 1.5)"
    print "      -o  prefix of output file (Default CNV-BAC_tmp)."
    print "      -b  length of bin. (Defaut 1000)"
    print "      -p  subsample percentage for normalization. (Default 0.5)"
    print "      -d  the directory for output files. (Default "+ SoftwareDir + "/tmp)"
    print "      --norm method for correction of normalization either Gaussian or Poisson (Default Gaussian)"
    print "      --SV SV regions file (Default FALSE)"
    print "      --PT Pvalue cutoff for CNVs detection (Default 0.001)"
    print "      --RT log 2 copy number ratio cutoff for CNVs detection (Default 0.2)"
    print "example: python CNV-BAC.py -i input.bam -r reference.fa -s start_of_Oric_region,end_of_Oric_region -m Mappability -l 4"


def main(argv,SoftwareDir):
    ## Set Paths
    Samtools=SoftwareDir + "/src/samtools-0.1.7a_getUnique-0.1.3/samtools"
    BICNorm=SoftwareDir + "/src/BICseq2-norm_v0.2.6/BICseq2-norm.pl"
    BICSeg=SoftwareDir + "/src/BICseq2-seg_v0.7.3/BICseq2-seg.pl"
    GenerateConf=SoftwareDir + "/src/GenerateConf.py"
    OriCorrect=SoftwareDir + "/src/OricCorrection.R"
    Genotype=SoftwareDir + "/src/BICseq2-seg_v0.7.3/genotype.pl"
    CNVseg=SoftwareDir + "/src/SVbreaksCluster.r"
    AddMap=SoftwareDir + "/src/AddMappability.r"
    
    # Set default parameters
    OUT="ProkaBIC-seq_tmp"
    tmp_dir=SoftwareDir + "/tmp"
    BIN="1000"
    REF=""
    ORloc=""
    BAMINPUT=""
    LAMBDA="1.5"
    MAPfile=""
    PROB="0.5"
    NORM="Gaussian"
    PT="0.001"
    RT="0.2"
    SV="FALSE"

    # Load parameters
    try:
        opts, args = getopt.getopt(argv,"hi:o:s:r:d:b:m:l:p:",["norm=","SV=","PT=","RT="])
    except getopt.GetoptError:
        usage(SoftwareDir)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            usage(SoftwareDir)
            sys.exit()
        elif opt in ("-i"):
            BAMINPUT=arg
        elif opt in ("-o"):
            OUT=arg
        elif opt in ("-s"):
            ORloc=arg
        elif opt in ("-r"):
            REF=arg
        elif opt in ("-d"):
            tmp_dir=arg
        elif opt in ("-b"):
            BIN=arg
        elif opt in ("-m"):
            MAPfile=arg
        elif opt in ("-l"):
            LAMBDA=arg
        elif opt in ("-p"):
            PROB=arg
        elif opt in ("--norm"):
            NORM=arg
        elif opt in ("--SV"):
            SV=arg
        elif opt in ("--PT"):
            PT=arg
        elif opt in ("--RT"):
            RT=arg

    # Check input parameters
    if REF == "" or ORloc == "" or BAMINPUT == "" or MAPfile=="":
        usage(SoftwareDir)
        print "Please check input parameters"
        sys.exit()

    # Normalization
    os.system(Samtools+' view -U BWA,'+tmp_dir+'/chr,N,N '+BAMINPUT)
    os.system('mv '+tmp_dir+'/chr*.seq '+tmp_dir+'/'+OUT+'.seq')

    # Generate config files
    os.system('python '+GenerateConf+' '+REF+' '+tmp_dir+' '+OUT+' '+MAPfile)

    # Bining
    os.system(BICNorm+' -p '+PROB+' -b '+BIN+' --tmp '+tmp_dir+'/tmp '+tmp_dir+'/conf_1 '+tmp_dir+'/'+OUT+'_norm.out')
     
    ## Replication bias correction
    os.system('Rscript '+OriCorrect+' '+tmp_dir+'/'+OUT+'.norm.bin '+ORloc+' '+tmp_dir+' '+OUT+' '+NORM)

    ## Segment
    os.system(BICSeg+' --lambda '+LAMBDA+' --bootstrap --tmp '+tmp_dir+'/tmp '+tmp_dir+'/conf_2 '+tmp_dir+'/'+OUT+'_seg.out')
    os.system('rm '+tmp_dir+'/conf*'+' '+tmp_dir+'/*.seq')

    ## CNV detection
    os.system('Rscript '+CNVseg+' '+SV+' '+'/'+OUT+'_norm.bin.norm.bin_corrected.norm.bin '+tmp_dir+'/'+OUT+'_seg.out '+tmp_dir+' '+Genotype+' '+OUT+' '+PT+' '+RT)
    
    ## Add mappability
    os.system('Rscript '+AddMap+' '+tmp_dir+'/'OUT+'.CNVs '+BIN)
    
if __name__ == "__main__":
   main(sys.argv[1:],SoftwareDir)
