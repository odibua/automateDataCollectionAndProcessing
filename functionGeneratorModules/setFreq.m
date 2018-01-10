function    setFreq(obj1,freqSet) 
    fwrite(obj1, ['SOUR1:FREQ:FIX ' num2str(freqSet) 'Hz']);
end