function Data=getTEKtrace(scopeObj,GPIB,CHstring)
%Data=getTEKtrace(GPIB,CHstring)
% Retrives single trace from most Tektronix osilloscopes
% Tested with TDS 3k 2k and 784 series
% Aswell as HP-54120B
%
% GPIB: Instrument GPIB adress
% CHstring: string/num chanel number '1','2' etc or 'Ref1' etc...
%
% Output: Data <#x2>
%
% Version 2012-07-12




% obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', GPIB, 'Tag', '');
% 
% if isempty(obj1)
%     scopeObj=gpib('ni',0,GPIB);
% else
%     fclose(obj1);
%     scopeObj = obj1(1);
% end
% 
% set(scopeObj,'InputBufferSize',8*50001);              % Standard is 512 ASCII signs that transfers
% 
% set(scopeObj,'Timeout',10);
% fopen(scopeObj);
IDN=query(scopeObj,'*IDN?');

if strcmp(IDN(1:9),'TEKTRONIX')
    switch CHstring(1)
        case {1, 2, 3, 4}
            CHstring=['CH' num2str(CHstring)];
        case {'1', '2', '3', '4'}
            CHstring=['CH' CHstring];
    end
    trash=query(scopeObj,'wfmpre?'); %this should get most of the needed data
    fprintf(scopeObj,['DATa:SOUrce ' CHstring]);
    fprintf(scopeObj,'DATa:ENCdg ASCII');
    fprintf(scopeObj,'DATa:WIDth 2'); % '1' = 8 bit, '2' = 16 bit
    fprintf(scopeObj,'DATa:STArt 1');
    xLength=query(scopeObj,'HORizontal:RECordlength?');
    fprintf(scopeObj,['DATa:STOp ' xLength]);
    xLength=str2double(xLength);
    if xLength>10000
        set(scopeObj,'Timeout',60);
    end
    value=str2num(query(scopeObj,'CURve?'));
    Ymult=str2num(query(scopeObj,['WFMPre:' CHstring ':Ymult?']));
    Yoff=str2num(query(scopeObj,['WFMPre:' CHstring ':Yoff?']));
    value=(value-Yoff)*Ymult;
    xUnit=query(scopeObj,['WFMPre:' CHstring ':XUNit?']);
    yUnit=query(scopeObj,['WFMPre:' CHstring ':YUNit?']);
    units={xUnit,yUnit};
    
    startTime=str2num(query(scopeObj,['WFMPre:' CHstring ':XZEro?']));
    timeDiv=str2num(query(scopeObj,['WFMPre:' CHstring ':XINcr?']));
    
    IDN=query(scopeObj,['*IDN?']);
    if strcmpi(IDN(1:18),'TEKTRONIX,TDS 784A')
        time=startTime+((0:length(value)-1)-length(value)/2)*timeDiv;
    else
        time=startTime+(0:length(value)-1)*timeDiv;
    end
else
    
    
    fprintf(obj1, 'ACQ:TYPE NORM;POINTS 1028');
    fprintf(obj1, ['DIG CHAN' CHstring]);
    fprintf(obj1, ['WAV:SOUR WMEM' CHstring ';FORM ASCII']);
    Waveform = str2num(query(obj1, 'WAV:DATA?'));
    
    Prem=str2num(query(obj1, ['WAV:SOUR WMEM' CHstring ';PRE?']));
    Xinc=Prem(5);
    Xor=Prem(6);
    Xref=Prem(7);
    Yinc=Prem(8);
    Yor=Prem(9);
    Yref=Prem(10);

    value=(Waveform-Yref)*Yinc+Yor;
    
    time=1:length(value);
    time=(time-Xref)*Xinc+Xor;
end

%fclose(scopeObj);

Data=[time' value'];