function convertToPNGFiles(dirName)
list=dir([dirName,'\Trial*']);
for j=1:length(list)
    list2=dir([dirName,'\',list(j).name,'\*.tif']);
    for k=1:length(list2)
        fileName=[dirName,'\',list(j).name,'\',list2(k).name];
        I=imread(fileName);
        imwrite(imadjust(I),[fileName(1:end-4),'.png']);
        
    end
end

end