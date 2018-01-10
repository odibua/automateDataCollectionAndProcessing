function scopeObj = initializeDigOsc(pAddressScope)
%pAddressScope=5;

scopeObj = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', pAddressScope, 'Tag', '');

if isempty(scopeObj)
    scopeObj=gpib('ni',0,pAddressScope);
else
    fclose(scopeObj);
    scopeObj = scopeObj(1);
end

set(scopeObj,'InputBufferSize',8*50001);              % Standard is 512 ASCII signs that transfers

set(scopeObj,'Timeout',10);
%Connect to hardware
fopen(scopeObj);
end