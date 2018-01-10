function varargout = microscopeGUI(varargin)
% MICROSCOPEGUI MATLAB code for microscopeGUI.fig Written by Ohi Dibua
%      MICROSCOPEGUI, by itself, creates a new MICROSCOPEGUI or raises the existing
%      singleton*.
%
%      H = MICROSCOPEGUI returns the handle to a new MICROSCOPEGUI or the handle to
%      the existing singleton*.
%
%      MICROSCOPEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MICROSCOPEGUI.M with the given input arguments.
%
%      MICROSCOPEGUI('Property','Value',...) creates a new MICROSCOPEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before microscopeGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to microscopeGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".

        %%%%%%%%%%%%%%%%%%%%%%%COMMENTS BY AUTHOR%%%%%%%%%%%%%%%%%%%%%
%       This GUI contains the code that allows the automated collection of
%       data from an electrostatic comb-drive actuator that is fabricated
%       in a similar way as in [1].

%       GUI is broken down into the following Blocks:

%           I. Initialization Module:
%                 a) Initialize Microscope:         Initializes the java class mmc that is used to control the microscope,
%                                                   the acquisition interval the maximum and minimum positions the stage,
%                                                   is allowed to be moved, and the parameters used in the auto-focus algorithm.
%
%                 b) Focus Microscope:              Begins a while loop that allows the user to manually focus the microscope
%                                                   so that the image we care about is clear.
%
%                 c) Complete Microscope Focusing:  Ends while loopBegins a while loop that allows the user to manually focus
%                                                   microscope.
%
%                 d) Initialize Function Generator: Initializes object that is used to control function generator and sets two
%                                                   channels 180 degrees out of phase.
%
%                 e) Initialize Dig. Oscilloscope:  Initializes object that is used to control the oscilloscope, and the channel
%                                                   channels strings.
%           II. Calibration Module:
%                 a) Set Frequency Sweep Parameters:         Sets the parameters that will be used define the amplitude of the signal applied to 
%                                                            the device, the interval of frequencies over which the signal will sweep, the number 
%                                                            of points in this interval, and whether the signal should be measured by an oscilloscope.
%                                                            There are limits prescribed to these values to protect the device.
%
%                 b) Frequency Sweep, Capture Images:        Apply the voltage signal across prescribed frequencies for prescribed number of trials, 
%                                                            capture images as a result of the applied signal, and save both the images and the
%                                                            measured signals. 
%
%                 c) Set Voltage Sweep Parameters:           Sets the parameters that will be used to define the frequency of the signal applied to
%                                                            the device, the interval of voltages over which the signal will sweep, and the number of points
%                                                            in the interval. There are limits prescribed to these values to protect the device. 
% 
%                 d) Voltage Sweep, Capture Images:          Apply the voltage signal across prescribed voltages for prescribed number of trials, 
%                                                            capture images as a result of the applied signal, and save both the images and the
%                                                            measured signals. 
%
%                 e) Set Voltage and Frequency Parameters:   COMMENTED OUT OF CODE. WILL BE WRITTEN LATER
%                 
% 
%                 f) Voltage and Frequency Sweep, Capture Images:   COMMENTED OUT OF CODE. WILL BE WRITTEN LATER

%           III. Post-processing Module:
%                 a) Measure Displacement, Binary Processing: Allows users to select folder obtained from the calibration module (which have
%                                                             a specific structire), and process the contained files using a local adaptive gaussian 
%                                                             threshold method in opencv-python. This returns the displacement of the actuator in each
%                                                             trial, displays the displacements on a plot, and saves the data to a text file.
% 
%                 b) Fit Model Parameters:                   Allows user to select data and to fit the parameters of different models to 
%                                                              it. It saves the fit parameters, and displays the error between the model prediction
%                                                              based on these parameters and the data. 




        
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help microscopeGUI

% Last Modified by GUIDE v2.5 18-Sep-2017 15:59:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @microscopeGUI_OpeningFcn, ...
    'gui_OutputFcn',  @microscopeGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before microscopeGUI is made visible.
function microscopeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to microscopeGUI (see VARARGIN)

% Choose default command line output for microscopeGUI
handles.output = hObject;

%Add paths
addpath('initializationModules','autoFocusModules','functionGeneratorModules','digitalOScopeModules','microscopeModules','postProcessingModules','parameterFittingAndControlModules','writeDataFoldersModules')
    
% Update handles structure
prompt = {'Enter salt concentration to be used in the experiment(uM):'};
dlg_title = 'concentration=?';
num_lines = 1;
def = {'1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
handles.concentrationName = strcat((answer{1}),'uM');
handles.concentrationBool = true;
handles.GainProp = 0.1;
guidata(hObject, handles);



% UIWAIT makes microscopeGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = microscopeGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Initialization Modules%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Button that initialized micromanager --- %
function initializeMicroscope_Callback(hObject, eventdata, handles)
% hObject    handle to initializeMicroscope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('Initializing micromanager java code');
import mmcorej.*; %Import java class that contains all microManager related classes
mmc = CMMCore; %Define variable as part of class CMMCore
mmc.loadSystemConfiguration ('C:\Program Files\Micro-Manager-1.4\MMConfig_05172016aaa.cfg');
intervalMS=100; %interval for continous acquisition
handles.mmc =  mmc; %Creates handle that stores mmc object
handles.intervalMS=intervalMS; %Creates handle that stores interval time of acquisition

display('Initialization Complete');

display('Setting bounds for motion of scope');
handles.zstage = mmc.getFocusDevice(); %Define zstage to be controlled
%Set the upper and lower bounds that autofocus is allowed to move to
string='Move microscope stage to maximum allowable z';
mydialog(string);
handles.zuBound=mmc.getPosition(handles.zstage);
string='Move microscope stage to minimum allowable z';
mydialog(string)
handles.zlBound=mmc.getPosition(handles.zstage);
disp(['Upper Bound ',num2str(handles.zuBound),' Lower Bound ',num2str(handles.zlBound)]); 

%Define default parameters for autofocus
handles.mmtoZ=5000/5e-3;
handles.intervalMicronsL = 20;%35;
handles.intervalMicronsU = 20;%35;
handles.intervalMicronsU = handles.intervalMicronsU*1e-6;
handles.intervalMicronsL = handles.intervalMicronsL*1e-6;
handles.maxIter=20; 
handles.tol=2;

guidata(hObject,handles); %Update handles

% --- Capture images on microscope and allows user to focus it --- %
function focusMicroscope_Callback(hObject, eventdata, handles)
% hObject    handle to focusMicroscope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mmc = handles.mmc; %mmc handle
intervalMS=handles.intervalMS;
handles.stop_now = 0; %Create stop_now in handles structure
guidata(hObject,handles); %Update the GUI data
mmc.stopSequenceAcquisition; %Stop sequence acquisition
mmc.startContinuousSequenceAcquisition(intervalMS); %Start's process of continous acquisition
figure(2);
display('Focusing Microscope');

while ~(handles.stop_now)
    handles = guidata(hObject);  %Get the newest GUI
    mmc.waitForSystem();
    img=captureImage(mmc); %Stores image acquired
    %set(gca,'visible','off')
    imagesc(img), colormap('gray'), axis off %% Image data
   
   % set(gca,'visible','off')
    pause(0.01) %Pause to give time for image to change
end
mmc.stopSequenceAcquisition; %Stop sequence acquisition
display('Microscope Focusing Completed');

% --- Stop sequence acquisition during focusing --- %
function completeMicroscopeFocusing_Callback(hObject, eventdata, handles)
% hObject    handle to completeMicroscopeFocusing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stop_now = 1; %Change handle to 1 so that focusing stops
guidata(hObject,handles); %Update handles
%mmc = handles.mmc;
%mmc.stopSequenceAcquisition

% --- Executes on button press in initFuncGen.
function initFuncGen_Callback(hObject, eventdata, handles)
% hObject    handle to initFuncGen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Initialize Function Generator');
handles.pAddressFunGen=1;
handles.funGenObj = initializeFuncGen(handles.pAddressFunGen);
initializePhase(handles.funGenObj);
mmc=handles.mmc;
mmc.stopSequenceAcquisition; %Stop sequence acquisition
handles.controlVoltageBool=0;
%handles.controlVoltageBool=1;
handles.vMax=8;
guidata(hObject,handles); %Update handles
disp('Initialization Complete');

% --- Executes on button press in initOScope.
function initOScope_Callback(hObject, eventdata, handles)
% hObject    handle to initOScope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Initialize Digital Oscilloscope');
handles.pAddressScope=5;
handles.scopeObj = initializeDigOsc(handles.pAddressScope);
handles.ch1String = '1';
handles.ch2String = '2';
guidata(hObject,handles); %Update handles
disp('Initialization Complete');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calibration Modules%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%Frequency Sweep Submodules%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in setFreqSweepParams.
function setFreqSweepParams_Callback(hObject, eventdata, handles)
% hObject    handle to setFreqSweepParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Initialize frequency bounds and thresholds
freqMin=0;
freqMax=0;
vFixed =0;
freqLThresh=2;
freqUThresh=8;
vThresh = 8;
while (freqMax > freqUThresh || freqMin<freqLThresh || freqMax < freqMin || vFixed > vThresh) %Allow users to set relevant parameters for frequency sweep
    prompt = {'Enter minimum frequency power:','Enter maximum frequency power:','Enter number of frequencies in interval:','Enter fixed voltage:','Enter device label:','Number of trials:','Scope Measurement?'};
    dlg_title = 'min=?,max=?,nFreq=?,vFixed=?,devLab=?,nTrials=?,scopeMeas=?';
    num_lines = 1;
    def = {'2','6','3','5','1','1','true'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    freqMin=str2num(answer{1});
    freqMax=str2num(answer{2});
    nFreq=str2num(answer{3});
    vFixed=str2num(answer{4});
    devLabel = answer{5};
    nTrials = str2num(answer{6});
    scopeMeas = str2num(answer{7});
    guidata(hObject,handles);
end
%Store parameters in handles
handles.freqMin=freqMin;
handles.freqMax=freqMax;
freqMax=handles.freqMax;
handles.nFreq=nFreq;
handles.vFixed = vFixed;
handles.devLabel = devLabel;
handles.nTrials = nTrials;
handles.scopeMeas = scopeMeas;

handles.freqArr = logspace(freqMin,freqMax,nFreq);% handles.freqArr = handles.freqArr(handles.freqArr<handles.freqCutOff);
handles.nFreq = length(handles.freqArr);
guidata(hObject,handles); %Update handles

% --- Executes on button press in freqSweepCaptImgs.
function freqSweepCaptImgs_Callback(hObject, eventdata, handles)
% hObject    handle to freqSweepCaptImgs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Define relevant parameters for frequency sweep
controlVoltageBool=handles.controlVoltageBool;

mmc = handles.mmc; %mmc handle
intervalMS=handles.intervalMS;
handles.stop_now = 0; %Create stop_now in handles structure
guidata(hObject,handles); %Update the GUI data
if mmc.isSequenceRunning()
mmc.stopSequenceAcquisition; %Stop sequence acquisition
end
mmc.startContinuousSequenceAcquisition(intervalMS); %Start's process of continous acquisition
figure(2);
%Allows user to focus microscope at beginning of experiment
display('Focusing Microscope');
while ~(handles.stop_now)
    handles = guidata(hObject);  %Get the newest GUI
    img=captureImage(mmc); %Stores image acquired
    %set(gca,'visible','off')
    imagesc(img), colormap('gray'), axis off %% Image data
    
    % set(gca,'visible','off')
    pause(0.01) %Pause to give time for image to change
end
mmc.stopSequenceAcquisition; %Stop sequence acquisition
display('Microscope Focusing Completed');

%Stores values needed to conduct frequency sweep
funGenObj = handles.funGenObj;  scopeObj = handles.scopeObj; 
freqMin = handles.freqMin;      freqMax = handles.freqMax;
freqArr = handles.freqArr;      devLabel = handles.devLabel;
vFixed = handles.vFixed;        vFixedCh1=vFixed;
vFixedCh2=vFixed;               vTarget=vFixed;
nFreq = handles.nFreq;          nTrials = handles.nTrials;
scopeMeas = handles.scopeMeas;

%Creates folder that will store data
folderNameFreq=writeSweepVoltFreqFolder(devLabel,vFixed,vFixed,freqMin,freqMax,1,nFreq,nTrials,handles.concentrationName);

tic
%Creates matrix that will store images
imageMatrix = uint16(zeros(1024,1344,nTrials,nFreq+1));
vFixedCh1Store=zeros(nFreq,1);  vFixedCh2Store=zeros(nFreq,1);
%Runs nTrials of voltage sweeps on actuator and saves the resulting images
for k=1:nTrials
    imageMatrix = uint16(zeros(1024,1344,nFreq+1));
    vFixed=vTarget;
    %Initializes structures that will store signals measured by oscilloscope
    [handles.freqCh1,handles.vPkPkCh1,handles.highCh1,handles.lowCh1,handles.freqCh2,handles.vPkPkCh2,handles.highCh2,handles.lowCh2,handles.waveFormCh1,handles.waveFormCh2] = initOscopeDatStorStruct(nFreq);    
    
    %Completes creation of folder that stores data. Asks user if they want
    %to overwrite if folder already exists.
    folderNameTrial = [folderNameFreq, '\', 'Trial', num2str(k)];
    if (isdir(folderNameTrial)==false)
        mkdir(folderNameTrial);
    else
        disp('Folder already exists. Are you sure you want to overwrite it?');
        pause;
    end
    figure(2);
    
    F(nFreq+1) = struct('cdata',[],'colormap',[]); %Define frame structure that will store images in sweep
    %Auto-focuses microscope
    performAutoFocus(handles.mmtoZ,handles.intervalMicronsU,handles.intervalMicronsL,handles.zlBound,handles.zuBound,handles.tol,handles.maxIter,@fmeasure,handles.zstage,mmc,handles.intervalMS);
    
    %Obtains image of device before actuation and stores it in image matrix
    mmc.setExposure(100);
    mmc.snapImage();
    img = mmc.getImage();
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    byteDepth = mmc.getBytesPerPixel();
    imageTemp=uint16(reshape(img,width,height)');
    imageMatrix(:,:,1)=imageTemp;
    imwrite(imageTemp,[folderNameTrial, '\volt1_freq0.tif']);
    figure(3);
    imshow(imadjust(imageTemp));
    
    %Performs frequency sweep on device
    pause(0.5);
    copyChan1ToChan2(funGenObj);
    setVoltageCh1(funGenObj,vFixedCh1);
    setVoltageCh2(funGenObj,vFixedCh1);
    [freqArr,funGenObj,scopeObj,scopeMeas,handles,imageMatrix] = sweepFreq(nFreq,freqArr,funGenObj,scopeObj,scopeMeas,handles,mmc,imageMatrix);
    
    %Manual focusing block that gives user time to rewet device if it is getting dry
    if (rem(k,3)==0)
        if mmc.isSequenceRunning()
        mmc.stopSequenceAcquisition; %Stop sequence acquisition
        end
        mmc.startContinuousSequenceAcquisition(intervalMS); %Start's process of continous acquisition
        figure(2);
        display('Focusing Microscope');
        %mmc.stopSequenceAcquisition; %Stop sequence acquisition
        handles.stop_now=0;
        guidata(hObject,handles); %Update the GUI data
        while ~(handles.stop_now)
            handles = guidata(hObject);  %Get the newest GUI
            img=captureImage(mmc); %Stores image acquired
            %set(gca,'visible','off')
            imagesc(img), colormap('gray'), axis off %% Image data

            % set(gca,'visible','off')
            pause(0.1) %Pause to give time for image to change
        end
        if mmc.isSequenceRunning()
        mmc.stopSequenceAcquisition; %Stop sequence acquisition
        end
        display('Microscope Focusing Completed');
    end

    %Turn off function generator and save data from trial
    turnOffChannels(funGenObj);
    for j=1:nFreq
        imwrite(imageMatrix(:,:,j+1),[folderNameTrial, '\volt1_freq', num2str(j), '.tif']);
        disp([folderNameTrial, '\volt1_freq', num2str(j), '.tif']);
    end
    freqCh1 = handles.freqCh1; lowCh1 = handles.lowCh1; highCh1 = handles.highCh1; vPkPkCh1=handles.vPkPkCh1;
    freqCh2 = handles.freqCh2; lowCh2 = handles.lowCh2; highCh2 = handles.highCh2; vPkPkCh2=handles.vPkPkCh2;
    waveFormCh1 = handles.waveFormCh1; waveFormCh2 = handles.waveFormCh2;
    save([folderNameTrial, '\signalMeasurements', '.mat'],'freqCh1','lowCh1','highCh1','freqCh2','lowCh2','highCh2','waveFormCh1','waveFormCh2','vPkPkCh1','vPkPkCh2');    
end
mmc.stopSequenceAcquisition;

toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Voltage Sweep Submodules%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in setVoltSweepParams.
function setVoltSweepParams_Callback(hObject, eventdata, handles)
% hObject    handle to setVoltSweepParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%NOTE: Voltage parameters are in terms of Peak-Peak Voltage
vMin=1;
vMax=8;
freqFixed =0;
vLThresh=1;
vUThresh=8;
freqThresh = 100;
while (vMax > vUThresh || vMin<vLThresh || vMax < vMin || freqFixed < freqThresh) %Allow users to set relevant parameters for frequency sweep
    prompt = {'Enter minimum peak-peak voltage:','Enter maximum peak-peak voltage:','Enter number of voltages in interval:','Enter fixed frequency:','Enter device label:','Number of trials:','Scope Measurement?'};
    dlg_title = 'min=?,max=?,nVolt=?,freqFixed=?,devLab=?,nTrials=?,scopeMeas=?';
    num_lines = 1;
    def = {'1','4','10','1e6','1','1','true'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    vMin=str2num(answer{1});
    vMax=str2num(answer{2});
    nVolt=str2num(answer{3});
    freqFixed=str2num(answer{4});
    devLabel = answer{5};
    nTrials = str2num(answer{6});
    scopeMeas = str2num(answer{7});
    guidata(hObject,handles);
end
%Store parameters in handles
handles.vMin=vMin;
handles.vMax=vMax;
handles.nVolt=nVolt;
linspace(vMin,vMax,nVolt)
handles.freqFixed = freqFixed;
handles.devLabel = devLabel;
handles.nTrials = nTrials;
handles.scopeMeas = scopeMeas;

handles.vArr = linspace(vMin,vMax,nVolt);
disp('Volt Params Set');
guidata(hObject,handles); %Update handles

% --- Executes on button press in voltSweepCapImgs ---%
function voltSweepCapImgs_Callback(hObject, eventdata, handles)
% hObject    handle to voltSweepCapImgs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
funGenObj = handles.funGenObj;
scopeObj = handles.scopeObj;
vArr = handles.vArr;
vMin = handles.vMin;
vMax = handles.vMax;
devLabel = handles.devLabel;
freqFixed = handles.freqFixed;
nVolt = handles.nVolt;
nTrials = handles.nTrials;
scopeMeas = handles.scopeMeas;
folderNameVoltFreq=writeSweepVoltFolder(devLabel,vMin,vMax,freqFixed,nVolt,nTrials);
mmc=handles.mmc;
intervalMS = handles.intervalMS;
mmc.stopSequenceAcquisition;
mmc.startContinuousSequenceAcquisition(intervalMS);
pause(0.5);
for k=1:nTrials
    [handles.freqCh1,handles.highCh1,handles.lowCh1,handles.freqCh2,handles.highCh2,handles.lowCh2,handles.waveFormCh1,handles.waveFormCh2] = initOscopeDatStorStruct(nVolt);
    F(nVolt+1) = struct('cdata',[],'colormap',[]); %Define frame structure that will store images in sweep
    %Create directory for trial number if it does not already exist
    if (handles.concentrationBool==true)
       folderNameTrial = [folderNameVoltFreq, '\', num2str(handles.concentrationBool), 'mM\' 'Trial', num2str(k)]; 
    else
       folderNameTrial = [folderNameVoltFreq, '\', 'Trial', num2str(k)]; 
    end
    if (isdir(folderNameTrial)==false)
        mkdir(folderNameTrial);
    else
        disp('Folder already exists. Are you sure you want to overwrite it?');
        pause;
    end
    delete([folderNameTrial, '\volt*']);
    
    %pause(0.5);
    figure(1);
    img=captureImage(mmc);
    imagesc(img), colormap('gray'), axis off %% Image data
    F(1) = getframe(gcf);
    [IM,~] = frame2im(F(1));
    imwrite(IM,[folderNameTrial, '\volt0.tif']);
    copyChan1ToChan2(funGenObj);
    setFreq(funGenObj,freqFixed);
    for j=1:nVolt
        setVoltage(funGenObj,vArr(j));
        if (j==1)
            turnOnChannels(funGenObj);
        end
        initializePhase(funGenObj);
        setChannels180OutofPhase(funGenObj);
        
        if (scopeMeas==true)
            autoSet(scopeObj);
            [handles.freqCh1(j),handles.highCh1(j),handles.lowCh1(j),handles.freqCh2(j),handles.highCh2(j),handles.lowCh2(j)] = measAmpFreq(scopeObj);
        end
        
        disp([num2str(vArr(j)) 'V']);
        img=captureImage(mmc);
        imagesc(img), colormap('gray'), axis off %% Image data
        pause(0.01)
        F(j+1) = getframe(gcf);
    end
    
    turnOffChannels(funGenObj);
    for j=1:nVolt
        [IM,~] = frame2im(F(j+1));
        imwrite(IM,[folderNameTrial, '\volt', num2str(j), '.tif']);
    end
    freqCh1 = handles.freqCh1; lowCh1 = handles.lowCh1; highCh1 = handles.highCh1;
    freqCh2 = handles.freqCh2; lowCh2 = handles.lowCh2; highCh2 = handles.highCh2;
    save([folderNameTrial, '\signalMeasurements', '.mat'],'freqCh1','lowCh1','highCh1','freqCh2','lowCh2','highCh2');
end
mmc.stopSequenceAcquisition();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Load External Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in loadFuncGenParams.
function loadFuncGenParams_Callback(hObject, eventdata, handles)
% hObject    handle to loadFuncGenParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileName = uigetfile('*.mat','Select the file that contains function generator parameters');
funcGenVars = load(fileName);
handles.REffFuncGen = funcGenVars.REff;
handles.CEffFuncGen = funcGenVars.CEff;
handles.freqCutOff = funcGenVars.freqCutOff;
handles
disp('Parameters Loaded');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in defConcentration.
function defConcentration_Callback(hObject, eventdata, handles)
% hObject    handle to defConcentration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Post Processing Module%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in postProcessDisplBWMeth.
function postProcessDisplBWMeth_Callback(hObject, eventdata, handles)
% hObject    handle to postProcessDisplBWMeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dirName = uigetdir(matlabroot,'Select directory that contains data to be processed');
pxl2mic=50/388; %Air 50x Scope
%pxl2mic=100/625.33; %Water 40x Scope
%Process data and display calculated displacement
measDisplacement(dirName,pxl2mic);

% --- Executes on button press in fitModelParameters.
function fitModelParameters_Callback(hObject, eventdata, handles)
% hObject    handle to fitModelParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[dataFileName, pathName] = uigetfile('*.dat','Select the file that contains experimental data you want to fit');
dataFileName = strcat(pathName,dataFileName);
saveDirName = uigetdir('C:\Users\miguel\Documents\MATLAB','Select directory that you want to save model parameters to');
saveDirName =strcat(saveDirName,'\');
prompt = {'Enter salt concentration of experimental data(uM):','Enter threshold of fit:','Manually input Vpp?:'};
dlg_title = 'concentration=?,threshholdFit=?,Manually Input Vpp (V)=?';
num_lines = 1;
def = {'100','0.1','true'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
c0NomIn = str2num(answer{1})*1e-6;
threshFit = str2num(answer{2});
manInputBool = str2num(answer{3});

if (manInputBool==true)
  prompt = {'Input Vpp (V):'};
  dlg_title = 'Vpp=?';
  num_lines = 1;
  def = {'2.5'};
  answer = inputdlg(prompt,dlg_title,num_lines,def);
  Vpp = str2num(answer{1});
else
    Vpp = obtainAvgVpp(pathName);
    disp(['Measured Vpp is ', num2str(Vpp) , ' V']);
end
disp('Fitting Models and Parameters');
fitClassic_LeakyModels(saveDirName,dataFileName,threshFit,c0NomIn,Vpp);
disp('Fitting Complete');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Control Module%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in openLoopControlFrequency.
function openLoopControlFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to openLoopControlFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%devLabel = handles.devLabel;
mmc=handles.mmc;
intervalMS=handles.intervalMS;
handles.stop_now = 0; %Create stop_now in handles structure
guidata(hObject,handles); %Update the GUI data
mmc.stopSequenceAcquisition; %Stop sequence acquisition
mmc.startContinuousSequenceAcquisition(intervalMS); %Start's process of continous acquisition
figure(2);
display('Focusing Microscope');
        %mmc.stopSequenceAcquisition; %Stop sequence acquisition
        while ~(handles.stop_now)
            handles = guidata(hObject);  %Get the newest GUI
            img=captureImage(mmc); %Stores image acquired
            %set(gca,'visible','off')
            imagesc(img), colormap('gray'), axis off %% Image data
            
            % set(gca,'visible','off')
            pause(0.01) %Pause to give time for image to change
        end
        mmc.stopSequenceAcquisition; %Stop sequence acquisition
display('Microscope Focusing Completed');


[dataFileName, pathName] = uigetfile('*.dat','Select the file that contains experimental data you want to use for open-loop control');
dataFileName = strcat(pathName,dataFileName);
[paramsFileName, pathName] = uigetfile('*.npz','Select the file that contains model parameters you want to use for open-loop control');
paramsFileName = strcat(pathName,paramsFileName);
saveDirName = uigetdir('C:\Users\miguel\Documents\MATLAB','Select directory that you want to save open-loop results to');
saveDirName =strcat(saveDirName,'\');

prompt = {'Choose model to be use for open-loop control (0 for Classic, 1 for Leaky, 2 for LeakyStern):','Choose number of trials for open-loop experiment:','Scope Meas:'};
dlg_title = 'model=?,trials=?,scopeMeas';
num_lines = 1;
def = {'0','10','false'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
chooseModel = str2num(answer{1});
nTrials = str2num(answer{2});
scopeMeas = str2num(answer{3});
funGenObj = handles.funGenObj;
scopeObj = handles.scopeObj;
targetDisplacement = chooseFromData(dataFileName);
[commandedFrequencies,commandedVoltage] = commandFrequency(paramsFileName,targetDisplacement,chooseModel);
nFreq = length(commandedFrequencies);
freqArr=commandedFrequencies
vFixed = commandedVoltage;
vTarget=vFixed;
folderName = [saveDirName,'openLoopModel',num2str(chooseModel)];

if(min(freqArr)<1e2 || max(freqArr>1e8) || vFixed>handles.vMax )
   disp('No Trials run because of invalide frequency or voltage command');
   disp(['Max Frequency ', num2str(max(freqArr)), ' minimum frequency ', num2str(min(freqArr)), ' fixed voltage ', vFixed]);
   nTrials=0; 
end
freqMin=min(freqArr);
freqMax=max(freqArr);
vFixedCh1=vFixed;
vFixedCh2=vFixed;
%folderNameFreq=writeSweepVoltFreqFolder(devLabel,vFixed,vFixed,freqMin,freqMax,1,nFreq,nTrials,handles.concentrationName);
mmc=handles.mmc;
intervalMS = handles.intervalMS;
% mmc.stopSequenceAcquisition;
% mmc.startContinuousSequenceAcquisition(intervalMS);
pause(0.5);
imageMatrix = uint16(zeros(1024,1344,nTrials,nFreq+1));

vFixedCh1Store=zeros(nFreq,1);
vFixedCh2Store=zeros(nFreq,1);
for k=1:nTrials
    imageMatrix = uint16(zeros(1024,1344,nFreq+1));
    vFixed=vTarget;
    [handles.freqCh1,handles.vPkPkCh1,handles.highCh1,handles.lowCh1,handles.freqCh2,handles.vPkPkCh2,handles.highCh2,handles.lowCh2,handles.waveFormCh1,handles.waveFormCh2] = initOscopeDatStorStruct(nFreq);
    F(nFreq+1) = struct('cdata',[],'colormap',[]); %Define frame structure that will store images in sweep
    %Create directory for trial number if it does not already exist
    folderNameTrial = [folderName, '\', 'Trial', num2str(k)];
    if (isdir(folderNameTrial)==false)
        mkdir(folderNameTrial);
    else
        disp('Folder already exists. Are you sure you want to overwrite it?');
        pause;
    end
    figure(2);
    performAutoFocus(handles.mmtoZ,handles.intervalMicronsU,handles.intervalMicronsL,handles.zlBound,handles.zuBound,handles.tol,handles.maxIter,@fmeasure,handles.zstage,mmc,handles.intervalMS);
    mmc.setExposure(100);
    mmc.snapImage();
    img = mmc.getImage();
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    byteDepth = mmc.getBytesPerPixel();
    imageTemp=uint16(reshape(img,width,height)');
    imageMatrix(:,:,1)=imageTemp;
    imwrite(imageTemp,[folderNameTrial, '\volt1_freq0.tif']);
    figure(3); 
    imshow(imadjust(imageTemp));
    
    pause(0.5);
    copyChan1ToChan2(funGenObj);
    setVoltageCh1(funGenObj,vFixedCh1);
    setVoltageCh2(funGenObj,vFixedCh1);
    
    [freqArr,funGenObj,scopeObj,scopeMeas,handles,imageMatrix] = sweepFreq(nFreq,freqArr,funGenObj,scopeObj,scopeMeas,handles,mmc,imageMatrix);

    %Manual focusing block
    %     if (rem(k,2)==0)
    % handles.stop_now = 0; %Create stop_now in handles structure
    % guidata(hObject,handles); %Update the GUI data
    % mmc.stopSequenceAcquisition; %Stop sequence acquisition
    % mmc.startContinuousSequenceAcquisition(intervalMS); %Start's process of continous acquisition
    % figure(2);
    % display('Focusing Microscope');
    %         %mmc.stopSequenceAcquisition; %Stop sequence acquisition
    %         while ~(handles.stop_now)
    %             handles = guidata(hObject);  %Get the newest GUI
    %             img=captureImage(mmc); %Stores image acquired
    %             %set(gca,'visible','off')
    %             imagesc(img), colormap('gray'), axis off %% Image data
    %
    %             % set(gca,'visible','off')
    %             pause(0.01) %Pause to give time for image to change
    %         end
    %         mmc.stopSequenceAcquisition; %Stop sequence acquisition
    % display('Microscope Focusing Completed');
    %     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    turnOffChannels(funGenObj);
    for j=1:nFreq
        imwrite(imageMatrix(:,:,j+1),[folderNameTrial, '\volt1_freq', num2str(j), '.tif']);
        disp([folderNameTrial, '\volt1_freq', num2str(j), '.tif']);
    end
    freqCh1 = handles.freqCh1; lowCh1 = handles.lowCh1; highCh1 = handles.highCh1; vPkPkCh1=handles.vPkPkCh1;
    freqCh2 = handles.freqCh2; lowCh2 = handles.lowCh2; highCh2 = handles.highCh2; vPkPkCh2=handles.vPkPkCh2;
    waveFormCh1 = handles.waveFormCh1; waveFormCh2 = handles.waveFormCh2;
    save([folderNameTrial, '\signalMeasurements', '.mat'],'freqCh1','lowCh1','highCh1','freqCh2','lowCh2','highCh2','waveFormCh1','waveFormCh2','vPkPkCh1','vPkPkCh2');
    
    
end
mmc.stopSequenceAcquisition();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%Voltage and Frequency Sweep Submodules%%%%%%%%%%%
% --- Executes on button press in setVoltFreqSweepParams.
% function setVoltFreqSweepParams_Callback(hObject, eventdata, handles)
% % hObject    handle to setVoltFreqSweepParams (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% vMin=1;
% vMax=8;
% freqMin=2;
% freqMax=6;
% freqLThresh=2;
% freqUThresh=8;
% vLThresh=1;
% vUThresh=8;
% startIndc=0;
% fileName = uigetfile('*.mat','Select the file that contains function generator parameters');
% funcGenVars = load(fileName);
% handles.REff = funcGenVars.REff;
% handles.CEff = funcGenVars.CEff;
% handles.freqCutOff = funcGenVars.freqCutOff;
% 
% while (vMax > vUThresh || vMin<vLThresh || vMax < vMin || freqMin < freqLThresh || freqMax > freqUThresh || freqMax < freqMin || startIndc==0) %Allow users to set relevant parameters for frequency sweep
%     prompt = {'Enter minimum peak-peak voltage:','Enter maximum peak-peak voltage:','Enter minimum frequency:','Enter maximum frequency:','Enter number of voltages in interval:','Enter number of frequencies in interval:','Enter device label:','Number of trials:','Scope Measurement?'};
%     dlg_title = 'vMin=?,vMax=?,freqMin=?,freqMax=?,nVolt=?,nFreq=?,devLab=?,nTrials=?,scopeMeas=?';
%     num_lines = 1;
%     def = {'1','4','2','6','3','3','1','1','true'};
%     answer = inputdlg(prompt,dlg_title,num_lines,def);
%     vMin=str2num(answer{1});
%     vMax=str2num(answer{2});
%     freqMin=str2num(answer{3});
%     freqMax=str2num(answer{4});
%     nVolt=str2num(answer{5});
%     nFreq=str2num(answer{6});
%     devLabel = answer{7};
%     nTrials = str2num(answer{8});
%     scopeMeas = str2num(answer{9});
%     guidata(hObject,handles);
%     startIndc=1;
% end
% %Store parameters in handles
% handles.vMin=vMin;
% handles.vMax=vMax;
% handles.freqMin=freqMin;
% handles.freqMax=log10(handles.freqCutOff);%freqMax;
% handles.nVolt=nVolt;
% handles.nFreq=nFreq;
% handles.devLabel = devLabel;
% handles.nTrials = nTrials;
% handles.scopeMeas = scopeMeas;
% 
% handles.vArr = linspace(vMin,vMax,nVolt);
% handles.freqArr = logspace(freqMin,freqMax,nFreq);
% %handles.freqArr=handles.freqArr(handles.freqArr<handles.freqCutOff);
% %handles.nFreq = length(handles.freqArr);
% linspace(vMin,vMax,nVolt);
% logspace(freqMin,freqMax,nFreq);
% % handles.freqCh1 = zeros(nFreq,1);
% % handles.highCh1 = zeros(nFreq,1);
% % handles.lowCh1 = zeros(nFreq,1);
% % handles.freqCh2 = zeros(nFreq,1);
% % handles.highCh2 = zeros(nFreq,1);
% % handles.lowCh2 = zeros(nFreq,1);
% % handles.waveFormCh1 = {};
% % handles.waveFormCh2 = {};
% disp('Voltage and Frequency Params Set');
% guidata(hObject,handles); %Update handles

% % --- Executes on button press in voltFreqSweepCapImgs.
% function voltFreqSweepCapImgs_Callback(hObject, eventdata, handles)
% % hObject    handle to voltFreqSweepCapImgs (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% tic
% funGenObj = handles.funGenObj;
% scopeObj = handles.scopeObj;
% vArr = handles.vArr;
% vMin = handles.vMin;
% vMax = handles.vMax;
% freqArr = handles.freqArr;
% freqMin = handles.freqMin;
% freqMax = handles.freqMax;
% devLabel = handles.devLabel;
% nVolt = handles.nVolt;
% nFreq = handles.nFreq;
% nTrials = handles.nTrials;
% scopeMeas = handles.scopeMeas;
% folderNameVoltFreq=writeSweepVoltFreqFolder(devLabel,vMin,vMax,freqMin,freqMax,nVolt,nFreq,nTrials,handles.concentrationName);
% mmc=handles.mmc;
% intervalMS = handles.intervalMS;
% mmc.stopSequenceAcquisition;
% mmc.startContinuousSequenceAcquisition(intervalMS);
% pause(0.5);
% %imageMatrix = uint16(zeros(1024,1344,nTrials,nVolt,nFreq+1));
% for k=1:nTrials
%     [freqCh1,highCh1,lowCh1,freqCh2,highCh2,lowCh2,waveFormCh1,waveFormCh2] = initOscopeDatStorStructSweepVoltFreq(nVolt,nFreq);
%     F(nVolt+1,nFreq+1) = struct('cdata',[],'colormap',[]); %Define frame structure that will store images in sweep
%     %Create directory for trial number if it does not already exist
% %     if (handles.concentrationBool==true)
% %        folderNameTrial = [folderNameVoltFreq, '\', num2str(handles.concentrationBool), 'mM\' 'Trial', num2str(k)]; 
% %     else
% %        folderNameTrial = [folderNameVoltFreq, '\', 'Trial', num2str(k)]; 
% %     end
%  folderNameTrial = [folderNameVoltFreq, '\', 'Trial', num2str(k)]; 
%     
%     
%     if (isdir(folderNameTrial)==false)
%         mkdir(folderNameTrial);
%     else
%         disp('Folder already exists. Are you sure you want to overwrite it?');
%         pause;
%     end
%     delete([folderNameTrial, '\volt*']);
%     
%     %pause(0.5);
%     figure(2);
%     img=captureImage(mmc);
%     imagesc(img), colormap('gray'), axis off %% Image data
% %     F(1) = getframe(gcf);
% %     [IM,~] = frame2im(F(1));
% %     imwrite(IM,[folderNameTrial, '\volt0.tif']);
% %     copyChan1ToChan2(funGenObj);
% %     %     initializePhase(funGenObj);
% %     %     setChannels180OutofPhase(funGenObj);
% %     setFreq(funGenObj,freqArr(1));
% %     setVoltage(funGenObj,vArr(1));
%     for l=1:nVolt
%     F(l,1) = getframe(gcf);
%     [IM,~] = frame2im(F(l,1));
%      imwrite(IM,[folderNameTrial, '\volt',num2str(l), '_freq0.tif']);
% %       imageTemp=mmc.popNextImage();
% %       imageTemp=uint16(reshape(imageTemp,1344,1024))';
% %       imageMatrix(:,:,k,l,1)=imageTemp;
% %      imwrite(imageMatrix(:,:,k,l,1),[folderNameTrial, '\volt',num2str(l), '_freq0.tif']);
%     copyChan1ToChan2(funGenObj);
%     setFreq(funGenObj,freqArr(1));
%     setVoltage(funGenObj,vArr(1));
%         %         initializePhase(funGenObj);
%         %         setChannels180OutofPhase(funGenObj);
%         setVoltage(funGenObj,vArr(l));
%         pause(1);
%         for j=1:nFreq
%                         lossRatio=1-lowPassFilt(handles.REff,handles.CEff,freqArr(j));
%                     if (lossRatio>0.1)
%                         setVoltage(funGenObj,vArr(l)*(1+lossRatio));
%                     end
% 
%             
%             setFreq(funGenObj,freqArr(j));
%             if (j==1)
%                 turnOnChannels(funGenObj);
%             end
%             initializePhase(funGenObj);
%             setChannels180OutofPhase(funGenObj);
%             if (scopeMeas==true)
%                 autoSet(scopeObj);
%                 [handles.freqCh1(l,j),handles.highCh1(l,j),handles.lowCh1(l,j),handles.freqCh2(l,j),handles.highCh2(l,j),handles.lowCh2(l,j)] = measAmpFreq(scopeObj);
%                 %handles.waveFormCh1{l,j} = getTEKtrace(handles.scopeObj,handles.pAddressScope,handles.ch1String);
%                 %handles.waveFormCh2{l,j} = getTEKtrace(handles.scopeObj,handles.pAddressScope,handles.ch2String);
%             end
%             disp([num2str(vArr(l)) 'V ' num2str(freqArr(j)) 'Hz']);
%             img=captureImage(mmc);
%             imagesc(img), colormap('gray'), axis off %% Image data
% %             imageTemp=mmc.popNextImage();
% %             imageTemp=uint16(reshape(imageTemp,1344,1024))';
% %             imageMatrix(:,:,k,l,j+1)=imageTemp;
%             pause(0.01)
%             F(l,j+1) = getframe(gcf);
%             
%         end
%             turnOffChannels(funGenObj);
%     end
%     
%     %turnOffChannels(funGenObj);
%     for l=1:nVolt
%         for j=1:nFreq
% %             disp(['l ' num2str(l) ' j ' num2str(j)]);
%             [IM,~] = frame2im(F(l,j+1));
%             imwrite(IM,[folderNameTrial, '\volt', num2str(l), '_freq', num2str(j), '.tif']);
%             %imwrite(imageMatrix(:,:,k,l,j+1),[folderNameTrial, '\volt', num2str(l), '_freq', num2str(j), '.tif']);
%             %         freqCh1 = handles.freqCh1(j); lowCh1 = handles.lowCh1(j); highCh1 = handles.highCh1(j);
%             %         freqCh2 = handles.freqCh2(j); lowCh2 = handles.lowCh2(j); highCh2 = handles.highCh2(j);
%             %         waveFormCh1 = handles.waveFormCh1{j}; waveFormCh2 = handles.waveFormCh2{j};
%             %         save([folderNameTrial, '\freq',num2str(j), '.mat'],'freqCh1','lowCh1','highCh1','freqCh2','lowCh2','highCh2','waveFormCh1','waveFormCh2');
%         end
%     end
%     freqCh1 = handles.freqCh1; lowCh1 = handles.lowCh1; highCh1 = handles.highCh1;
%     freqCh2 = handles.freqCh2; lowCh2 = handles.lowCh2; highCh2 = handles.highCh2;
%     %waveFormCh1 = handles.waveFormCh1; waveFormCh2 = handles.waveFormCh2;
%     %save([folderNameTrial, '\signalMeasurements', '.mat'],'freqCh1','lowCh1','highCh1','freqCh2','lowCh2','highCh2','waveFormCh1','waveFormCh2');
%     save([folderNameTrial, '\signalMeasurements', '.mat'],'freqCh1','lowCh1','highCh1','freqCh2','lowCh2','highCh2');
% end
%     mmc.stopSequenceAcquisition();
%     toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % --- Executes on button press in viscoelasticOscillating.
% function viscoelasticOscillating_Callback(hObject, eventdata, handles)
% % hObject    handle to viscoelasticOscillating (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% funGenObj = handles.funGenObj;
% freqArr = handles.freqArr;
% freqMin = handles.freqMin;
% freqMax = handles.freqMax;
% devLabel = handles.devLabel;
% vFixed = handles.vFixed;
% nFreq = handles.nFreq;
% nTrials = handles.nTrials;
% nCycles = 5;
% 
% 
% %%%%%%%%%%Define relevant directory names and create them if necessary%%%%%%%%%%%%
% folderNameDev = ['device',num2str(devLabel)];
% if (isdir(folderNameDev)==false)
%     mkdir(folderNameDev);
% else
%     disp('Folder already exists. Are you sure you want to overwrite it?');
%     pause;
% end
% 
% aa = datestr(datetime('now'));
% folderNameTm = [folderNameDev '\dateTime' aa(1:11) '_' num2str(now)];
% if (isdir(folderNameTm)==false)
%     mkdir(folderNameTm);
% else
%     disp('Folder already exists. Are you sure you want to overwrite it?');
%     pause;
% end
% 
% folderNameFreq = [folderNameTm, '\freqMin',num2str(freqMin),'_freqMax',num2str(freqMax),'_vFixed',num2str(vFixed),'_nFreq',num2str(nFreq)];
% if (isdir(folderNameFreq)==false)
%     mkdir(folderNameFreq);
% else
%     disp('Folder already exists. Are you sure you want to overwrite it?');
%     pause;
% end
% 
% 
% mmc=handles.mmc;
% intervalMS = handles.intervalMS;
% mmc.stopSequenceAcquisition;
% 
% for l=1:nTrials
%     mmc.startContinuousSequenceAcquisition(intervalMS);
%     pause(0.5);
%     cnt=1;
%     F(2*nFreq+1) = struct('cdata',[],'colormap',[]); %Define frame structure that will store images in sweep
%     
%     folderNameTrial = [folderNameFreq, '\', 'ViscoCycle_Trial', num2str(l)];
%     if (isdir(folderNameTrial)==false)
%         mkdir(folderNameTrial);
%     else
%         disp('Folder already exists. Are you sure you want to overwrite it?');
%         pause;
%     end
%     delete([folderNameTrial, '\freq*']);
%     for k=1:nCycles
%         freqIDX={};
%         figure(1);
%         img=captureImage(mmc);
%         imagesc(img), colormap('gray'), axis off %% Image data
%         F(1) = getframe(gcf);
%         [IM,~] = frame2im(F(1));
%         imwrite(IM,[folderNameTrial, '\freq0.tif']);
%         fwrite(funGenObj,'SOUR1:VOLT:CONC:STAT ON');
%         fwrite(funGenObj,'SOUR1:FREQ:CONC:STAT ON');
%         fwrite (funGenObj ,[ 'SOUR1:VOLT:AMPL ' num2str(vFixed) 'VPP']);
%         tic;
%         for j=1:(2*nFreq-1)
%             if (j>=1 && j<=nFreq)
%                 fwrite(funGenObj, ['SOUR1:FREQ:FIX ' num2str(freqArr(j)) 'Hz']);
%                 fwrite(funGenObj,'SOUR1:PHAS: INIT');
%                 fwrite(funGenObj,'SOUR1:PHAS:ADJ 0' );
%                 fwrite(funGenObj,'SOUR1:PHAS:ADJ 180 DEG');
%                 if (j==1)
%                     fwrite(funGenObj,'OUTP1:STAT ON');
%                     fwrite(funGenObj,'OUTP2:STAT ON');
%                 end
%                 disp([num2str(freqArr(j)) 'Hz']);
%             elseif (j>nFreq)
%                 fwrite(funGenObj, ['SOUR1:FREQ:FIX ' num2str(freqArr(2*nFreq-j)) 'Hz']);
%                 disp([num2str(freqArr(2*nFreq-j)) 'Hz']);
%             end
%             tmp=toc;
%             if (tmp>=0.1)
%                 img=captureImage(mmc);
%                 imagesc(img), colormap('gray'), axis off %% Image data
%                 if (j>=1 && j<=nFreq)
%                     %disp([num2str(freqArr(j)) 'Hz']);
%                 elseif (j>nFreq)
%                     %disp([num2str(freqArr(2*nFreq-j)) 'Hz']);
%                 end
%                 F(cnt+1) = getframe(gcf);
%                 %[IM{cnt},~] = frame2im(F(j+1));
%                 freqIDX{cnt}=j;
%                 cnt=cnt+1;
%                 %imwrite(IM,[folderNameTrial, '\freq', num2str(j), '.tif']);
%                 tic;
%             end
%             pause(0.05);
%             %[IM,~] = frame2im(F(j+1));
%             %imwrite(IM,[folderNameTrial, '\freq', num2str(j), '.tif']);
%         end
%         %fig=figure;
%         %movie(fig,F,20);
%         % Set both outputs to off
%         
%         
%     end
%     fwrite(funGenObj,'OUTP1:STAT OFF');
%     fwrite(funGenObj,'OUTP2:STAT OFF');
%     % Set output impedances of channel 1&2 to High Z
%     fwrite (funGenObj, 'OUTP1:IMP:INF');
%     fwrite (funGenObj, 'OUTP2:IMP:INF');
%     mmc.stopSequenceAcquisition();
%     F = F(1:cnt-1);
%    % cnt
%     for j=1:(cnt-2)
%         [IM,~] = frame2im(F(j+1));
%         imwrite(IM,[folderNameTrial, '\freq', num2str(j), '.tif']);
%     end
% end



