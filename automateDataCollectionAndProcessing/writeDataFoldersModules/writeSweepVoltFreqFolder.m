function    folderNameVoltFreq=writeSweepVoltFreqFolder(devLabel,vMin,vMax,freqMin,freqMax,nVolt,nFreq,nTrials,concentrationName)
    folderNameDev = ['device',num2str(devLabel)];
    if (isdir(folderNameDev)==false)
        mkdir(folderNameDev);
    else
        disp('Folder already exists. Press any button to overwrite.');
        pause;
    end

    aa = num2str(datestr(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z')));
    aa(aa==':')='_';
    aa(aa==' ')='_';
    %folderNameTm = [folderNameDev '\dateTime' aa(1:11) '_' num2str(now)];
    folderNameTm = [folderNameDev, '\', concentrationName, '_', 'date_HH_mm_ss_' aa];
    %folderNameTm = [folderNameDev, '\', 'date_HH_mm_ss_' aa];
    if (isdir(folderNameTm)==false)
        mkdir(folderNameTm);
    else
        disp('Folder already exists. Press any button to overwrite.');
        pause;
    end

    folderNameVoltFreq = [folderNameTm, '\vMin',num2str(vMin),'_vMax',num2str(vMax),'_freqMin',num2str(freqMin),'_freqMax',num2str(freqMax),'_nVolt',num2str(nVolt),'_nFreq',num2str(nFreq),'_nTrials',num2str(nTrials),];
    if (isdir(folderNameVoltFreq)==false)
        mkdir(folderNameVoltFreq);
    else
        disp('Folder already exists. Press any button to overwrite.');
        pause;
    end
end