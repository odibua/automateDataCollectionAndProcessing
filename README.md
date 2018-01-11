# Automate Data Collection and Processing (In progress)

This file contains the gui, microscopeGUI, that is used to apply voltage signals to an 
electrostatic comb-drive actuator in electrolytes. The actuator is fabricated as in [1], 
and the signal is applied in accordance with [1]. It also contains all functions called 
in the GUI in different folders. 

# Modifying Parameters Relevant to GUI:

In the initializeMicroscope_Callback function, the following parameters are important to the autofocusing algorithm:

          %Define default parameters for autofocus
          handles.mmtoZ=5000/5e-3; #Conversion between mm and the z-position obtained from scope
          handles.intervalMicronsL = 20;%35; #Lowest position below current z-stage position allowed
          handles.intervalMicronsU = 20;%35; #Highest position above current z-stage position allowed
          handles.intervalMicronsU = handles.intervalMicronsU*1e-6;
          handles.intervalMicronsL = handles.intervalMicronsL*1e-6;
          handles.maxIter=20; #Maximum number of iterations allowed in auto focus algorithm
          handles.tol=2; #Tolerance that stops auto focus algorithm (maximum difference in updated bounds in golden section algorithm)

In the postProcessDisplBWMeth_Callback function, the following parameter is important to calculating displacement:

          pxl2mic=50/388; #Gives the conversion ratio between pixels and microns that is used in calculating displacement


# Outline of Microscope GUI:
          I. Initialization Module:
                a) Initialize Microscope:         Initializes the java class mmc that is used to control the microscope,
                                                  the acquisition interval the maximum and minimum positions the stage,
                                                  is allowed to be moved, and the parameters used in the auto-focus algorithm.

                b) Focus Microscope:              Begins a while loop that allows the user to manually focus the microscope
                                                  so that the image we care about is clear.

                c) Complete Microscope Focusing:  Ends while loopBegins a while loop that allows the user to manually focus
                                                  microscope.

                d) Initialize Function Generator: Initializes object that is used to control function generator and sets two
                                                  channels 180 degrees out of phase.

                e) Initialize Dig. Oscilloscope:  Initializes object that is used to control the oscilloscope, and the channel
                                                  channels strings.
          II. Calibration Module:
                a) Set Frequency Sweep Parameters:         Sets the parameters that will be used define the amplitude of the signal applied to 
                                                           the device, the interval of frequencies over which the signal will sweep, the number 
                                                           of points in this interval, and whether the signal should be measured by an oscilloscope.
                                                           There are limits prescribed to these values to protect the device.

                b) Frequency Sweep, Capture Images:        Apply the voltage signal across prescribed frequencies for prescribed number of trials, 
                                                           capture images as a result of the applied signal, and save both the images and the
                                                           measured signals. 

                c) Set Voltage Sweep Parameters:           Sets the parameters that will be used to define the frequency of the signal applied to
                                                           the device, the interval of voltages over which the signal will sweep, and the number of points
                                                           in the interval. There are limits prescribed to these values to protect the device. 

                d) Voltage Sweep, Capture Images:          Apply the voltage signal across prescribed voltages for prescribed number of trials, 
                                                           capture images as a result of the applied signal, and save both the images and the
                                                           measured signals. 

                e) Set Voltage and Frequency Parameters:   COMMENTED OUT OF CODE. WILL BE WRITTEN LATER
                

                f) Voltage and Frequency Sweep, Capture Images:   COMMENTED OUT OF CODE. WILL BE WRITTEN LATER
  

          III. Post-processing Module:
                a) Measure Displacement, Binary Processing: Allows users to select folder obtained from the calibration module (which have
                                                            a specific structire), and process the contained files using a local adaptive gaussian 
                                                            threshold method in opencv-python. This returns the displacement of the actuator in each
                                                            trial, displays the displacements on a plot, and saves the data to a text file.

                b) Fit Model Parameters:                   Allows user to select data and to fit the parameters of different models to 
                                                             it. It saves the fit parameters, and displays the error between the model prediction
                                                             based on these parameters and the data. 
                                                     
# Contents of sub-folders: 

          I. autoFocusModules
                    a) calcFocMeasure:            Moves z-stage, capture new image, and return value of focus measure.
                    
                    b) checkInBounds:             Make sure that microscope is not being commanded to move too high or low.
                    
                    c) fmeasure:                  Contains switch statement with different measures of focus that have been 
                                                  formulated over time. 
                    
                    d) goldenSearchAutoFocus:     Implements autofocusing by using the golden search algorithm. This algorithm 
                                                  moves the stage, and uses some selected fmeasure as the objective.
                                                  
                    e) performAutoFocus:          Calls goldenSearchFocus and chooses the measurement using a string. It is 
                                                  currently using 'GLLV'.
                                                  
                    f) setFinalPosition:          Chooses the final position as the half-way point between the last upper and lower 
                                                  bound of the golden search algorithm.

          II. digitalOScopeModules
                    a) autoSet:         Auto-sets the digital oscilloscope to capture the signal it is measuring.
                    
                    b) getTekTrace:     Obtains the time-series of the signal measured by the oscilloscope as a function of time.
                    c) measAmpFreq:     Measures the frequency, peak-to-peak voltage, and high and low voltages of the signal measured on the oscilloscope.
                    
          III. functionGeneratorModules
                    a) copyChan1toChan2:          Makes sure that each channel reads the same thing.
                    
                    b) setChannels180OutofPhase:  Makes signals on the two channels 180 degrees out of phase with one another.
                    
                    c) setFreq:         Sets the frequency of the applied signal for both channels.
                    
                    d) setVoltage:      Sets the voltage of the applied signal for both channels.
                    
                    e) setVoltageCh1/2: Sets the voltage of the applied signal for channels 1/2.
                    
                    f) sweepFreq:       Apply a voltage signal across n logarithmically  spaced points in a range of frequencies.
                    
                    g) turnOffChannels:   Turn of both channels on function generator.
                    
                    h) turnOnChannels:    Turn on both channels on function generator
                    
                    
          IV. initializationModules
                    a) initOscopeDatStorStruct:   Return data structures that stores information of the digital oscilloscope
                    
                    b) initOscopeDatStorStructSweepVoltFreq:   Return data structures that stores information of the digital oscilloscope when it sweeps the voltage and frequency.
                    
                    c) initializeDigOsc:         Initializes digital oscilloscope object.
                    
                    d) initializeFuncGen:        Initializes function generator object.
                    
                    e) initializeMicroManager:   Initialize micromanager connection to microscope.
                    
                    f) initializePhase:          Initialize channels of function generator as 180 degrees out of phase.
                    
                    
          V. microscopeModules
                    a) captureImage:             Capture image with microscope that is not fit to the full size of the microscope.
                    
                    b) snapFullSizedImage:       Capture full-sized image with microscope.
                    
                    
           
          VI. parameterFittingAndControlModules
                    a) chooseFromData:            Choose the displacements you will attempt to command the actuator to move toward using open-loop control.
                    
                    b) commandFrequency.m/py:     Find the frequencies that are required to obtain the displacements given a selected model, as well as the commanded voltage.
                    
                    c) fitClassic_LeakyModels:    Call python function that finds the parameters that best fit different models to the data.        
                    
                    d) fitParamsToData.py:        Fit parameters in different models to the data using least-squares 
                                     
                    b) obtainAvgVpp:              Take the average value of the voltage measured by function generator, and                                                   use it to calculate Vpp.
                    
                    e) runCombDriveModels:        Contains functions that run different models of the actuator in                                                             electrolyte. 
                    
          VII. postProcessingModules
                    a) convertToPNGFiles: Convert generated files from function to png files.
                    
                    b) measDisplacement:  Calls python function that uses adaptive guassian procedure to binarize image and                                           find the displacement using the centroids.
                    
                    c) measDisplacementAdaptiveThresh.py:   Python function that uses adaptive guassian procedure to binarize image and                                          find the displacement using the centroids.
