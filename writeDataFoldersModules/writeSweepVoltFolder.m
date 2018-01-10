function    folderNameVolt=writeSweepVoltFolder(devLabel,vMin,vMax,freqFixed,nVolt,nTrials)
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

    folderNameVolt = [folderNameTm, '\vMin',num2str(vMin),'_vMax',num2str(vMax),'_freqFixed',num2str(freqFixed),'_nVolt',num2str(nVolt),'_nTrials',num2str(nTrials)];
    if (isdir(folderNameVolt)==false)
        mkdir(folderNameVolt);
    else
        disp('Folder already exists. Press any button to overwrite.');
        pause;
    end
end