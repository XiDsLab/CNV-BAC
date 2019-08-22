import os,sys
dir = os.getcwd()

## Main code
f = open('ProkaBIC-seq')
tmp = ''
line = f.readline()
while line:
    if line.find('SoftwareDir') == 0:
        tmp = tmp + 'SoftwareDir="' + dir + '"\n'
    else:
        tmp = tmp + line
    line = f.readline()
open('ProkaBIC-seq','w').write(tmp)

## Main code
f = open('GenerateMappabilityFile.sh')
tmp = ''
line = f.readline()
while line:
    if line.find('SoftwareDir') == 0:
        tmp = tmp + 'SoftwareDir="' + dir + '"\n'
    else:
        tmp = tmp + line
    line = f.readline()
open('GenerateMappabilityFile.sh','w').write(tmp)

CMD = 'tar xf ' + dir +'/src/BICseq2-norm_v0.2.6.tar.gz -C ' + dir + '/src/'
os.system(CMD)
CMD = 'tar xf ' + dir +'/src/BICseq2-seg_v0.7.3.tar.gz -C '+ dir + '/src/'
os.system(CMD)
CMD = 'tar xf ' + dir +'/src/samtools-0.1.7a_getUnique-0.1.3.tar.gz -C '+ dir + '/src/'
os.system(CMD)
CMD = 'rm ' + dir +'/src/*.tar.gz'
os.system(CMD)
CMD = 'Rscript ' + dir+'/src/CheckRpackages.r'
os.system(CMD)
os.system('chmod 775 ProkaBIC-seq')
os.system('chmod 775 GenerateMappabilityFile.sh')
