function measDisplacement(dirName,pxl2mic)
print('Loading python modules')
P = py.sys.path;
insert(P,int32(0),'C:\Users\miguel\Anaconda2\Lib\site-packages');
insert(P,int32(0),'C:\Users\miguel\Anaconda2\pkgs\opencv-3.2.0-np112py27_204\Lib\site-packages')
nFreqIDX = findstr(dirName,'nFreq');
nVoltIDX = findstr(dirName,'nVolt');
nTrialsIDX = findstr(dirName,'nTrials');
vMinIDX = findstr(dirName,'vMin');
vMaxIDX = findstr(dirName,'vMax');
freqMinIDX = findstr(dirName,'freqMin');
freqMaxIDX = findstr(dirName,'freqMax');

nTrials = str2num(dirName(nTrialsIDX+7:end));
nFreq = str2num(dirName(nFreqIDX+5:nTrialsIDX-2))
nVolt = str2num(dirName(nVoltIDX+5:nFreqIDX-2));
vMin = str2num(dirName(vMinIDX+4:vMaxIDX-2));
vMax = str2num(dirName(vMaxIDX+4:freqMinIDX-2));
freqMin = str2num(dirName(freqMinIDX+7:freqMaxIDX-2));
freqMax = str2num(dirName(freqMaxIDX+7:nVoltIDX-2));

freq = logspace(freqMin,freqMax,nFreq);
v = linspace(vMin,vMax,nVolt);
disp3DMatrix=zeros(nTrials,nFreq);
voltArr=zeros(nTrials,nFreq);

mod = py.importlib.import_module('measDisplacementAdaptiveThresh');
py.reload(mod);
print('Running Python Script')
outputData = struct(py.measDisplacementAdaptiveThresh.measDisplacementAdaptiveThresh(dirName,nTrials,nFreq,vMin,vMax,freqMin,freqMax,pxl2mic));
print('Processing Data')
data = double(py.array.array('d',py.numpy.nditer(outputData.data)));
data=reshape(data,([nFreq,nTrials+1]))';
frequencyDim = data(1,1:end);
displacement = data(2:end,1:end);
stdDisp = std(displacement,[],1);
figure; semilogx(frequencyDim,displacement,'-x')
figure; semilogx(frequencyDim,stdDisp,'-o');