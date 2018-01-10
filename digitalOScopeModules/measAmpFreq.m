function [freqCh1,vPkPkCh1,highCh1,lowCh1,freqCh2,vPkPkCh2,highCh2,lowCh2] = measAmpFreq(scopeObj)
fwrite(scopeObj,'REM “Set up the measurement parameters”');
fwrite(scopeObj,'MEASUrement:IMMed:SOURCE1 CH1');
fwrite(scopeObj,'MEASUrement:IMMed:TYPE FREQUENCY');
freqCh1=str2num(query(scopeObj,'MEASUrement:IMMed:VALue?'));
fwrite(scopeObj,'MEASUrement:IMMed:TYPE High');
highCh1=str2num(query(scopeObj,'MEASUrement:IMMed:VALue?'));
fwrite(scopeObj,'MEASUrement:IMMed:TYPE Low');
lowCh1=str2num(query(scopeObj,'MEASUrement:IMMed:VALue?'));
fwrite(scopeObj,'MEASUrement:IMMed:TYPE PK2pk');
vPkPkCh1=str2num(query(scopeObj,'MEASUrement:IMMed:VALue?'));

fwrite(scopeObj,'MEASUrement:IMMed:SOURCE1 CH2');
fwrite(scopeObj,'MEASUrement:IMMed:TYPE FREQUENCY');
freqCh2=str2num(query(scopeObj,'MEASUrement:IMMed:VALue?'));
fwrite(scopeObj,'MEASUrement:IMMed:TYPE High');
highCh2=str2num(query(scopeObj,'MEASUrement:IMMed:VALue?'));
fwrite(scopeObj,'MEASUrement:IMMed:TYPE Low');
lowCh2=str2num(query(scopeObj,'MEASUrement:IMMed:VALue?'));
fwrite(scopeObj,'MEASUrement:IMMed:TYPE PK2pk');
vPkPkCh2=str2num(query(scopeObj,'MEASUrement:IMMed:VALue?'));
fwrite(scopeObj,'REM “Wait until the acquisition is complete before taking the measurement”');
fwrite(scopeObj,'While BUSY? keep looping');
fwrite(scopeObj,'REM “Take amplitude measurement on acquired data”');

end