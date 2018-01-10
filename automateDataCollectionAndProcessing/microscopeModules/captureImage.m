function img=captureImage(mmc)
img=mmc.getLastImage();
%img=mmc.getImage();
%img=mmc.popNextImage();
width = mmc.getImageWidth();
height = mmc.getImageHeight();
if mmc.getBytesPerPixel == 2
    pixelType = 'uint16';
else
    pixelType = 'uint8';
end
img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
img = reshape(img, [width, height]); % image should be interpreted as a 2D array
img = imadjust(transpose(img));                % make column-major order for MATLAB

%     mmc.snapImage(); 
%     img=mmc.getImage(); 
%     imData=typecast(img,'uint16'); 
%     imData=reshape(imData,[height,width]); 
%     img=imData;
%Turn output off