#!/bin/bash
refFile=$1
readLength=$2
output=$3

SoftwareDir=
export PATH=${SoftwareDir}/src/gemtools-1.7.1-i3/bin/:$PATH

### Reshape reference
python ${SoftwareDir}/src/ReshapeReference.py ${refFile} ${readLength} ${output}

### gemtools
gem-indexer -T 4 -c dna -i ${output}_mappability.ref -o ${output}
gem-mappability -T 4 -I ${output}.gem -l ${readLength} -o ${output}
gem-2-wig -I ${output}.gem -i ${output}.mappability -o ${output}_${readLength}
 
### Generate mappability for ProkaBIC-seq
python ${SoftwareDir}/src/CNV-BACMappability.py ${readLength} ${output}

### remove temporary files
rm ${output}.gem
rm ${output}.log
rm ${output}_mappability.ref
rm ${output}.mappability
rm ${output}_${readLength}.sizes
rm ${output}_${readLength}.wig