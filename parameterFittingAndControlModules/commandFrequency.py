# -*- coding: utf-8 -*-
"""
Created on Mon Sep 18 14:03:13 2017

@author: miguel
"""
import numpy as np
from scipy.optimize import fmin
import runCombDriveModels

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
        
def openLoopClassic(paramsFileName,targetDisplacement):
    combDriveDispl=runCombDriveModels.combDriveModels();
    modelParameters = np.load(paramsFileName);
    tauOpt = modelParameters['tauOpt'];
    RBulkOpt = modelParameters['RBulkOpt'];
    alphaOpt = modelParameters['alphaOpt'];
    Vpp = modelParameters['Vpp'];
    VRMS=Vpp/np.sqrt(2)   
    
    funcDispl=combDriveDispl.makeVikramModelFitAlphaDisp(VRMS,params);
    commandedFrequencies = np.zeros((len(targetDisplacement),1));

    for k in xrange(len(targetDisplacement)):
         commandedFrequencies[k] = fmin(funcDispl,2e6*2*np.pi,args=(tauOpt,RBulkOpt,alphaOpt,targetDisplacement[k]))/(2*np.pi);
         if (commandedFrequencies[k]<0):
             commandedFrequencies[k]=-1*commandedFrequencies[k];
    return {'commandedFrequencies':commandedFrequencies,'Vpp':2*Vpp}

def openLoopLeakyDielectric(paramsFileName,targetDisplacement):
    combDriveDispl=runCombDriveModels.combDriveModels();   
    modelParameters = np.load(paramsFileName);
    lambdaOxOpt = modelParameters['lambdaOxOpt'];
    tauBulkOptRC = modelParameters['tauBulkOptRC'];
    ROxOpt = modelParameters['ROxOpt'];
    alphaOptRC = modelParameters['alphaOptRC'];
    Vpp = modelParameters['Vpp'];
    VRMS=Vpp/np.sqrt(2) 
    
    funcDispl=combDriveDispl.makeVikramModelRCDielFitAlphaDisp(VRMS,combDriveParams,params);
    commandedFrequencies = np.zeros((len(targetDisplacement),1));

    for k in xrange(len(targetDisplacement)):
         commandedFrequencies[k] = fmin(funcDispl,2e6*2*np.pi,args=(ROxOpt,lambdaOxOpt,tauBulkOptRC,alphaOptRC,targetDisplacement[k]))/(2*np.pi);
         if (commandedFrequencies[k]<0):
             commandedFrequencies[k]=-1*commandedFrequencies[k];
    return {'commandedFrequencies':commandedFrequencies,'Vpp':2*Vpp}

def openLoopLeakySternDielectric(paramsFileName,targetDisplacement):
    combDriveDispl=runCombDriveModels.combDriveModels();   
    modelParameters = np.load(paramsFileName);
    ROxOptRCStern=modelParameters['ROxOptRCStern'];
    lambdaOxOptRCStern=modelParameters['lambdaOxOptRCStern'];
    tauBulkOptRCStern=modelParameters['tauBulkOptRCStern'];
    alphaOptRCStern=modelParameters['alphaOptRCStern'];
    CSternOptRCStern=modelParameters['CSternOptRCStern'];
    Vpp = modelParameters['Vpp'];
    VRMS=Vpp/np.sqrt(2) 
    
    funcDispl=combDriveDispl.makeVikramModelRCDielStrnFitAlphaDisp(VRMS,combDriveParams,params);
    commandedFrequencies = np.zeros((len(targetDisplacement),1));

    for k in xrange(len(targetDisplacement)):
         commandedFrequencies[k] = fmin(funcDispl,2e6*2*np.pi,args=(ROxOptRCStern,lambdaOxOptRCStern,CSternOptRCStern,tauBulkOptRCStern,alphaOptRCStern,targetDisplacement[k]))/(2*np.pi);
         if (commandedFrequencies[k]<0):
             commandedFrequencies[k]=-1*commandedFrequencies[k];
    return {'commandedFrequencies':commandedFrequencies,'Vpp':2*Vpp}