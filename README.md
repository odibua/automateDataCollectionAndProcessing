# Automate Data Collection and Processing

This file contains the gui, microscopeGUI, that is used to apply voltage signals to an 
electrostatic comb-drive actuator in electrolytes. The actuator is fabricated as in [1],
and the signal is applied in accordance with [1]. It also contains all functions called 
in the GUI in different folders. 

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
