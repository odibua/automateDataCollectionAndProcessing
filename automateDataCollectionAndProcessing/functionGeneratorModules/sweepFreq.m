function [freqArr,funGenObj,scopeObj,scopeMeas,handles,imageMatrix] = sweepFreq(freqArr,funGenObj,scopeObj,scopeMeas,handles,mmc,imageMatrix)
    for j=1:nFreq
        disp([num2str(freqArr(j)) 'Hz']);
        setFreq(funGenObj,freqArr(j));
        if (j==1)
            turnOnChannels(funGenObj);
        end
        initializePhase(funGenObj);
        setChannels180OutofPhase(funGenObj);
        if (scopeMeas==true)
            autoSet(scopeObj);
            [handles.freqCh1(j),handles.vPkPkCh1(j),handles.highCh1(j),handles.lowCh1(j),handles.freqCh2(j),handles.vPkPkCh2(j),handles.highCh2(j),handles.lowCh2(j)] = measAmpFreq(scopeObj);
            handles.waveFormCh1{j} = getTEKtrace(handles.scopeObj,handles.pAddressScope,handles.ch1String);
            handles.waveFormCh2{j} = getTEKtrace(handles.scopeObj,handles.pAddressScope,handles.ch2String);
        end
        performAutoFocus(handles.mmtoZ,handles.intervalMicronsU,handles.intervalMicronsL,handles.zlBound,handles.zuBound,handles.tol,handles.maxIter,@fmeasure,handles.zstage,mmc,handles.intervalMS);
        mmc.snapImage();
        img = mmc.getImage();
        width = mmc.getImageWidth();
        height = mmc.getImageHeight();
        byteDepth = mmc.getBytesPerPixel();
        imageTemp=uint16(reshape(img,1344,1024)');
        imageMatrix(:,:,j+1)=imageTemp;
        figure(3);
        imshow(imadjust(imageTemp));
    end
end