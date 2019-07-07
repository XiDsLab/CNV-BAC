#################################################
##      Measure the length of reference
## usage: python RefLength.py /Path/to/reference/ref.fa /Path/to/output
import os,sys
ref = sys.argv[1]
dir = sys.argv[2]
OUT = sys.argv[3]
if ref[0] != '/':
    ref = os.getcwd() + '/' + ref
if dir[-1] == '/':
    dir = dir[:-1]

c = 0
f = open(ref)
line = f.readline()
while line:
    if line[0] != '>':
        c = c + len(line.strip('\n'))
    line = f.readline()
f.close()

## Generate Mapfile
tmp = '0 '+str(c-1)+'\n'
open(dir+'/chr.txt','w').write(tmp)

## Generate config file
Mapfile = dir + '/chr.txt'
readPosFile = dir + '/' + OUT +'.seq'
binFileNorm = dir + '/' + OUT +'.norm.bin' 

# For normalization
conf_1 = 'romName\tfaFile\tMapfile\treadPosFile\tbinFileNorm\n'
conf_1 = conf_1 + 'chr\t' + ref+ '\t' + Mapfile + '\t' + readPosFile + '\t' + binFileNorm +'\n'
open(dir+'/conf_1','w').write(conf_1) 

# For segmentation
conf_2 = 'romName\tbinFileNorm\n'
conf_2 = conf_2 + 'chr\t' + dir +'/' + OUT + '.norm.bin\n'
open(dir+'/conf_2','w').write(conf_2)

# For segmentation
conf_3 = 'romName\tbinFileNorm\n'
conf_3 = conf_3 + 'chr\t' + dir +'/' + OUT + '.norm.bin_corrected.norm.bin\n'
open(dir+'/conf_3','w').write(conf_3)

