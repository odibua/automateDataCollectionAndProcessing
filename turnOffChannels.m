function    turnOffChannels(obj1)
    fwrite(obj1,'OUTP1:STAT OFF');
    fwrite(obj1,'OUTP2:STAT OFF');
end