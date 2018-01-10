function [Vpp] = obtainAvgVpp(dataFileName)
list=dir([dataFileName,'\Trial*']);
nTrials=length(list);
freqData = [];
highVoltData = [];
lowVoltData = [];
Vpp=[];
for j = 1:nTrials
    load([dataFileName,'\',list(j).name,'\signalMeasurements.mat']);
    szFreqCh1 = size(freqCh1)

    if (szFreqCh1(1)==1 || szFreqCh1(2)==1)
        if (j==1)
            Vpp  = zeros(nTrials,1);
        end
        Vpp(j) = 0.5*(mean(highCh1-lowCh1)+mean(highCh2-lowCh2));
    else
        disp('Here');
        if (j==1)
            Vpp = zeros(nTrials,szFreqCh1(1))
        end
        for l = 1:szFreqCh1(1)
            Vpp(j,l) = (0.5*(mean(highCh1(l,1:end)-lowCh1(l,1:end))+mean(highCh2(l,1:end)-lowCh2(l,1:end))));
        end
    end
    %figure, semilogx(freqCh1(freqCh1<freqCutOff),(highCh1(freqCh1<freqCutOff)-lowCh1(freqCh1<freqCutOff)),'*')
    %      if (j==1)
    %         semilogx(freqCh1(freqCh1<freqCutOff),(highCh1(freqCh1<freqCutOff)-lowCh1(freqCh1<freqCutOff)),'*')
    %      else
    %          hold on, semilogx(freqCh1(freqCh1<freqCutOff),(highCh1(freqCh1<freqCutOff)-lowCh1(freqCh1<freqCutOff)),'*')
    %      end
end
Vpp = mean(Vpp)/2;
end