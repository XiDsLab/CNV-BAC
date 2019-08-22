#reshape referfence sequence
import os,sys
refFile = sys.argv[1]
readLength = sys.argv[2]
output = sys.argv[3]

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
if os.path.exists(output+'_mappability.ref'):
    os.system('rm '+output+'_mappability.ref')
f = open(output+'_mappability.ref','a')
f.write(tag)
for c in range(0,len(ref),50):
    f.write(ref[c:min(c+50,len(ref))] + '\n')
