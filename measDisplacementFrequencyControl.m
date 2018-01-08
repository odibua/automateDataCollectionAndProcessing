function measDisplacementControl(dirName,pxl2mic,dataFileName)
targetDisplacement = chooseFromData(dataFileName)
% nFreqIDX = findstr(dirName,'nFreq');
% nVoltIDX = findstr(dirName,'nVolt');
% nTrialsIDX = findstr(dirName,'nTrials');
% vMinIDX = findstr(dirName,'vMin');
% vMaxIDX = findstr(dirName,'vMax');
% freqMinIDX = findstr(dirName,'freqMin');
% freqMaxIDX = findstr(dirName,'freqMax');
% 
% nTrials = str2num(dirName(nTrialsIDX+7:end));
% nFreq = str2num(dirName(nFreqIDX+5:nTrialsIDX-2));
% nVolt = str2num(dirName(nVoltIDX+5:nFreqIDX-2));
% vMin = str2num(dirName(vMinIDX+4:vMaxIDX-2));
% vMax = str2num(dirName(vMaxIDX+4:freqMinIDX-2));
% freqMin = str2num(dirName(freqMinIDX+7:freqMaxIDX-2));
% freqMax = str2num(dirName(freqMaxIDX+7:nVoltIDX-2));
% 
% freq = logspace(freqMin,freqMax,nFreq);
% v = linspace(vMin,vMax,nVolt);
% disp3DMatrix=zeros(nTrials,nFreq);
% 
% %a=input ('Movement in x(1) or y(2)');

 list=dir([dirName,'\Trial*']);
nVolt=1;
nTrials=3;
nFreq=15;
disp3DMatrix=zeros(nTrials,nFreq);
for voltIDX=1:nVolt
    for j=1:nTrials
        disp(['Trial ', num2str(j), ' Volt ' num2str(voltIDX)]);
        Fpath = strcat(dirName,'\',list(j).name,'\')
        n=0;
        freqIDX=0;
        Disp=zeros(nFreq+1,1);
        [Cent_ref]=FindCent(Fpath,freqIDX,voltIDX);
        Cent_ref=Cent_ref(1:2,:);
        %Cent_ref=Cent_ref(2:3,:);
        for freqIDX=1:nFreq-n
            [Cent_i]=FindCent(Fpath,n+freqIDX,voltIDX) ;
            Cent_i=Cent_i(1:2,:);
            %Cent_i=Cent_i(2:3,:);
%             if (( Cent_i(1,a)-Cent_ref(1,a)) > 100)
%                 Cent_i=[Cent_i(2,:); Cent_i(1,:)] ;
%             end
%             D=(Cent_i-Cent_ref);
%             Disp(freqIDX+1)=(D(2,a)-D(1,a))*pxl2mic;
            if (( Cent_i(1,1)-Cent_ref(1,1)) > 100)
                Cent_i=[Cent_i(2,:); Cent_i(1,:)] ;
            end
            if (( Cent_i(1,2)-Cent_ref(1,2)) > 100)
                Cent_i=[Cent_i(2,:); Cent_i(1,:)] ;
            end
%             Cent_i
%             Cent_ref
            D=(Cent_i-Cent_ref);
            %D(2,2)-D(1,2)
            %D(2,1)-D(1,1)
            %(sqrt((D(2,1)-D(1,1))^2+(D(2,2)-D(1,2))^2))*pxl2mic
            Disp(freqIDX+1)=(sqrt((D(2,1)-D(1,1))^2+(D(2,2)-D(1,2))^2))*pxl2mic;
        end
        disp3DMatrix(j,1:nFreq+1)=Disp;
        %disp3DMatrix(j,2:end)=abs(Disp(2:end)-targetDisplacement')./targetDisplacement';
        %disp3DMatrix(j,2:2:nFreq+1)=Disp(2:2:nFreq+1);
        j
       if (j==1)
           figure(1);
           hold on;
          size(Disp(2:end))
          plot(targetDisplacement,Disp(2:end),'-x'); 
          %plot(abs(Disp(2:end)-targetDisplacement')./targetDisplacement','-*'); 
          %semilogx(freq(1:2:end-2),Disp(2:2:end-2),'*'); 
          hold on;
       else
           figure(1)
           plot(targetDisplacement,Disp(2:end),'-x'); 
           
          % semilogx(freq(1:2:end-2),Disp(2:2:end-2),'*'); 
          %plot(abs(Disp(2:end)-targetDisplacement')./targetDisplacement','-*'); 
       end
       if (min(Disp)<-0.1)
          disp(['Thresholding Issue, ' 'Trial ', num2str(j), ' Volt ' num2str(voltIDX), ' Ignoring this for online data processing']); 
       %else
    %      dispDat = [freq(1:end); disp3DMatrix(1:end,2:end)];
           %dispDat = [freq(1:2:end-2); disp3DMatrix(1:end,2:2:end-2)];
       %   save([dirName, '\', num2str(v(voltIDX)),'Vpp_Device12.dat'],'dispDat','-ascii');
       end
       Disp
    end
    mn=mean(disp3DMatrix)
    figure(2)
    hold on;
    semilogx(targetDisplacement,mn(2:end),'-o')
    hold on;
%     dispDat = [freq; disp3DMatrix(1:end,2:end)];
%     save([dirName, '\', num2str(v(voltIDX)),'Vpp_Device12.dat'],'dispDat','-ascii')
end


