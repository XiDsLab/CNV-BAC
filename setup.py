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

CMD = 'Rscript ' + dir+'/src/CheckRpackages.r'
os.system(CMD)
