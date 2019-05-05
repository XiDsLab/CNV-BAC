LIST=.packages(all.available=T)
flag = sum(LIST == 'quantreg')
if(flag){
print('Package quantreg is available.')
}else{
print('ERROR: Package quantreg is not available.')
}
