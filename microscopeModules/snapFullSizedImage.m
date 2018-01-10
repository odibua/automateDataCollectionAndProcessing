function [I]= snapFullSizedImage(mmc)

mmc.snapImage();
img = mmc.getImage();
width = mmc.getImageWidth();
height = mmc.getImageHeight();
byteDepth = mmc.getBytesPerPixel();
I=imadjust(uint16(reshape(img,width,height)'));
end