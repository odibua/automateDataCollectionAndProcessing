function    turnOnChannels(funGenObj)
    fwrite(funGenObj,'OUTP1:STAT ON');
    fwrite(funGenObj,'OUTP2:STAT ON');
end