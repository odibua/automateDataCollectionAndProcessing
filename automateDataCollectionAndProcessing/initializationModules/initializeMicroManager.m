%Code to initialize micromanager and microscope
%Ohi Dibua, February 7, 2017
function [mmc] =  initializeMicroManager(intervalMS)
import mmcorej.*; %Import java class that contains all microManager related classes
mmc = CMMCore; %Define variable as part of class CMMCore
%mmc.loadSystemConfiguration ('C:\Program Files\Micro-Manager-1.4\MMConfig_05172016aaa.cfg'); %Load configuration for scope 
mmc.loadSystemConfiguration ('C:\Program Files\Micro-Manager-1.4\MMConfig_05172016.cfg');
intervalMS=100; %interval for continous acquisition
%mmc.startContinuousSequenceAcquisition(intervalMS); %Start process of continous acquaisition at defined interval

end
