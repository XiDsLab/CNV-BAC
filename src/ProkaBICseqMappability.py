## Generate mappability file for ProkaBICseq
import os,sys
readLength = sys.argv[1]
output = sys.argv[2]

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

open(output+'_mappability','w').write(result)
