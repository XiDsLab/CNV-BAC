import os,sys
dir = os.getcwd()
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

CMD = 'chmod 775 ' + dir +'/ProkaBIC-seq'
os.system(CMD)
CMD = 'chmod 775 ' + dir +'/src/BICseq2-seg_v0.7.3/*.pl'
os.system(CMD)
CMD = 'chmod 775 ' + dir +'/src/BICseq2-norm_v0.2.6/*.pl'
os.system(CMD)
CMD = 'chmod 775 ' + dir +'/src/samtools-0.1.7a_getUnique-0.1.3/samtools'
os.system(CMD)
CMD = 'Rscript ' + dir+'/src/CheckRpackages.r'
os.system(CMD)
