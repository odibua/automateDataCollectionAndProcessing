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

%a=input ('Movement in x(1) or y(2)');
% list=dir([dirName,'\Trial*']);
% 
% for voltIDX=1:nVolt
%     for j=1:nTrials
%     %for j=[1:3,5:7,9:10] %5mM
%         disp(['Trial ', num2str(j), ' Volt ' num2str(voltIDX)]);
%         Fpath = strcat(dirName,'\',list(j).name,'\')
%         a=load(strcat(dirName,'\',list(j).name,'\','signalMeasurements.mat'));
%         n=0;
%         freqIDX=0;
%         Disp=zeros(nFreq+1,1);
%         [Cent_ref]=FindCent(Fpath,freqIDX,voltIDX);
%         Cent_ref=Cent_ref(1:2,:);
%         %Cent_ref=Cent_ref(2:3,:);
%         for freqIDX=1:nFreq-n
%             [Cent_i]=FindCent(Fpath,n+freqIDX,voltIDX) ;
%             Cent_i=Cent_i(1:2,:);
%             %Cent_i=Cent_i(2:3,:);
% %             if (( Cent_i(1,a)-Cent_ref(1,a)) > 100)
% %                 Cent_i=[Cent_i(2,:); Cent_i(1,:)] ;
% %             end
% %             D=(Cent_i-Cent_ref);
% %             Disp(freqIDX+1)=(D(2,a)-D(1,a))*pxl2mic;
%             if (( Cent_i(1,1)-Cent_ref(1,1)) > 100)
%                 Cent_i=[Cent_i(2,:); Cent_i(1,:)] ;
%             end
%             if (( Cent_i(1,2)-Cent_ref(1,2)) > 100)
%                 Cent_i=[Cent_i(2,:); Cent_i(1,:)] ;
%             end
% %             Cent_i
% %             Cent_ref
%             D=(Cent_i-Cent_ref);
%             %D(2,2)-D(1,2)
%             %D(2,1)-D(1,1)
%             %(sqrt((D(2,1)-D(1,1))^2+(D(2,2)-D(1,2))^2))*pxl2mic
%             Disp(freqIDX+1)=(sqrt((D(2,1)-D(1,1))^2+(D(2,2)-D(1,2))^2))*pxl2mic;
%         end
%         disp3DMatrix(j,1:nFreq+1)=Disp;
%         volt = a.vPkPkCh1;
%         voltArr(j,1:end) = volt;
%         %disp3DMatrix(j,2:2:nFreq+1)=Disp(2:2:nFreq+1);
%        if (j==1)
%            size(Disp)
%            size(freq)
%            figure(1);
%           semilogx(freq(1:end),Disp(2:end),'-*'); 
%           hold on
%           figure(2)
%           semilogx(freq(1:end),volt,'-*'); 
%           hold on
%          % semilogx(freq(1:2:end-2),Disp(2:2:end-2),'*'); 
%          % hold on;
%        else
%           % semilogx(freq(1:2:end-2),Disp(2:2:end-2),'*'); 
%             figure(1);
%           semilogx(freq(1:end),Disp(2:end),'-*'); 
%           
%                     figure(2)
%           semilogx(freq(1:end),volt,'-*'); 
%        end
%        if (min(Disp)<-0.1)
%           disp(['Thresholding Issue, ' 'Trial ', num2str(j), ' Volt ' num2str(voltIDX), ' Ignoring this for online data processing']); 
%        else
%           %dispDat = [freq(1:end); disp3DMatrix(1:end,2:end)];
%            %dispDat = [freq(1:2:end-2); disp3DMatrix(1:end,2:2:end-2)];
%           %save([dirName, '\', num2str(v(voltIDX)),'Vpp_Device12.dat'],'dispDat','-ascii');
%        end
%        Disp
%     end
%     
%      mn=mean(disp3DMatrix);
%      stdDev=std(disp3DMatrix)
% %     save(strcat(dirName,'/','10000uMData'),'mn','stdDev');
%     mnVolt=mean(voltArr);
%     stdDevVolt=std(voltArr);
%     idxUse=[];
%     figure(3)
%     for j=1:nTrials
%         checkOutlier =sum(abs(disp3DMatrix(j,2:end)-mn(2:end))>2*stdDev(2:end));
%        %datPDF=normpdf(disp3DMatrix(j,2:end),mn(2:end),stdDev(2:end))
% %        disp3DMatrix(j,2:end)
% %        minPDF=min(datPDF) 
% %        maxPDF=max(datPDF)
%        if(checkOutlier==0)
%            idxUse=[idxUse j];
% 
%            semilogx(freq(1:end),disp3DMatrix(j,2:end),'-*'); 
%          % semilogx(freq(1:2:end-2),Disp(2:2:end-2),'*'); 
%           hold on;
%        end
%     end
%     idxUse
%     %dispDat = [freq(1:end); disp3DMatrix(idxUse,2:end)];
%     dispDat = [freq(1:end); disp3DMatrix(1:end,2:end)];
%     save([dirName, '\', num2str(v(voltIDX)),'Vpp_Device12.dat'],'dispDat','-ascii');
%     figure(4);
%     
% %     semilogx(freq(1:end),mn(2:end),'-o')
% %     hold on;
%     
%     hAx=axes;
%     hAx.XScale='log';
%     hold all;
%     xlim([1e2 1e7])
%     hold on
%     errorbar(freq(1:end),mn(2:end),2*stdDev(2:end),'-o','LineWidth',3,'MarkerSize',8)
%     hold on;
%     xlabel('Frequency (Hz)');
%     ylabel('Displacement (um)');
%     set(gca,'FontSize', 20)
%     hold on;
%      
%     figure(5);
% %     semilogx(freq(1:end),mn(2:end),'-o')
% %     hold on;
%     hold on
%     hAx=axes;
%     hAx.XScale='log';
%     hold all;
%     xlim([1e2 1e7])
%     errorbar(freq(1:end),mnVolt,2*stdDevVolt,'-o','LineWidth',3,'MarkerSize',8)
%     
%     xlabel('Frequency (Hz)');
%     ylabel('Volt (V)');
%     set(gca,'FontSize', 20)
% %     dispDat = [freq; disp3DMatrix(1:end,2:end)];
% %     save([dirName, '\', num2str(v(voltIDX)),'Vpp_Device12.dat'],'dispDat','-ascii')
% end


