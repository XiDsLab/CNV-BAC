# ProkaBIC-seq
Copy number detection and growth rate calculation for prokaryote.

# Download
git clone https://github.com/LinjieWu/ProkaBIC-seq.git

# Requirments
R version >= 2.6
and R package 'mgcv'

# Set up
cd /PATH/TO/ProkaBIC-seq

python setup.py

Add the path of ProkaBIC-seq to envrionment.

# Usage
ProkaBIC-seq require the origin of replication for reference genome. For the references from NCBI database, origin of replications can get from http://tubic.org/doric/public/index.php/index.

## Example for detection of copy number varations
/Path/to/ProkaBIC-seq/GenerateMappabilityFile.sh reference.fa 150 example
ProkaBIC-seq -i input.bam -r reference.fa -s start_of_Oric_region,end_of_Oric_region -m example_mappability -l 2

# Output files
*_GR.txt: Growth rate measured by spearman correlation, pearson correlation and coefficient of quantile regression.

*_seg.out: Segmentation result for CNV calling. Since prokaryote are haplotype, we recomand use 0.5 and -0.5 as the thresholds for CNV gain and loss.

*_norm.out： Record the parameters for normalization.

*.norm.bin: Normalized, GC corrected and oriC corrected counts.
