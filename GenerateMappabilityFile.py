###########################################################
####     Generate mappability file for ProkaBIC-seq    ####
###########################################################
import os,sys
softwaredir='/home/ljwu/software/ProkaBIC-seq'
gemtools_dir = softwaredir+'/src/gemtools-1.7.1-i3/bin/'
CMD = 'export PATH='+gemtools_dir+':$PATH'
os.system(CMD)
# refFile = sys.argv[1]
# readLength = sys.argv[2]
# output = sys.argv[3]
refFile = '/home/ljwu/ProkaPaper/ref/Ecoil.fasta'
readLength = '150'
output = '/home/ljwu/software/test/Ecoil'

### Transform reference to 70 length each row
## unfold (Circular DNA)
ref = ''
f = open(refFile)
line = f.readline()
while line:
    if line[0] == '>':
        tag = line
    else:
        ref = ref + line.strip('\n')
    line = f.readline()

f.close()

## reshape
os.system('rm '+ output + '_mappability.ref')
f = open(output+'_mappability.ref','a')
f.write(tag)
for c in range(0,len(ref),50):
    f.write(ref[c:min(c+50,len(ref))] + '\n')

## gemtools_index
CMD = 'gem-indexer -T 4 -c dna -i ' + output + '_mappability.ref'  + ' -o ' + output
os.system(CMD)

## calculate mappability
CMD =  'gem-mappability -T 4 -I ' + output + '.gem -l ' + readLength + ' -o ' + output
os.system(CMD)
CMD = 'gem-2-wig -I '+output+'.gem -i ' + output +'.mappability -o ' + output + '_' + readLength
os.system(CMD)

## reshape
f = open(output+'_'+readLength+'.wig')
line = f.readline()
result = ''
while line:
    if line.find('variableStep') >= 0:
        if line.find('span') >= 0:
            index = line.rfind('=') +1
            L = int(line[index:-1])
        else:
            L = 1
    else:
        tmp = line.strip('\n')
        tmp = tmp.split('\t')
        mappability = float(tmp[1])
        if mappability == 1:
            S = int(tmp[0]) - 1 
            E = int(tmp[0]) + L -2
            result = result + str(S) + '\t' + str(E) + '\n'
    line = f.readline()

f.close()
open(output+'_mappbaility','w').write(result)
os.system('rm '+ output +'*.*')

