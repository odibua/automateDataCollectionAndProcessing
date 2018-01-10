# -*- coding: utf-8 -*-
"""
Created on Fri Sep 15 11:10:19 2017

@author: miguel
"""

import numpy as np
#import matplotlib as mplib
#import matplotlib.pyplot as plt
#import matplotlib.animation as anim
#from scipy import integrate

def calcTimeConstantOxideOnly(c0NomIn,params):
    c0NomIn=(c0NomIn*1000.0)*params.NA
    #print c0NomIn
    lambda_d=np.sqrt((params.epsilonR*params.epsilon0*params.kB*params.T)/(2*(params.eCharge**2)*c0NomIn)) 
    c0NomIn=c0NomIn/(params.NA*1000)
    eps=lambda_d/params.L
    oxideLayer=1.0
    sternLayer=1.0
    doubleLayer=1.0

            
    #Define Resistance(s) and Capacitance(s)
    C0=2*eps*doubleLayer #Dimensionless linear component electric double layer capacitor
    c0=1 #Dimensionless bulk concentration of single ion
    R=1./(2*c0) #Dimensionless initial resistance of bulk       
    Cox=(params.epsilonOx/params.epsilonR)*(lambda_d/params.lambda_Ox)*C0*oxideLayer  #Dimensionless capacitance of oxide
    Cstern=(params.epsilonStern/params.epsilonR)*(lambda_d/params.lambda_Stern)*C0*sternLayer #Dimensionless capacitance of Stern Layer
    
    tau=(Cox*R)*((params.L**2)/params.Di)
    return tau
    
    
class combDriveModels():     
    def makeVikramModelFitAlpha(self,VRMS,params):
        def vikramModel(omegaDimIn,tau1,RBulk,alpha):
        #def vikramModel(omegaDimIn,tau1,alpha):
            alpha=alpha*1e-2
            epsilonR=params.epsilonR
            
            f_Tau1=((0.5*omegaDimIn*tau1)**2)/(1+((0.5*omegaDimIn*tau1)**2))  
            #f_Tau1=((0.5*omegaDimIn*tau1)**2)/(1+((0.5*omegaDimIn*tau1+omegaDimIn*tau2)**2))  
            #print VRMS**2
            #print f_Tau1
            #print alpha
            
            displ=epsilonR*(alpha)*f_Tau1*(VRMS**2)  
            
            return displ
        return vikramModel
        
    def makeVikramModelFitAlphaDisp(self,VRMS,params):
        def vikramModelDisp(omegaDimIn,tau1,RBulk,alpha,targetDispl):
        #def vikramModel(omegaDimIn,tau1,alpha):
            alpha=alpha*1e-2
            epsilonR=params.epsilonR
            f_Tau1=((0.5*omegaDimIn*tau1)**2)/(1+((0.5*omegaDimIn*tau1)**2))  
            #f_Tau1=((0.5*omegaDimIn*tau1)**2)/(1+((0.5*omegaDimIn*tau1+omegaDimIn*tau2)**2))  
            displ=epsilonR*(alpha)*f_Tau1*(VRMS**2)  
             
            return np.abs(displ-targetDispl)
        return vikramModelDisp
    
    def makeVikramModelRCDielFitAlpha(self,VRMS,combDriveParams,params):
        def vikramModelRCDielFitAlpha(omegaDimIn,ROx,lambdaOx,tauBulk,alpha):
            alpha=alpha*1e-2;
            lambdaOx = lambdaOx*1e-9;
            epsilonOx = params.epsilonOx;
            epsilonBulk = params.epsilonR;
            epsilon0  = params.epsilon0;
            g = combDriveParams.d;
            
            Cox = epsilon0*epsilonOx/(lambdaOx);
            CBulk = (epsilon0*epsilonBulk)/g;
            RBulk = tauBulk/CBulk;
            
            ZOx = ROx/(1+omegaDimIn*ROx*Cox*1j);
            ZBulk = RBulk/(1+omegaDimIn*tauBulk*1j);
            Z = 2*ZOx+ZBulk;

            fTau =abs(ZBulk/Z)**2;
            displ=epsilonBulk*alpha*fTau*(VRMS**2);
            
            
            return displ
            
        return vikramModelRCDielFitAlpha
    
    def makeVikramModelRCDielStrnFitAlpha(self,VRMS,combDriveParams,params):
        def vikramModelRCDielStrnFitAlpha(omegaDimIn,ROx,lambdaOx,CStern,tauBulk,alpha):
            alpha=alpha*1e-2;
            lambdaOx = lambdaOx*1e-9;
            epsilonOx = params.epsilonOx;
            epsilonBulk = params.epsilonR;
            epsilon0  = params.epsilon0;
            g = combDriveParams.d;
            
            Cox = epsilon0*epsilonOx/(lambdaOx);
            CBulk = (epsilon0*epsilonBulk)/g;
            RBulk = tauBulk/CBulk;
            
            ZOx = ROx/(1+omegaDimIn*ROx*Cox*1j);
            ZBulk = RBulk/(1+omegaDimIn*tauBulk*1j);
            ZStern = 1/(omegaDimIn*CStern*1j);
            Z = 2*(ZOx+ZStern)+ZBulk;

            fTau =abs(ZBulk/Z)**2;
            displ=epsilonBulk*alpha*fTau*(VRMS**2);
            
            
            return displ
        return vikramModelRCDielStrnFitAlpha
    
    
    def makeVikramModelRCDielFitAlphaDisp(self,VRMS,combDriveParams,params):
        def vikramModelRCDielFitAlphaDisp(omegaDimIn,ROx,lambdaOx,tauBulk,alpha,targetDispl):
            alpha=alpha*1e-2;
            lambdaOx = lambdaOx*1e-9;
            epsilonOx = params.epsilonOx;
            epsilonBulk = params.epsilonR;
            epsilon0  = params.epsilon0;
            g = combDriveParams.d;
            
            Cox = epsilon0*epsilonOx/(lambdaOx);
            CBulk = (epsilon0*epsilonBulk)/g;
            RBulk = tauBulk/CBulk;
            
            ZOx = ROx/(1+omegaDimIn*ROx*Cox*1j);
            ZBulk = RBulk/(1+omegaDimIn*tauBulk*1j);
            Z = 2*ZOx+ZBulk;

            fTau =abs(ZBulk/Z)**2;
            displ=epsilonBulk*alpha*fTau*(VRMS**2);
            
            
            return np.abs(displ-targetDispl)
            
        return vikramModelRCDielFitAlphaDisp
    
    
    def makeVikramModelRCDielStrnFitAlphaDisp(self,VRMS,combDriveParams,params):
        def vikramModelRCDielStrnFitAlphaDisp(omegaDimIn,ROx,lambdaOx,CStern,tauBulk,alpha,targetDispl):
            alpha=alpha*1e-2;
            lambdaOx = lambdaOx*1e-9;
            epsilonOx = params.epsilonOx;
            epsilonBulk = params.epsilonR;
            epsilon0  = params.epsilon0;
            g = combDriveParams.d;
            
            Cox = epsilon0*epsilonOx/(lambdaOx);
            CBulk = (epsilon0*epsilonBulk)/g;
            RBulk = tauBulk/CBulk;
            
            ZOx = ROx/(1+omegaDimIn*ROx*Cox*1j);
            ZBulk = RBulk/(1+omegaDimIn*tauBulk*1j);
            ZStern = 1/(omegaDimIn*CStern*1j);
            Z = 2*(ZOx+ZStern)+ZBulk;

            fTau =abs(ZBulk/Z)**2;
            displ=epsilonBulk*alpha*fTau*(VRMS**2);
            
            
            return np.abs(displ-targetDispl)
        return vikramModelRCDielStrnFitAlpha

