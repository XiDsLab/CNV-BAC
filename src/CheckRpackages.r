LIST=.packages(all.available=T)
## check mgcv
flag = sum(LIST == 'mgcv')
if(flag){
print('Package mgcv is available.')
}else{
print('ERROR: Package mgcv is not available.')
}

## check graph
flag = sum(LIST == 'graph')
if(flag){
print('Package graph is available.')
}else{
print('ERROR: Package graph is not available.')
}
