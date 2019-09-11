#### Extract candidate SV regions
import os,sys
import getopt

def usage():
    print(
"""
usage: python ExtractSVRegions.py -i InputFile -o OutputFile -s breakdancer
-i     : Input file
-o     : Output file
-s     : software used in calling SV (breakdancer or Delly)
-h     : Print this information
""".format(sys.argv[0]))
    sys.exit()

def DellySplit(str):
    tmp = str.split(';')
    record = []
    for t in tmp:
        if t.find('SVTYPE') >= 0:
            index = t.find('=') + 1
            record.append(t[index:])
            break
    for t in tmp:    
        if t.find('END') >= 0:
            index = t.find('=') + 1
            record.append(t[index:])
            break
    return(record)

opts,args = getopt.getopt(sys.argv[1:],"i:o:s:h")
Input = ''
Output = ''
TYPE = ''

for op,value in opts:
    if op == '-i':
        Input = value
    elif op == "-o":
        Output = value
    elif op == "-s":
        TYPE = value
    else:
        usage()
        sys.exit()

if TYPE == 'breakdancer':
    lines = open(Input).readlines()
    result = ''
    for line in lines:
        if line[0] != '#':
            line = line.strip('\n')
            line = line.split('\t')
            result = result + line[1] + '\t' + line[4] + '\t' + line[6] + '\n'
    open(Output,'w').write(result)
elif TYPE == 'Delly':
    lines = open(Input).readlines()
    result = ''
    for line in lines:
        if line[0] != '#':
            line = line.strip('\n')
            line = line.split('\t')
            if line[6] == 'PASS':
                S = line[1]
                tmp = DellySplit(line[7])
                result = result + S + '\t' + tmp[1] + '\t' + tmp[0] + '\n'
    open(Output,'w').write(result)
else:
    if len(sys.argv) == 1:
        usage()
    else:
	    print('Wrong input file type, please check -s parameter.')
