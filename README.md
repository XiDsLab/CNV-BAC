# ProkaBIC-seq
Copy number calling and growth rate calculation for prokaryote.

# Requirments
R version >= 2.6
and R package 'quantreg'

# Set up
python setup.py
Then add the path of ProkaBIC-seq to envrionment.

# Usage
## Example for calculate growth rate
ProkaBIC-seq -i input.bam -r reference.fa -s start_of_Oric_region,end_of_Oric_region -b 1000

## Example for detection of copy number varations
ProkaBIC-seq -i input.bam -r reference.fa -s start_of_Oric_region,end_of_Oric_region -b 1000 -m NormAndSeg -l 8
