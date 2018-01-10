# -*- coding: utf-8 -*-
"""
Created on Tue Dec 19 15:02:48 2017

@author: miguel
"""

# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import cv2
import sys
#from matplotlib import pyplot as plt
import numpy as np
 
(major_ver, minor_ver, subminor_ver) = (cv2.__version__).split('.')
 
def is_contour_bad(c):
	# approximate the contour
    peri = cv2.arcLength(c, True)
    approx = cv2.approxPolyDP(c, 0.02 * peri, True)
    area = cv2.contourArea(c) 
    #return (area>200*200 and area<600*100)
    # the contour is 'bad' if it is not a rectangle
    return not len(approx) == 4 or area<250*250 or area>500*500


def measDisplacementAdaptiveThresh(imgFileNameBase,nTrials,nFreq,vMin,vMax,freqMin,freqMax,pxl2mic):
    def is_contour_bad(c):
    	# approximate the contour
        peri = cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, 0.02 * peri, True)
        area = cv2.contourArea(c) 
        #return (area>200*200 and area<600*100)
        # the contour is 'bad' if it is not a rectangle
        return not len(approx) == 4 or area<250*250 or area>500*500

    freq=np.logspace(freqMin,freqMax,nFreq)
    dataArray=np.array(freq);
    for j in range(int(nTrials)):
        print('Trial',j+1)
        cxList=[]; cyList=[]; distList=[];
        for k in range(int(nFreq+1)):
            imgFileName=imgFileNameBase+'/Trial'+str(j+1)+'/volt1_freq'+str(k)+'.png';#"C:/Users/miguel/Documents/MATLAB/deviceT3/100uM_date_HH_mm_ss_11-Nov-2017_20_15_24/vMin4_vMax4_freqMin2_freqMax6_nVolt1_nFreq25_nTrials10/Trial1/volt1_freq0.png";
            img = cv2.imread(imgFileName,0);
            xNeighbor=51; yNeighbor=1;           
            blur = cv2.GaussianBlur(img,(5,5),0)
            
            thMn = cv2.adaptiveThreshold(blur,255,cv2.ADAPTIVE_THRESH_MEAN_C,\
                    cv2.THRESH_BINARY,xNeighbor,yNeighbor)
            imMn,contoursMn,hierarchyMn = cv2.findContours(thMn, 1, 2);   
            
            mask = np.ones(blur.shape[:2], dtype="uint8") * 255
            # loop over the contours
            contoursMnGood=[]
            for c in contoursMn:# cntGaus:
            	# if the contour is bad, draw it on the mask
                if is_contour_bad(c):
                		cv2.drawContours(mask, [c], -1, 0, -1)
                else:
                   contoursMnGood.append(c)
             
            # remove the contours from the image and show the resulting images
            thMn = cv2.bitwise_and(thMn, thMn, mask=mask)
           
            #cv2.imshow("Mask", mask)
            #cv2.imshow("After", thGaus)
            
            thMn,contoursMn,hierarchyMn = cv2.findContours(thMn, 1, 2)
            for c in contoursMnGood:
                cv2.fillPoly(thMn, pts =[c], color=(255,255,255))
            
            imMn,contoursMn,hierarchyMn = cv2.findContours(thMn, 1, 2)
            
            MMn = [cv2.moments(contoursMn[0]),cv2.moments(contoursMn[1])];
#            MGausRect = [cv2.moments(box[0]),cv2.moments(box[1])];
            
            cx = np.array([float(MMn[0]['m10']/MMn[0]['m00']),float(MMn[1]['m10']/MMn[1]['m00'])]);
            cy = np.array([float(MMn[0]['m01']/MMn[0]['m00']),float(MMn[1]['m01']/MMn[1]['m00'])]);
            
            dist = np.sqrt((cx[0]-cx[1])**2+(cy[0]-cy[1])**2)
            cxList.append(cx); cyList.append(cy); 
            if (k==0):
                distList.append(dist);
            else:
                distList.append((dist-distList[0]))
#            if (j==0 and k==0):
#                freq=np.logspace(2,6,25)
#                plt.figure(); 
        distList = [dist*pxl2mic for dist in distList[1:]]
        dataArray = np.vstack([dataArray,np.array(distList)])
    np.savetxt(imgFileNameBase+'/'+str(vMin)+'Vpp_Device12.dat',dataArray, delimiter=' ')
    return {'data':dataArray}
#        if (j==0):
#            distArray = np.array(distList);
#        else:
#            distArray = np.vstack([distArray,np.array(distList)])
#        plt.semilogx(freq,distList,'-*')