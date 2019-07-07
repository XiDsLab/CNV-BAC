LIST=.packages(all.available=T)
flag = sum(LIST == 'mgcv')
if(flag){
print('Package mgcv is available.')
}else{
print('ERROR: Package mgcv is not available.')
}
