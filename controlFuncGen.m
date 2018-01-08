clc; close all; clear all;

%Define frequency and voltage space of interest
nFreq=20;
freq = logspace(2,6,nFreq);
vPP= [5, 2.5, 1];


%Define time to wait between changing function generator output
nSeconds=1;
pAddress=5;

% Create a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', pAddress, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('ni', 0, pAddress);
else
    fclose(obj1);
    obj1 = obj1(1);
end
%Connect to hardware
fopen(obj1);

% Set both outputs to off
fwrite(obj1,'OUTP1:STAT OFF');
fwrite(obj1,'OUTP2:STAT OFF');

% Set output impedances of channel 1&2 to High Z
%fwrite (obj1, 'OUTP1:IMP: INF');
%fwrite (obj1, 'OUTP2:IMP: INF');

% Set source waveform
sineWaveForm='SOUR1:FUNC:SHAP SIN '; 
squareWaveForm='SOUR1:FUNC:SHAP SQUARE '; 
fwrite(obj1 , sineWaveForm) ;
%fwrite ( g , 'SOUR2:FUNC:SHAP SIN ' ) ;

freqIDX=1;
vPPIDX=1;
% Set frequency and voltage
fwrite (obj1 ,[ 'SOUR1:VOLT:AMPL ' num2str(vPP(vPPIDX)) 'VPP']);
fwrite(obj1, ['SOUR1:FREQ:FIX ' num2str(freq(freqIDX)) 'Hz']);

%Prompt user to make sure that the experiment is ready to go
% prompt = 'Have you focused the microscope and taken an inital picture of device Y/N [Y]: ';
% str = input(prompt,'s');

%Turn output on
fwrite(obj1,'OUTP1:STAT ON');
disp([num2str(freq(freqIDX)) 'Hz']);
%Wait to give time to take picture
pause(nSeconds);
%Iterate through frequencies
for freqIDX=2:nFreq
    fwrite(obj1, ['SOUR1:FREQ:FIX ' num2str(freq(freqIDX)) 'Hz']);
    disp([num2str(freq(freqIDX)) 'Hz']);
    pause(nSeconds);
end
%Turn output off
fwrite(obj1,'OUTP1:STAT OFF');

%Close objects
fclose(obj1);

%Delete objects
delete(obj1);