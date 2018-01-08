clear all;
pAddress=5;
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', pAddress, 'Tag', '');

if isempty(obj1)
    g1=gpib('ni',0,pAddress);
else
    fclose(obj1);
    g1 = obj1(1);
end

set(g1,'InputBufferSize',8*50001);              % Standard is 512 ASCII signs that transfers

set(g1,'Timeout',10);
fopen(g1);

fwrite(g1,'AUTOSet EXECute');
fwrite(g1,'MEASUrement:IMMed:SOURCE[1]');

fwrite(g1,'MEASUrement:IMMed:TYPE FREQUENCY');
freq=query(g1,'MEASUrement:IMMed:VALue?')

fwrite(g1,'MEASUrement:IMMed:TYPE Amplitude');
amp=query(g1,'MEASUrement:IMMed:VALue?')