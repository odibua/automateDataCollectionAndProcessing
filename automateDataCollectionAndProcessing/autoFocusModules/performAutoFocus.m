function performAutoFocus(mmtoZ,intervalMicronsU,intervalMicronsL,zlBound,zuBound,tol,maxIter,fmeasure,zstage,mmc,intervalMS)
focusString='GLLV';
zRef=mmc.getPosition(zstage);
zu=zRef + mmtoZ*intervalMicronsU;
zl=zRef - mmtoZ*intervalMicronsL;
z1=zRef; z2=zRef; k=0;
output=goldenSearchAutoFocus(zl,zu,z1,z2,k,zlBound,zuBound,tol,maxIter,fmeasure,focusString,zstage,mmc,intervalMS);

end