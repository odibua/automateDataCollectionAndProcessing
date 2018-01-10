function copyChan1ToChan2(funGenObj)
    %fwrite(funGenObj,'SOUR1:VOLT:CONC:STAT ON');
    fwrite(funGenObj,'SOUR1:FREQ:CONC:STAT ON');
end