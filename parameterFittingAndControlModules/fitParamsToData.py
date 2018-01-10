# -*- coding: utf-8 -*-
"""
Created on Fri Sep 15 09:50:01 2017

@author: miguel
"""

# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import numpy as np
from numpy import inf
#from scipy import *
#from scipy.optimize import minpack
from scipy.optimize import curve_fit
import runCombDriveModels
from runCombDriveModels import calcTimeConstantOxideOnly
##import scipy
##from scipy.optimize import least_squares
##import os
##import random
from scipy.interpolate import interp1d
from scipy.optimize import fmin
from scipy.linalg import norm


    
#Define parameters relevant to the combdrive actuator and to the electrolyte
class params:
    #Define universal constants and Temperature
    eCharge=1.602177e-19 #Charge of electron(C)
    NA = 6.02214e23 #Avogadro's Number(num/mol)
    kB=1.38065e-23 #Boltzmann Constant
    epsilon0=8.85419e-12 #Permitivitty of Free Space
    T=273+25 #Temperature (K)
            
    #Define medium constants and thickness of mediums
    lambda_Ox=2e-9 #Thickness of Oxide Layers
    lambda_Stern=0.5e-9 #Thickness of Stern Layers
    L=5e-6  #Distance between Electrodes
    epsilon0=8.85418782e-12;
    #L=5e-6  #Distance between Electrodes
    epsilonR=78 #Relative Permitivitty of Water
    epsilonOx=3.5 #Relative Permitivitty of Oxide
    epsilonStern=5.0 #Relative Permitivitty of Stern Layer
    Di = (1.93e-5)*((1e-2)**2) #Estimate of diffusivity of KCl
class combDriveParams:
    NFingers=25; #Number of comb fingers
    NCombs=4; #NEED TO CHECK THIS
    b=15e-6; #Electrode Thickness
    d=5e-6; #Comb gap
class model:
        NormalCircuit=0
        
#c0NomIn=100e-6;
#
#Vpp=2.6
#   
#dataFileName='C:/Users/miguel/Documents/MATLAB/device1/100uM_date_HH_mm_ss_14-Sep-2017_10_37_31/vMin5_vMax5_freqMin2_freqMax6_nVolt1_nFreq20_nTrials10/5Vpp_Device12.dat';
#saveDirName='C:/Users/miguel/Documents/MATLAB/device1/100uM_date_HH_mm_ss_14-Sep-2017_10_37_31/vMin5_vMax5_freqMin2_freqMax6_nVolt1_nFreq20_nTrials10/';
#Introduce class that contains combdrive fit functions and circuit model functions
def loadDataForFitting(dataFileName):
    data=np.loadtxt(dataFileName,dtype=float);    
    frequencyDimTemp=np.array(data[0])
    #omegaDimInTemp=frequencyDimTemp*2*np.pi
    frequencyDimTempStack=np.tile(frequencyDimTemp,(len(data)-1,1))
    #omegaDimInStack=np.tile(omegaDimIn,(len(data)-1,1))
    displacementsTemp = np.array(data[1:]);
    idxData = np.where(np.min(data,axis=0)>=0)[0];
    freqStart=idxData[0];
    freqEnd=len(frequencyDimTemp)
    #print(frequencyDim)
    frequencyDimTemp=frequencyDimTemp[freqStart:freqEnd]
    #omegaDimIn=omegaDimIn[freqStart:freqEnd]
    frequencyDimTempStack=frequencyDimTempStack[0:,freqStart:freqEnd]
    #omegaDimInStack=omegaDimInStack[0:,freqStart:freqEnd]
    displacementsTemp=displacementsTemp[0:,freqStart:freqEnd]
    class dataStruct:
        frequencyDim=frequencyDimTemp;
        frequencyDimStack=frequencyDimTempStack;
        displacementData=displacementsTemp;
        
    
    return dataStruct
    
def fitDataToClassicModel(saveDirName,c0NomIn,Vpp,threshFit,dataStruct):
    #curve_fit=scipy.optimize.curve_fit

    VRMS=Vpp/np.sqrt(2)   
    tauNomIn=calcTimeConstantOxideOnly(c0NomIn,params)
    combDriveDispl=runCombDriveModels.combDriveModels()
    
    frequencyDim=dataStruct.frequencyDim
    omegaDimIn=frequencyDim*2*np.pi
    frequencyDimStack=dataStruct.frequencyDimStack
    omegaDimInStack=frequencyDimStack*2*np.pi;
    displacementData = dataStruct.displacementData    
    
      
    lambda_Ox=params.lambda_Ox/1e-9
    lambda_Ox0=lambda_Ox
    bigWeight=1e10;
    scaleTau=bigWeight;
    COx=(params.epsilon0*params.epsilonOx)/lambda_Ox;
    CBulk = (params.epsilon0*params.epsilonR)/params.L;
    
    alpha0=1#1e-2
    sigma = np.sqrt(displacementData.ravel())#np.ones((np.shape(KCL100uMDat.ravel())))
    sigma[displacementData.ravel()<np.sqrt(threshFit)]=bigWeight#np.sqrt(10)
    RBulkIn  = (tauNomIn/COx)
    optVals, pcov = curve_fit(combDriveDispl.makeVikramModelFitAlpha(VRMS,params), omegaDimInStack.ravel(),  displacementData.ravel(),p0=(tauNomIn,RBulkIn,alpha0),sigma=sigma,absolute_sigma=False)
    funcDispl=combDriveDispl.makeVikramModelFitAlpha(VRMS,params)
    tauOpt=optVals[0]
    RBulkOpt=optVals[1]
    alphaOpt=optVals[2]
    modelDisplacement=funcDispl(omegaDimIn,tauOpt,RBulkOpt,alphaOpt)
    #mseDisplacementData=np.sqrt(np.mean((((modelDisplacement-displacementData))/displacementData)**2,axis=0));
    mseDisplacementData=np.sqrt(np.mean((((modelDisplacement-displacementData)))**2,axis=0))#/np.mean(displacementData,axis=0);
    mseDisplacementDataPerc=np.sqrt(np.mean((((modelDisplacement-displacementData)))**2,axis=0))/np.mean(displacementData,axis=0);
    print("Before fitting","alpha",alpha0,"RBulk", RBulkIn,"tau",tauNomIn)
    print("Classic","alpha",alphaOpt,"RBulk", RBulkOpt,"tau",tauOpt)
    print("model displacement",modelDisplacement)
    print("mse",mseDisplacementData)
    #print(np.mean(np.abs((modelDisplacement-displacementData))/displacementData,axis=0))
    np.savez_compressed(saveDirName+'fitToClassicCircuitModel',tauOpt=tauOpt,RBulkOpt=RBulkOpt,alphaOpt=alphaOpt,frequencyDim=frequencyDim,modelDisplacement=modelDisplacement,Vpp=Vpp,mseDisplacementData=mseDisplacementData);    
    
    return  {'frequencyDim':frequencyDim, 'mseDisplacementData':mseDisplacementData, 'mseDisplacementDataPerc':mseDisplacementDataPerc,'modelDisplacement':modelDisplacement,'displacementData':displacementData}

def fitDataToLeakyDielectricModel(saveDirName,c0NomIn,Vpp,threshFit,dataStruct):    
    VRMS=Vpp/np.sqrt(2)   
    tauNomIn=calcTimeConstantOxideOnly(c0NomIn,params)
    combDriveDispl=runCombDriveModels.combDriveModels()
    
    frequencyDim=dataStruct.frequencyDim
    omegaDimIn=frequencyDim*2*np.pi
    frequencyDimStack=dataStruct.frequencyDimStack
    omegaDimInStack=frequencyDimStack*2*np.pi;
    displacementData = dataStruct.displacementData    
    
      
    lambda_Ox=params.lambda_Ox/1e-9
    lambda_Ox0=lambda_Ox
    bigWeight=1e10;
    scaleTau=bigWeight;
    COx=(params.epsilon0*params.epsilonOx)/lambda_Ox;
    CBulk = (params.epsilon0*params.epsilonR)/params.L;
    
    alpha0=1#1e-2 
    sigma = np.sqrt(displacementData.ravel())#np.ones((np.shape(KCL100uMDat.ravel())))
    sigma[displacementData.ravel()<np.sqrt(threshFit)]=bigWeight#np.sqrt(10)
    RBulkIn  = (tauNomIn/COx)
     
    epsilon0 = params.epsilon0;
    epsilonOx = params.epsilonOx
    COx = (epsilon0*epsilonOx)/(lambda_Ox*1e-9);
    tauOx = tauNomIn;
    ROx0 =  tauOx/COx;#RBulkIn;#tauOx/COx;
    tauBulk0 = 0.01*tauOx#/1000;
    CStern0 =( epsilon0*params.epsilonStern)/params.lambda_Stern;
    lambdad0=np.sqrt((params.epsilonR*params.epsilon0*params.kB*params.T)/(2*(params.eCharge**2)*c0NomIn*1000.0*params.NA))
    CEDL0 =( epsilon0*params.epsilonR)/lambdad0;
    
    optVals, pcov = curve_fit(combDriveDispl.makeVikramModelRCDielFitAlpha(VRMS,combDriveParams,params), omegaDimInStack.ravel(),  displacementData.ravel(),p0=(ROx0,lambda_Ox0,tauBulk0,alpha0),bounds=(0,[inf,inf,inf,inf]),sigma=sigma,absolute_sigma=False)
    ROxOpt=optVals[0]
    lambdaOxOpt=optVals[1]
    tauBulkOptRC=optVals[2]
    alphaOptRC=optVals[3]
    funcDisplRC = combDriveDispl.makeVikramModelRCDielFitAlpha(VRMS,combDriveParams,params);
    modelDisplacement = funcDisplRC(omegaDimIn,ROxOpt,lambdaOxOpt,tauBulkOptRC,alphaOptRC);
    #mseDisplacementData=np.sqrt(np.mean((((modelDisplacement-displacementData))/displacementData)**2,axis=0));
    mseDisplacementData=np.sqrt(np.mean((((modelDisplacement-displacementData)))**2,axis=0))#/np.mean(displacementData,axis=0);
    mseDisplacementDataPerc=np.sqrt(np.mean((((modelDisplacement-displacementData)))**2,axis=0))/np.mean(displacementData,axis=0);
    print("Before Fitting","alpha",alpha0, "ROx",ROx0,"tauBulk",tauBulk0,"lambdaOx",lambda_Ox0)
    print("Leaky Optval","alpha",alphaOptRC, "ROx",ROxOpt,"tauBulk",tauBulkOptRC,"lambdaOx",lambdaOxOpt)
    print("model displacement",modelDisplacement)
    print("mse",mseDisplacementData)
    #print(np.mean(np.abs((modelDisplacement-displacementData))/displacementData,axis=0))
    np.savez_compressed(saveDirName+'fitToLeakyDielectricModel',ROxOpt=ROxOpt,lambdaOxOpt=lambdaOxOpt,tauBulkOptRC=tauBulkOptRC,alphaOptRC=alphaOptRC,frequencyDim=frequencyDim,modelDisplacement=modelDisplacement,Vpp=Vpp,mseDisplacementData=mseDisplacementData)    
    
    return {'frequencyDim':frequencyDim, 'mseDisplacementData':mseDisplacementData,'mseDisplacementDataPerc':mseDisplacementDataPerc,'modelDisplacement':modelDisplacement,'displacementData':displacementData}


def fitDataToLeakyDielectricSternModel(saveDirName,c0NomIn,Vpp,threshFit,dataStruct):    
    VRMS=Vpp/np.sqrt(2)   
    tauNomIn=calcTimeConstantOxideOnly(c0NomIn,params)
    combDriveDispl=runCombDriveModels.combDriveModels()
    
    frequencyDim=dataStruct.frequencyDim
    omegaDimIn=frequencyDim*2*np.pi
    frequencyDimStack=dataStruct.frequencyDimStack
    omegaDimInStack=frequencyDimStack*2*np.pi;
    displacementData = dataStruct.displacementData    
    
      
    lambda_Ox=params.lambda_Ox/1e-9
    lambda_Ox0=lambda_Ox
    bigWeight=1e10;
    scaleTau=bigWeight;
    COx=(params.epsilon0*params.epsilonOx)/lambda_Ox;
    CBulk = (params.epsilon0*params.epsilonR)/params.L;
    
    alpha0=1#1e-2 
    sigma = np.sqrt(displacementData.ravel())#np.ones((np.shape(KCL100uMDat.ravel())))
    sigma[displacementData.ravel()<np.sqrt(threshFit)]=bigWeight#np.sqrt(10)
    RBulkIn  = (tauNomIn/COx)
     
    epsilon0 = params.epsilon0;
    epsilonOx = params.epsilonOx
    COx = (epsilon0*epsilonOx)/(lambda_Ox*1e-9);
    tauOx = tauNomIn#tauIn0100uMKCl;
    ROx0 = tauOx/COx;
    tauBulk0 = tauOx;
    CStern0 =( epsilon0*params.epsilonStern)/params.lambda_Stern;
    lambdad0=np.sqrt((params.epsilonR*params.epsilon0*params.kB*params.T)/(2*(params.eCharge**2)*c0NomIn*1000.0*params.NA))
    CEDL0 =( epsilon0*params.epsilonR)/lambdad0;
            
    optVals, pcov = curve_fit(combDriveDispl.makeVikramModelRCDielStrnFitAlpha(VRMS,combDriveParams,params), omegaDimInStack.ravel(),  displacementData.ravel(),p0=(ROx0,lambda_Ox0,CStern0,tauBulk0,alpha0),bounds=(0,[inf,inf,0.1,inf,inf]),sigma=sigma,absolute_sigma=False)
    ROxOptRCStern=optVals[0]
    lambdaOxOptRCStern=optVals[1]
    tauBulkOptRCStern=optVals[3]
    alphaOptRCStern=optVals[4]
    CSternOptRCStern=optVals[2]
    funcDisplRCStern = combDriveDispl.makeVikramModelRCDielStrnFitAlpha(VRMS,combDriveParams,params);
    modelDisplacement = funcDisplRCStern(omegaDimIn,ROxOptRCStern,lambdaOxOptRCStern,CSternOptRCStern,tauBulkOptRCStern,alphaOptRCStern);
    #mseDisplacementData=np.sqrt(np.mean((((modelDisplacement-displacementData))/displacementData)**2,axis=0));
    mseDisplacementData=np.sqrt(np.mean((((modelDisplacement-displacementData)))**2,axis=0))#/np.mean(displacementData,axis=0);
    mseDisplacementDataPerc=np.sqrt(np.mean((((modelDisplacement-displacementData)))**2,axis=0))/np.mean(displacementData,axis=0);
    print("Before Fitting","alpha",alpha0, "ROx",ROx0,"tauBulk",tauBulk0,"lambdaOx",lambda_Ox0,"CStern",CStern0)
    print("Leaky Stern Optval","alpha",alphaOptRCStern, "ROx",ROxOptRCStern,"tauBulk",tauBulkOptRCStern,"lambdaOx",lambdaOxOptRCStern,"CStern",CSternOptRCStern)
    print("model displacement",modelDisplacement)
    print("mse",mseDisplacementData)
    #print(np.mean(np.abs((modelDisplacement-displacementData))/displacementData,axis=0))
    np.savez_compressed(saveDirName+'fitToLeakySternDielectricModel',ROxOptRCStern=ROxOptRCStern,lambdaOxOptRCStern=lambdaOxOptRCStern,tauBulkOptRCStern=tauBulkOptRCStern,alphaOptRCStern=alphaOptRCStern,CSternOptRCStern=CSternOptRCStern,frequencyDim=frequencyDim,modelDisplacement=modelDisplacement,Vpp=Vpp,mseDisplacementData=mseDisplacementData)    
    
    return {'frequencyDim':frequencyDim, 'mseDisplacementData':mseDisplacementData,'mseDisplacementDataPerc':mseDisplacementDataPerc,'modelDisplacement':modelDisplacement,'displacementData':displacementData}

                


#            targetDisplacement = np.array([0.2,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.6,2.8,3.0])
#            splVikram100uMKClTargetDispl = interp1d(KCL100uMDispl,frequencyDim100uMKCl,kind='linear')
#            splVikram500uMKClTargetDispl = interp1d(KCL500uMDispl,frequencyDim500uMKCl,kind='linear')
#            splVikram1000uMKClTargetDispl = interp1d(KCL1000uMDispl,frequencyDim1000uMKCl,kind='linear')
##            vikram100uMKClTargetDispl = splVikram100uMKClTargetDispl(targetDisplacement)
##            vikram500uMKClTargetDispl = splVikram500uMKClTargetDispl(targetDisplacement)
##            vikram1000uMKClTargetDispl = splVikram1000uMKClTargetDispl(targetDisplacement)
#            funcKCLDisplVikramDisp = combDriveDispl.makeVikramModelFitAlphaDisp(VRMS);
#            vikram100uMKClTargetDispl=np.zeros((len(targetDisplacement),1));
#            vikram500uMKClTargetDispl=np.zeros((len(targetDisplacement),1));          
#            vikram1000uMKClTargetDispl=np.zeros((len(targetDisplacement),1));
#            for k, item in enumerate(targetDisplacement):
#                vikram100uMKClTargetDispl[k] = fmin(funcKCLDisplVikramDisp,2e6*2*np.pi,args=(tau100uMOpt,RBulkOpt100uM,alphaOpt100uM,targetDisplacement[k]))/(2*np.pi);
#                vikram500uMKClTargetDispl[k] = fmin(funcKCLDisplVikramDisp,2e6*2*np.pi,args=(tau500uMOpt,RBulkOpt500uM,alphaOpt500uM,targetDisplacement[k]))/(2*np.pi);
#                vikram1000uMKClTargetDispl[k] = fmin(funcKCLDisplVikramDisp,2e6*2*np.pi,args=(tau1000uMOpt,RBulkOpt1000uM,alphaOpt1000uM,targetDisplacement[k]))/(2*np.pi);     
#                if (vikram100uMKClTargetDispl[k]<0):
#                    vikram100uMKClTargetDispl[k]=-1*vikram100uMKClTargetDispl[k];
#                if (vikram500uMKClTargetDispl[k]<0):
#                    vikram500uMKClTargetDispl[k]=-1*vikram500uMKClTargetDispl[k];  
#                if  (vikram1000uMKClTargetDispl[k]<0):
#                    vikram1000uMKClTargetDispl[k]=-1*vikram1000uMKClTargetDispl[k];
#            displ100uMKCl = np.reshape(spl100uMKCl(vikram100uMKClTargetDispl),(datEnd-datLen,len(targetDisplacement)));
#            displ500uMKCl = np.reshape(spl500uMKCl(vikram500uMKClTargetDispl),(datEnd-datLen,len(targetDisplacement)));
#            displ1000uMKCl = np.reshape(spl1000uMKCl(vikram1000uMKClTargetDispl),(datEnd-datLen,len(targetDisplacement)));
##            meanTrackErrorVikram100uM = (np.abs(displ100uMKCl-targetDisplacement))
##            meanTrackErrorVikram500uM = (np.abs(displ500uMKCl-targetDisplacement))
##            meanTrackErrorVikram1000uM = (np.abs(displ1000uMKCl-targetDisplacement))
#            meanTrackErrorVikram100uM = np.mean(np.abs(displ100uMKCl-targetDisplacement),axis=0)
#            meanTrackErrorVikram500uM = np.mean(np.abs(displ500uMKCl-targetDisplacement),axis=0)
#            meanTrackErrorVikram1000uM = np.mean(np.abs(displ1000uMKCl-targetDisplacement),axis=0)
#
#            splRC100uMKClTargetDispl = interp1d(KCL100uMDisplRC,frequencyDim100uMKCl,kind='linear')
#            splRC500uMKClTargetDispl = interp1d(KCL500uMDisplRC,frequencyDim500uMKCl,kind='linear')
#            splRC1000uMKClTargetDispl = interp1d(KCL1000uMDisplRC,frequencyDim1000uMKCl,kind='linear')
##            RC100uMKClTargetDispl = splRC100uMKClTargetDispl(targetDisplacement)
##            RC500uMKClTargetDispl = splRC500uMKClTargetDispl(targetDisplacement)
##            RC1000uMKClTargetDispl = splRC1000uMKClTargetDispl(targetDisplacement)
#            funcKCLDisplRCDisp = combDriveDispl.makeVikramModelRCDielFitAlphaDisp(VRMS,combDriveParams,params);
#            RC100uMKClTargetDispl=np.zeros((len(targetDisplacement),1));
#            RC500uMKClTargetDispl=np.zeros((len(targetDisplacement),1));          
#            RC1000uMKClTargetDispl=np.zeros((len(targetDisplacement),1));
#            for k, item in enumerate(targetDisplacement):
#                RC100uMKClTargetDispl[k] = fmin(funcKCLDisplRCDisp,1e6*2*np.pi,args=(ROxOpt100uMRC,lambdaOxOpt100uMRC,tauBulkOpt100uMRC,alphaOpt100uMRC,targetDisplacement[k]))/(2*np.pi);
#                RC500uMKClTargetDispl[k] = fmin(funcKCLDisplRCDisp,1e6*2*np.pi,args=(ROxOpt500uMRC,lambdaOxOpt500uMRC,tauBulkOpt500uMRC,alphaOpt500uMRC,targetDisplacement[k]))/(2*np.pi);
#                RC1000uMKClTargetDispl[k] = fmin(funcKCLDisplRCDisp,1e6*2*np.pi,args=(ROxOpt1000uMRC,lambdaOxOpt1000uMRC,tauBulkOpt1000uMRC,alphaOpt1000uMRC,targetDisplacement[k]))/(2*np.pi);
#                if (RC100uMKClTargetDispl[k]<0):
#                    RC100uMKClTargetDispl[k]=-1*RC100uMKClTargetDispl[k];
#                if (RC500uMKClTargetDispl[k]<0):
#                    RC500uMKClTargetDispl[k]=-1*RC500uMKClTargetDispl[k];  
#                if  (RC1000uMKClTargetDispl[k]<0):
#                    RC1000uMKClTargetDispl[k]=-1*RC1000uMKClTargetDispl[k];
#            displ100uMKCl = np.reshape(spl100uMKCl(RC100uMKClTargetDispl),(datEnd-datLen,len(targetDisplacement)));
#            displ500uMKCl = np.reshape(spl500uMKCl(RC500uMKClTargetDispl),(datEnd-datLen,len(targetDisplacement)));
#            displ1000uMKCl = np.reshape(spl1000uMKCl(RC1000uMKClTargetDispl),(datEnd-datLen,len(targetDisplacement)));
##            meanTrackErrorRC100uM = (np.abs(displ100uMKCl-targetDisplacement))
##            meanTrackErrorRC500uM = (np.abs(displ500uMKCl-targetDisplacement)
##            meanTrackErrorRC1000uM = (np.abs(displ1000uMKCl-targetDisplacement))
#            meanTrackErrorRC100uM = np.mean(np.abs(displ100uMKCl-targetDisplacement),axis=0)
#            meanTrackErrorRC500uM = np.mean(np.abs(displ500uMKCl-targetDisplacement),axis=0)
#            meanTrackErrorRC1000uM = np.mean(np.abs(displ1000uMKCl-targetDisplacement),axis=0)
#
#
#
##            
#
#
#
##            
#
#            mrkSZ=20
#            lnSZ=6
#            fntSZ=40
#            mrkScale=1.3
#            mplib.rcParams.update({'font.size':fntSZ})
#            multiple_bars = plt.figure(figsize=(18,10))
#            plt.semilogy(targetDisplacement, meanTrackErrorVikram100uM*100,'k-^',targetDisplacement, meanTrackErrorRC100uM*100,'b-*',markeredgewidth=0,markersize=mrkSZ,linewidth=lnSZ)
#            plt.title('Mean Tracking Error at 100$\mu$$\it{M}$ KCl',fontsize=fntSZ)
#            plt.xlabel('Target Displacement ($\mu$$\it{m}$)',fontsize=fntSZ)
#            plt.ylabel('Tracking Error (%)',fontsize=fntSZ)           
#            plt.legend(['Classic Model','Leaky Model'],fontsize=fntSZ,markerscale=mrkScale,loc=0) 
#            plt.tight_layout()
#            plt.grid(linewidth=3)
#            plt.show()
#            multiple_bars = plt.figure(figsize=(18,10))
#            plt.semilogy(targetDisplacement, meanTrackErrorVikram500uM*100,'k-^',targetDisplacement, meanTrackErrorRC500uM*100,'b-*',markeredgewidth=0,markersize=mrkSZ,linewidth=lnSZ)
#            plt.title('Mean Tracking Error at 500$\mu$$\it{M}$ KCl',fontsize=fntSZ)
#            plt.xlabel('Target Displacement ($\mu$$\it{m}$)',fontsize=fntSZ)
#            plt.ylabel('Tracking Error (%)',fontsize=fntSZ)                  
#            plt.legend(['Classic Model','Leaky Model'],fontsize=fntSZ,markerscale=mrkScale,loc=0)         
#            plt.tight_layout()
#            plt.grid(linewidth=3)
#            plt.show()
#            multiple_bars = plt.figure(figsize=(18,10))
#            plt.semilogy(targetDisplacement, meanTrackErrorVikram1000uM*100,'k-^',targetDisplacement, meanTrackErrorRC1000uM*100,'b-*',markeredgewidth=0,markersize=mrkSZ,linewidth=lnSZ)
#            plt.title('Mean Tracking Error at 1000$\mu$$\it{M}$ KCl',fontsize=fntSZ)
#            plt.xlabel('Target Displacement ($\mu$$\it{m}$)',fontsize=fntSZ)
#            plt.ylabel('Tracking Error (%)',fontsize=fntSZ)                  
#            plt.legend(['Classic Model','Leaky Model'],fontsize=fntSZ,markerscale=mrkScale,loc=0)
#            plt.tight_layout()  
#            plt.grid(linewidth=3)
#            plt.show()
                 
            