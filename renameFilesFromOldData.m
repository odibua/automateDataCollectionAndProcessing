clc; clear all; close all;

dataDirectoryName = 'C:\Users\miguel\Documents\MATLAB\device1\100uM_date_HH_mm_ss_14-Sep-2017_15_39_37\vMin5_vMax5_freqMin2_freqMax6_nVolt1_nFreq20_nTrials15';
list=dir([dataDirectoryName,'\Trial*']);
nTrials=length(list);
for j=1:nTrials
    directoryInUse=strcat(dataDirectoryName,'\',list(j).name);
    files=dir(directoryInUse);
    szFiles=size(files);
    for l=3:szFiles(1)
        destinationName=strcat(directoryInUse,'\',files(l).name);
        %destinationName=strcat(directoryName1,runName(j,:),'\',magnificationName(n,:),'\',directionName(k,:),'\',sprintf(strcat('img',num2str(l-1),'.tif')));
        
        directoryName=strcat(directoryInUse,'\','volt1_freq',num2str(l-3),'.tif');
        copyfile(destinationName,directoryName)
    end
    %end
end