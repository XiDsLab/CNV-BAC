# CNV-BAC
Copy number variation detection for bacteria circular DNA high-throughput sequencing data.

# Download
git clone https://github.com/LinjieWu/CNV-BAC.git

# Requirments
R version >= 2.6

R package 'mgcv' and 'graph'

Python2

# Set up
cd /PATH/TO/CNV-BAC

python setup.py


# Usage
Usage: python CNV-BAC.py [options]

      -h  display help info.
      
      -i  bam file generate by BWA. (required)
      
      -s  Location of origin of replications seperated by comma (required), one can get this information from DoriC database http://tubic.org/doric/public/index.php/index.
      
      -r  fasta file of reference file. (required)
      
      -m  Mappability file (required)
      
      -l  penalty for BIC-seq2 (Default 1.5)
      
      -o  prefix of output file (Default CNV-BAC_tmp).
      
      -b  length of bin. (Defaut 1000)
      
      -p  subsample percentage for normalization. (Default 0.5)
      
      -d  the directory for output files. (Default /home/ruibinxi_pkuhpc/lustre1/ljwu/software/CNV-BAC/tmp)
      
      --norm method for correction of normalization either Gaussian or Poisson (Default Gaussian)
      
      --SV SV regions file (Default FALSE)
      
      --PT Pvalue cutoff for CNVs detection (Default 0.001)
      
      --RT log 2 copy number ratio cutoff for CNVs detection (Default 0.2)

## Example for detection of copy number varations
Step 1: Generate mappability file

See https://github.com/LinjieWu/GenerateMappability

Step 2: Extract SV regions from Breakdancer or Delly results (optional)

/Path/to/CNV-BAC/ExtractSVRegions.py -i BreakDancer.out -o SV.out -s breakdancer

Step 3: Filter CNVs

python CNV-BAC.py -i input.bam -r reference.fa -s start_of_Oric_region,end_of_Oric_region -m example_mappability -l 2 -SV SV.out

# Output files
*_mappability: Regions of reference with mappability 1 (calculated by gemtools).

*_GR.txt: spearman correlation, pearson correlation between log2 copy number ratio and distance to origin of replication.

*_seg.out: Segmentation result for CNV calling.

*_norm.out： Record the parameters for normalization.

*.norm.bin: Normalized, GC corrected and oriC corrected counts.

*.CNVs: Detected CNVs.
