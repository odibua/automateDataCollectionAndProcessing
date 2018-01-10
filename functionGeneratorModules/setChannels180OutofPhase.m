function    setChannels180OutofPhase(obj1)
    fwrite(obj1,'SOUR1:PHAS:ADJ 0 DEG' );
    fwrite(obj1,'SOUR2:PHAS:ADJ 180 DEG');
end