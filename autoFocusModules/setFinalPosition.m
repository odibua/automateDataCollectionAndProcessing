function [f]=setFinalPosition(zstage,mmc,zl,zu,funcMeasure,focusMeasureString,intervalMS)
f=calcFocMeasure(0.5*(zu+zl),zstage,mmc,funcMeasure,focusMeasureString,intervalMS);
% mmc.waitForSystem();
% I=snapFullSizedImage(mmc);
% figure(1),imshow(imadjust(I));
end

