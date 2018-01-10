function setVoltageCh2(obj1,vSet)
    fwrite(obj1 ,[ 'SOUR2:VOLT:AMPL ' num2str(vSet) 'VPP']);
end