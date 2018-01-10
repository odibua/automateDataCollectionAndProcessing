function setVoltageCh1(obj1,vSet)
    fwrite(obj1 ,[ 'SOUR1:VOLT:AMPL ' num2str(vSet) 'VPP']);
end