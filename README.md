# CNV-BAC
Copy number detection and growth rate calculation for prokaryote.

# Download
git clone https://github.com/LinjieWu/CNV-BAC.git

# Requirments
R version >= 2.6
R package 'mgcv' and 'graph'

# Set up
cd /PATH/TO/CNV-BAC

python setup.py

Add the path of CNV-BAC to envrionment.

# Usage
ProkaBIC-seq require the origin of replication for reference genome. For the references from NCBI database, origin of replications can get from http://tubic.org/doric/public/index.php/index.

## Example for detection of copy number varations
Step 1: Generate mappability file

See https://github.com/LinjieWu/GenerateMappability

Step 2: Extract SV regions from Breakdancer or Delly results

/Path/to/CNV-BAC/ExtractSVRegions.py -i BreakDancer.out -o SV.out -s breakdancer

Step 3: Filter CNVs

CNV-BAC -i input.bam -r reference.fa -s start_of_Oric_region,end_of_Oric_region -m example_mappability -l 2 -SV SV.out

# Output files
*_mappability: Regions of reference with mappability 1 (calculated by gemtools).

*_GR.txt: spearman correlation, pearson correlation between log2 copy number ratio and distance to origin of replication.

*_seg.out: Segmentation result for CNV calling.

*_norm.out： Record the parameters for normalization.

*.norm.bin: Normalized, GC corrected and oriC corrected counts.

*.CNVs: Detected CNVs.
