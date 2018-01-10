function funGenObj = initializeFuncGen(pAddressFunGen)
%pAddressFunGen=1;
% Create a GPIB object.
funGenObj = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', pAddressFunGen, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(funGenObj)
    funGenObj = gpib('ni', 0, pAddressFunGen);
else
    fclose(funGenObj); 
    funGenObj = funGenObj(1);
end
%Connect to hardware
fopen(funGenObj);

% Set both outputs to off
fwrite(funGenObj,'OUTP1:STAT OFF');
fwrite(funGenObj,'OUTP2:STAT OFF');

% Set output impedances of channel 1&2 to High Z
% fwrite (funGenObj, 'OUTP1:IMP INF');
% fwrite (funGenObj, 'OUTP2:IMP INF');

% Set source waveform
sineWaveForm='SOUR1:FUNC:SHAP SIN '; 
sineWaveForm2='SOUR2:FUNC:SHAP SIN '; 
squareWaveForm='SOUR1:FUNC:SHAP SQUARE '; 
fwrite(funGenObj , sineWaveForm);
fwrite(funGenObj , sineWaveForm2);
end
