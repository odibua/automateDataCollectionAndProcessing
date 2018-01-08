% Code Findcent.m to find centroid of objects
function rCent=FindCent(Fpath,freqIDX,voltIDX)
% Read image
%filepath=strcat(Fpath ,'n Image 001',num2str( Imgno ),'.tif');
% filepath=strcat(Fpath ,'img',num2str(Imgno),'.jpg');
filepath=strcat(Fpath ,'volt',num2str(voltIDX),'_','freq',num2str(freqIDX),'.tif');
a=imread(filepath);
adj=imadjust(a); % Adjust histogram

%adj=adj-mean(adj(:));
%figure, imshow(adj)
level = graythresh(adj);
% figure,imshow(adj)
%level+0.4*level
%%%%%%%%%%%%%%%Typical%%%%%%%%%%%%%%%%%
% abw=im2bw(adj,level+0.7*level); % Convert to b/w by thresholding
% abw=bwfill(abw,'holes'); % Fill holes in image
% [L,Num]=bwlabel(abw); %Label the images
% sarea=regionprops(L,'area'); % Find area of labelled regions
% req=find([sarea.Area]>150*170); % Locate area greater than size
% a_bwnew=ismember(L,req) ; % Create new image with these areas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
abw=im2bw(adj,level+0.3*level);
%abw=bwfill(abw,'holes'); % Fill holes in image
%abw=bwfill(abw,'holes'); % Fill holes in image%NEWWWW
[L,Num]=bwlabel(abw); %Label the images
sarea=regionprops(L,'area');
%  figure
%  imshow(abw)
req=find([sarea.Area]>200*200); % Locate area greater than size
a_bwnew=ismember(L,req); 
%a_bwnew=bwfill(a_bwnew,'holes'); % Fill holes in image
%  figure
%  imshow(a_bwnew)
%   figure
%  imshow(abw)
L=bwlabel(a_bwnew) ; % Label new image
s = regionprops(L, 'centroid' ); % Calculate centroid of new areas
centroids = cat(1,s.Centroid ) ;
rCent=centroids ; % Return centroid array
%rCent
%   hold on
%   plot(rCent(:,1),rCent(:,2),'r-*')
%
% end
 
% Code Findcent .m to f i n d c ent r o i d of o b j e c t s
% function [rCent, a_bwnew]=FindCent (Fpath , freqIDX, voltIDX,q )
% % Read image
% %filepath=strcat(Fpath ,'img',num2str(Imgno),'.tif');
% filepath=strcat(Fpath ,'volt',num2str(voltIDX),'_','freq',num2str(freqIDX),'.png');
% a=imread (filepath ) ;
% a=rgb2gray(a);
% a(:,1:80)=0;
% a(:,500:560)=0;
% a(360:420,:)=0;
% a(1:40,:)=0;
% %figure,imshow(a)
% %adj=imadjust(a); % Adjus t hi s togram
% %figure,imshow(adj)
% %med=(median((adj(:))));
% %stDev=std(double(adj(:)));
% %background=uint16(ones(size(adj)))*(med-stDev*1.2);
% %adj=medfilt2(adj,[20,20]);
% %a_bw=bwfill(adj);
% % if (q<3)
% a_bw=im2bw(a,0.3); % Convert to b/w by thresholding
% %figure,imshow(a_bw);
% %a_bw=im2bw(adj,0.7); % Convert to b/w by thresholding
% %a_bw=imclose(a_bw,strel('disk',10));
% % else
% %     a_bw=im2bw(adj,0.6); % Convert to b/w by thresholding
% % end
% %a_bw=bwfill (a_bw , 'holes' ) ; % Fill holes in image
% L=bwlabel (a_bw) ; % Label the images
% sarea=regionprops (L, 'area') ; % Find area of labelled regions
% req=find ([sarea.Area] >40*70) ; % Locate area greater than size
% a_bwnew=ismember (L, req) ; % Create new image with these areas
% L=bwlabel (a_bwnew) ; % Label new image
% s = regionprops (L, 'centroid' ) ; % Calculate centroid of new areas
% centroids = cat( 1 , s.Centroid ) ;
% rCent=centroids ; % Return centroid array
%rCent
% figure
% imshow(a)
% figure
% imshow(a_bwnew)
% hold on
%  plot(rCent(:,1),rCent(:,2),'r-*')
%   figure
%   imshow(a_bwnew)
%   hold on;
%   plot(rCent(:,1),rCent(:,2),'r-*')