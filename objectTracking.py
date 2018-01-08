# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import cv2
import sys
from matplotlib import pyplot as plt
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


if __name__ == '__main__' :
 
    # Set up tracker.
#    # Instead of MIL, you can also use
# 
#    tracker_types = ['BOOSTING', 'MIL','KCF', 'TLD', 'MEDIANFLOW', 'GOTURN']
#    tracker_type = tracker_types[1]
# 
#    if int(minor_ver) < 3:
#        tracker = cv2.Tracker_create(tracker_type)
#    else:
#        if tracker_type == 'BOOSTING':
#            tracker = cv2.TrackerBoosting_create()
#        if tracker_type == 'MIL':
#            tracker = cv2.TrackerMIL_create()
#        if tracker_type == 'KCF':
#            tracker = cv2.TrackerKCF_create()
#        if tracker_type == 'TLD':
#            tracker = cv2.TrackerTLD_create()
#        if tracker_type == 'MEDIANFLOW':
#            tracker = cv2.TrackerMedianFlow_create()
#        if tracker_type == 'GOTURN':
#            tracker = cv2.TrackerGOTURN_create()
#    imgFileName='C:/Users/miguel/Documents/MATLAB/Outline_Tests/BF_001-0001.tif'       
#    img = cv2.imread(imgFileName,0);
#    xNeighbor=51; yNeighbor=1;
#    
#    blur = cv2.GaussianBlur(img,(5,5),0)
#    ret3,th3 = cv2.threshold(blur,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)
#    thGaus = cv2.adaptiveThreshold(blur,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,\
#    cv2.THRESH_BINARY,xNeighbor,yNeighbor)
#    thMn = cv2.adaptiveThreshold(blur,255,cv2.ADAPTIVE_THRESH_MEAN_C,\
#                    cv2.THRESH_BINARY,xNeighbor,yNeighbor)
#    plt.figure(); plt.imshow(img); plt.figure(); plt.imshow(th3); plt.figure(); plt.imshow(thGaus); plt.figure(); plt.imshow(thMn)
#

    imgFileNameBase="C:/Users/miguel/Documents/MATLAB/deviceT3/100uM_date_HH_mm_ss_11-Nov-2017_20_15_24/vMin4_vMax4_freqMin2_freqMax6_nVolt1_nFreq25_nTrials10/Trial";#1/volt1_freq";
    pxl2mic=50.0/388; nFreq=25;
    #imgFileNameBase="C:/Users/miguel/Documents/MATLAB/deviceT3/500uM_date_HH_mm_ss_11-Nov-2017_22_32_30/vMin4_vMax4_freqMin2_freqMax6_nVolt1_nFreq25_nTrials10/Trial";
    #distArray=np.array([0.0]*nFreq)
    for j in range(10):
        print('Trial',j+1)
        cxList=[]; cyList=[]; distList=[];
        for k in range(nFreq+1):
            imgFileName=imgFileNameBase+str(j+1)+'/volt1_freq'+str(k)+'.png';#"C:/Users/miguel/Documents/MATLAB/deviceT3/100uM_date_HH_mm_ss_11-Nov-2017_20_15_24/vMin4_vMax4_freqMin2_freqMax6_nVolt1_nFreq25_nTrials10/Trial1/volt1_freq0.png";
            img = cv2.imread(imgFileName,0);
            xNeighbor=51; yNeighbor=1;
            ret,thresh = cv2.threshold(img,127,255,0)
            im2,contours,hierarchy = cv2.findContours(thresh, 1, 2)
        #    # Otsu's thresholding after Gaussian filtering
            blur = cv2.GaussianBlur(img,(5,5),0)
            ret3,th3 = cv2.threshold(blur,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)
            
            thMn = cv2.adaptiveThreshold(blur,255,cv2.ADAPTIVE_THRESH_MEAN_C,\
                    cv2.THRESH_BINARY,xNeighbor,yNeighbor)
            thGaus = cv2.adaptiveThreshold(blur,255,cv2.ADAPTIVE_THRESH_GAUSSIAN_C,\
                    cv2.THRESH_BINARY,xNeighbor,yNeighbor)

            im2,contours,hierarchy = cv2.findContours(th3, 1, 2);
            cnt = contours[0]
            M = cv2.moments(cnt);
            #print( M )
            
            imMn,contoursMn,hierarchyMn = cv2.findContours(thMn, 1, 2);
            cntMn = contoursMn[0]
            MMn = cv2.moments(cntMn)
            #thGaus=thMn
            imGaus,contoursGaus,hierarchyGaus = cv2.findContours(thGaus, 1, 2);
            cntGaus = contoursGaus[0]
            
            MGaus = cv2.moments(cntGaus);
        
            mask = np.ones(blur.shape[:2], dtype="uint8") * 255
            # loop over the contours
            contoursGausGood=[]
            for c in contoursGaus:# cntGaus:
            	# if the contour is bad, draw it on the mask
                if is_contour_bad(c):
                		cv2.drawContours(mask, [c], -1, 0, -1)
                else:
                   contoursGausGood.append(c)
             
            # remove the contours from the image and show the resulting images
            thGaus = cv2.bitwise_and(thGaus, thGaus, mask=mask)
           
            #cv2.imshow("Mask", mask)
            #cv2.imshow("After", thGaus)
            
            thGaus,contoursGaus,hierarchyGaus = cv2.findContours(thGaus, 1, 2)
            for c in contoursGausGood:
                cv2.fillPoly(thGaus, pts =[c], color=(255,255,255))
            
            imGaus,contoursGaus,hierarchyGaus = cv2.findContours(thGaus, 1, 2)
            
            rect = [cv2.minAreaRect(contoursGaus[0]),cv2.minAreaRect(contoursGaus[1])];
            box = [cv2.boxPoints(rect[0]),cv2.boxPoints(rect[1])];
            MGaus = [cv2.moments(contoursGaus[0]),cv2.moments(contoursGaus[1])];
#            MGausRect = [cv2.moments(box[0]),cv2.moments(box[1])];
            
            cx = np.array([float(MGaus[0]['m10']/MGaus[0]['m00']),float(MGaus[1]['m10']/MGaus[1]['m00'])]);
            cy = np.array([float(MGaus[0]['m01']/MGaus[0]['m00']),float(MGaus[1]['m01']/MGaus[1]['m00'])]);
            
#            cx = np.array([float(MGausRect[0]['m10']/MGausRect[0]['m00']),float(MGausRect[1]['m10']/MGausRect[1]['m00'])]);
#            cy = np.array([float(MGausRect[0]['m01']/MGausRect[0]['m00']),float(MGausRect[1]['m01']/MGausRect[1]['m00'])]);
            dist = np.sqrt((cx[0]-cx[1])**2+(cy[0]-cy[1])**2)
            cxList.append(cx); cyList.append(cy); 
            if (k==0):
                distList.append(dist);
            else:
                distList.append((dist-distList[0]))
            if (j==0 and k==0):
                freq=np.logspace(2,6,25)
                plt.figure(); 
        distList = [dist*pxl2mic for dist in distList[1:]]
        if (j==0):
            distArray = np.array(distList);
        else:
            distArray = np.vstack([distArray,np.array(distList)])
        plt.semilogx(freq,distList,'-*')
######################################    
#    # Read video
#    video = cv2.VideoCapture("C:/Users/miguel/Documents/MATLAB/deviceT3/100uM_date_HH_mm_ss_11-Nov-2017_20_15_24/vMin4_vMax4_freqMin2_freqMax6_nVolt1_nFreq25_nTrials10/Trial1/out.mp4")
## 
#    # Exit if video not opened.
#    if not video.isOpened():
#        print("Could not open video")
#        sys.exit()
## 
#    # Read first frame.
#    ok, frame = video.read()
#    if not ok:
#        print('Cannot read video file')
#        sys.exit()
###     
##    # Define an initial bounding box
##    bbox = (287, 23, 86, 320)
## 
#    print("Before box chosen")
#    # Uncomment the line below to select a different bounding box
#    bbox = cv2.selectROI(frame, False)
##   
#    print("Box chosen")
#    # Initialize tracker with first frame and bounding box
#    ok = tracker.init(frame, bbox)
## 
#    print("After initialization")
#    while True:
#        # Read a new frame
#        ok, frame = video.read()
#        if not ok:
#            break
#         
#        # Start timer
#        timer = cv2.getTickCount()
# 
#        # Update tracker
#        ok, bbox = tracker.update(frame)
# 
#        # Calculate Frames per second (FPS)
#        fps = cv2.getTickFrequency() / (cv2.getTickCount() - timer);
# 
#        # Draw bounding box
#        if ok:
#            # Tracking success
#            p1 = (int(bbox[0]), int(bbox[1]))
#            p2 = (int(bbox[0] + bbox[2]), int(bbox[1] + bbox[3]))
#            cv2.rectangle(frame, p1, p2, (255,0,0), 2, 1)
#        else :
#            # Tracking failure
#            cv2.putText(frame, "Tracking failure detected", (100,80), cv2.FONT_HERSHEY_SIMPLEX, 0.75,(0,0,255),2)
# 
#        # Display tracker type on frame
#        cv2.putText(frame, tracker_type + " Tracker", (100,20), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (50,170,50),2);
#     
#        # Display FPS on frame
#        cv2.putText(frame, "FPS : " + str(int(fps)), (100,50), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (50,170,50), 2);
# 
#        # Display result
#        cv2.imshow("Tracking", frame)
# 
#        # Exit if ESC pressed
#        k = cv2.waitKey(1) & 0xff
#        if k == 27 : break