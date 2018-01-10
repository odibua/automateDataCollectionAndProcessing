function [f]=calcFocMeasure(z,zstage,mmc,funcMeasure,focusMeasureString,intervalMS)
        mmc.setPosition(zstage,z);
        mmc.waitForSystem();
        pause(2*intervalMS*1e-3);
%         I=snapFullSizedImage(mmc);
%pause(1)
I=captureImage(mmc);
%figure,imshow((I));
        %figure(1),imshow(imadjust(I));
        f=funcMeasure(I,focusMeasureString);
end