function    folderNameFreq=writeSweepFreqFolder(devLabel,freqMin,freqMax,vFixed,nFreq,nTrials)
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
    folderNameTm = [folderNameDev '\date_HH_mm_ss' aa];
    if (isdir(folderNameTm)==false)
        mkdir(folderNameTm);
    else
        disp('Folder already exists. Press any button to overwrite.');
        pause;
    end

    folderNameFreq = [folderNameTm, '\freqMin',num2str(freqMin),'_freqMax',num2str(freqMax),'_vFixed',num2str(vFixed),'_nFreq',num2str(nFreq),'_nTrials',num2str(nTrials)];
    if (isdir(folderNameFreq)==false)
        mkdir(folderNameFreq);
    else
        disp('Folder already exists. Press any button to overwrite.');
        pause;
    end
end