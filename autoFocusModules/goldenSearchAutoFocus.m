function [output] = goldenSearchAutoFocus(xl,xu,x1,x2,k,xlBound,xuBound,tol,maxIter,funcMeasure,focusMeasureString,zstage,mmc,intervalMS)
if (abs(xl-xu)<tol)
    f=setFinalPosition(zstage,mmc,xl,xu,funcMeasure,focusMeasureString,intervalMS);
    disp('Tolerance reached');
    disp(['xl ', num2str(xl), ' x1 ',num2str(x1), ' x2 ', num2str(x2),' xu ',num2str(xu)]);
    mmc.stopSequenceAcquisition;
    pause(1)
%     while mmc.isSequenceRunning()
%         continue
%     end
    output=[f,xl,x1,x2,xu,abs(xu-xl),k];
elseif (k>=maxIter)
    f=setFinalPosition(zstage,mmc,xl,xu,funcMeasure,focusMeasureString,intervalMS);
    disp('Max number of iterations run')
    disp(['xl ', num2str(xl), ' x1 ',num2str(x1), ' x2 ', num2str(x2),' xu ',num2str(xu)]);
    mmc.stopSequenceAcquisition;
    pause(1)
%     while mmc.isSequenceRunning()
%         continue
%     end
    output=[f,xl,x1,x2,xu,abs(xu-xl),k];
elseif ~(checkInBounds(xl,xlBound,xuBound) && checkInBounds(xu,xlBound,xuBound))
    mmc.stopSequenceAcquisition;
    error('Bounds of xl and/or xu out of limit')
elseif (xl>xu)
    mmc.stopSequenceAcquisition;
    error('Lower bound greater than upper bound')
else
    if (k==0)
        d=(sqrt(5)-1)*(xu-xl)/2;
        x1=xl+d;
        x2=xu-d;
        mmc.stopSequenceAcquisition;
        mmc.startContinuousSequenceAcquisition(intervalMS);
    end
    if (checkInBounds(x1,xlBound,xuBound) && checkInBounds(x2,xlBound,xuBound))
        %disp('In Recursion Block')
        output=1;
        fx1=calcFocMeasure(x1,zstage,mmc,funcMeasure,focusMeasureString,intervalMS);
        fx2=calcFocMeasure(x2,zstage,mmc,funcMeasure,focusMeasureString,intervalMS);
        
        if (fx1>fx2)
            xl=x2;
            x2=x1;
            xu=xu;
            d=(sqrt(5)-1)*(xu-xl)/2;
            x1=xl+d;
            indc=0;
           % disp(['k ' num2str(k) 'xl ', num2str(xl), ' x1 ',num2str(x1), ' x2 ', num2str(x2),' xu ',num2str(xu) ,num2str(xu) 'fx1 ' num2str(fx1) ' fx2 ' num2str(fx2)]);
            output=goldenSearchAutoFocus(xl,xu,x1,x2,k+1,xlBound,xuBound,tol,maxIter,funcMeasure,focusMeasureString,zstage,mmc,intervalMS);
        elseif (fx2>=fx1)
            xl=xl;
            xu=x1;
            x1=x2;
            d=(sqrt(5)-1)*(xu-xl)/2;
            x2=xu-d;
            indc=1;
           % disp(['k ' num2str(k) 'xl ', num2str(xl), ' x1 ',num2str(x1), ' x2 ', num2str(x2),' xu ',num2str(xu) 'fx1 ' num2str(fx1) ' fx2 ' num2str(fx2)]);
            output=goldenSearchAutoFocus(xl,xu,x1,x2,k+1,xlBound,xuBound,tol,maxIter,funcMeasure,focusMeasureString,zstage,mmc,intervalMS);
        end
    else
        error('Bounds of x1 and x2 out of limit')
    end
end
end