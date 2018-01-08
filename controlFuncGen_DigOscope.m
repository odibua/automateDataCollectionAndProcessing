clc; %clear all;
nFreq=40;
nSeconds=3;
nTrials=2;
freqCutOff = 100e6;
freq = logspace(4,log10(freqCutOff),nFreq);
vPP= [2.5 , 2.5, 1];

freqMeasCh1 = zeros(nFreq,1);
highMeasCh1 = zeros(nFreq,1);
lowMeasCh1 = zeros(nFreq,1);
vPkPkCh1 = zeros(nFreq,1);


freqMeasCh2 = zeros(nFreq,1);
highMeasCh2 = zeros(nFreq,1);
lowMeasCh2 = zeros(nFreq,1);
vPkPkCh2 = zeros(nFreq,1);


freqMeasCh1Cell = {};
highMeasCh1Cell = {};
lowMeasCh1Cell = {};


freqMeasCh2 = zeros(nFreq,1);
highMeasCh2 = zeros(nFreq,1);
lowMeasCh2 = zeros(nFreq,1);

freqMeasCh2Cell = {};
highMeasCh2Cell = {};
lowMeasCh2Cell = {};


pAddressFunGen=1;
pAddressScope=5;
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', pAddressScope, 'Tag', '');
obj2 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', pAddressFunGen, 'Tag', '');

if isempty(obj1)
    g1=gpib('ni',0,pAddressScope);
else
    fclose(obj1);
    g1 = obj1(1);
end

if isempty(obj2)
    g2=gpib('ni',0,pAddressFunGen);
else
    fclose(obj2);
    g2 = obj2(1);
end

set(g1,'InputBufferSize',10*50001);              % Standard is 512 ASCII signs that transfers

set(g1,'Timeout',40);
fopen(g1);

%Connect to hardware
fopen(g2);

for trial=1:nTrials
% Set both outputs to off
fwrite(g2,'OUTP1:STAT OFF');
fwrite(g2,'OUTP2:STAT OFF');

% Set source waveform
sineWaveForm='SOUR1:FUNC:SHAP SIN ';  
fwrite(g2 , sineWaveForm) 

freqIDX=1;
vPPIDX=1;
% Set frequency and voltage
fwrite (g2 ,[ 'SOUR1:VOLT:AMPL ' num2str(vPP(vPPIDX)) 'VPP']);
fwrite(g2, ['SOUR1:FREQ:FIX ' num2str(freq(freqIDX)) 'Hz']);

%Turn output on
fwrite(g2,'SOUR1:VOLT:CONC:STAT ON');
fwrite(g2,'SOUR1:FREQ:CONC:STAT ON');
fwrite(g2,'SOUR1:PHAS: INIT');
fwrite(g2,'SOUR1:PHAS:ADJ 0 DEG' );
fwrite(g2,'SOUR2:PHAS:ADJ 180 DEG');
fwrite(g2,'OUTP1:STAT ON');
fwrite(g2,'OUTP2:STAT ON');


pause(nSeconds);
disp([num2str(freq(freqIDX)) 'Hz']);
fwrite(g1,'AUTOSet EXECute');
pause(nSeconds);
fwrite(g1,'REM “Set up the measurement parameters”');
fwrite(g1,'MEASUrement:IMMed:SOURCE1 CH1');
fwrite(g1,'MEASUrement:IMMed:TYPE FREQUENCY');
freqMeasCh1(1)=str2num(query(g1,'MEASUrement:IMMed:VALue?'))
fwrite(g1,'MEASUrement:IMMed:TYPE High');
highMeasCh1(1)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
fwrite(g1,'MEASUrement:IMMed:TYPE Low');
lowMeasCh1(1)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
fwrite(g1,'MEASUrement:IMMed:TYPE PK2pk');
vPkPkCh1(1)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
%pause(nSeconds);
fwrite(g1,'MEASUrement:IMMed:SOURCE1 CH2');
fwrite(g1,'MEASUrement:IMMed:TYPE FREQUENCY');
freqMeasCh2(1)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
fwrite(g1,'MEASUrement:IMMed:TYPE High');
highMeasCh2(1)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
fwrite(g1,'MEASUrement:IMMed:TYPE Low');
lowMeasCh2(1)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
fwrite(g1,'MEASUrement:IMMed:TYPE PK2pk');
vPkPkCh2(1)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
    fwrite(g1,'REM “Wait until the acquisition is complete before taking the measurement”');
    fwrite(g1,'While BUSY? keep looping');
    fwrite(g1,'REM “Take amplitude measurement on acquired data”');
% fwrite(g1,'MEASUrement:IMMed:SOURCE[1]');
% fwrite(g1,'MEASUrement:IMMed:TYPE FREQUENCY');
% freq=query(g1,'MEASUrement:IMMed:VALue?')
% fwrite(g1,'MEASUrement:IMMed:TYPE Amplitude');
% amp=query(g1,'MEASUrement:IMMed:VALue?')
%Iterate through frequencies
for freqIDX=2:nFreq
    fwrite(g2, ['SOUR1:FREQ:FIX ' num2str(freq(freqIDX)) 'Hz']);
    disp([num2str(freq(freqIDX)) 'Hz']);
    pause(nSeconds);
    fwrite(g1,'AUTOSet EXECute');
   % pause(nSeconds);
    fwrite(g1,'REM “Set up the measurement parameters”')
    fwrite(g1,'MEASUrement:IMMed:SOURCE1 CH1');
    fwrite(g1,'MEASUrement:IMMed:TYPE FREQUENCY');
    freqMeasCh1(freqIDX)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
    fwrite(g1,'MEASUrement:IMMed:TYPE High');
    highMeasCh1(freqIDX)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
    fwrite(g1,'MEASUrement:IMMed:TYPE Low');
    lowMeasCh1(freqIDX)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
    fwrite(g1,'MEASUrement:IMMed:TYPE PK2pk');
    vPkPkCh1(freqIDX)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
   % pause(nSeconds);
   fwrite(g1,'REM “Set up the measurement parameters”')
    fwrite(g1,'MEASUrement:IMMed:SOURCE1 CH2');
    fwrite(g1,'MEASUrement:IMMed:TYPE FREQUENCY');
    freqMeasCh2(freqIDX)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
    fwrite(g1,'MEASUrement:IMMed:TYPE High');
    highMeasCh2(freqIDX)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
    fwrite(g1,'MEASUrement:IMMed:TYPE Low');
    lowMeasCh2(freqIDX)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
    fwrite(g1,'MEASUrement:IMMed:TYPE PK2pk');
    vPkPkCh2(freqIDX)=str2num(query(g1,'MEASUrement:IMMed:VALue?'));
    fwrite(g1,'REM “Wait until the acquisition is complete before taking the measurement”');
    fwrite(g1,'While BUSY? keep looping');
    fwrite(g1,'REM “Take amplitude measurement on acquired data”');
    
    fwrite(g2,'SOUR1:PHAS: INIT');
    fwrite(g2,'SOUR1:PHAS:ADJ 0 DEG' );
    fwrite(g2,'SOUR2:PHAS:ADJ 180 DEG');
    %pause(nSeconds);
    
    
end
freqMeasCh1Cell{trial} = freqMeasCh1;
highMeasCh1Cell{trial} = highMeasCh1;
lowMeasCh1Cell{trial} = lowMeasCh1;
freqMeasCh2Cell{trial} = freqMeasCh2;
highMeasCh2Cell{trial} = highMeasCh2;
lowMeasCh2Cell{trial} = lowMeasCh2;
end