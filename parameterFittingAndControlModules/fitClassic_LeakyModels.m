function fitClassic_LeakyModels(saveDirName,dataFileName,threshFit,c0NomIn,Vpp)
P = py.sys.path;
insert(P,int32(0),'C:\Users\miguel\Anaconda2\Lib\site-packages');
insert(P,int32(0),[pwd,'\parameterFittingAndControlModules'])
mod = py.importlib.import_module('fitParamsToData');
py.reload(mod);


dataStruct = py.fitParamsToData.loadDataForFitting(dataFileName);
outputClassicModel = struct(py.fitParamsToData.fitDataToClassicModel(saveDirName,c0NomIn,Vpp,threshFit,dataStruct));
mseDisplacementClassic = double(py.array.array('d',py.numpy.nditer(outputClassicModel.mseDisplacementData)));
mseDisplacementClassicPerc = double(py.array.array('d',py.numpy.nditer(outputClassicModel.mseDisplacementDataPerc)));
modelDisplacementClassic = double(py.array.array('d',py.numpy.nditer(outputClassicModel.modelDisplacement)));
displacementData = double(py.array.array('d',py.numpy.nditer(outputClassicModel.displacementData)));
frequencyDimClassic = double(py.array.array('d',py.numpy.nditer(outputClassicModel.frequencyDim)));

outputLeakyModel = struct(py.fitParamsToData.fitDataToLeakyDielectricModel(saveDirName,c0NomIn,Vpp,threshFit,dataStruct));
mseDisplacementLeaky= double(py.array.array('d',py.numpy.nditer(outputLeakyModel.mseDisplacementData)));
mseDisplacementLeakyPerc= double(py.array.array('d',py.numpy.nditer(outputLeakyModel.mseDisplacementDataPerc)));
modelDisplacementLeaky = double(py.array.array('d',py.numpy.nditer(outputLeakyModel.modelDisplacement)));
displacementData = double(py.array.array('d',py.numpy.nditer(outputLeakyModel.displacementData)));
frequencyDimLeaky = double(py.array.array('d',py.numpy.nditer(outputLeakyModel .frequencyDim)));

outputLeakySternModel = struct(py.fitParamsToData.fitDataToLeakyDielectricSternModel(saveDirName,c0NomIn,Vpp,threshFit,dataStruct));
mseDisplacementLeakyStern = double(py.array.array('d',py.numpy.nditer(outputLeakySternModel.mseDisplacementData)));
mseDisplacementLeakySternPerc = double(py.array.array('d',py.numpy.nditer(outputLeakySternModel.mseDisplacementDataPerc)));
modelDisplacementLeakyStern = double(py.array.array('d',py.numpy.nditer(outputLeakySternModel.modelDisplacement)));
displacementData = double(py.array.array('d',py.numpy.nditer(outputLeakySternModel.displacementData)));
frequencyDimLeakyStern = double(py.array.array('d',py.numpy.nditer(outputLeakySternModel .frequencyDim)));

frequencyDimClassic
frequencyDimLeaky
frequencyDimLeakyStern

displacementData = reshape(displacementData,([length(frequencyDimClassic),10]))
figure;
semilogx(frequencyDimClassic,mseDisplacementClassic,'-o','LineWidth',3,'MarkerSize',8);
hold on;
semilogx(frequencyDimLeaky,mseDisplacementLeaky,'-o','LineWidth',3,'MarkerSize',8);
hold on;
semilogx(frequencyDimLeakyStern,mseDisplacementLeakyStern,'-o','LineWidth',3,'MarkerSize',8);
legend('Classic Circuit Model','Leaky Dielectric Model','Leaky Dielectric Stern Model');
xlabel('Frequency (Hz) ');
ylabel('MSE of Displacement') 
set(gca,'FontSize', 20)

figure;
semilogx(frequencyDimClassic,mseDisplacementClassicPerc*100,'-o','LineWidth',3,'MarkerSize',8);
hold on;
semilogx(frequencyDimLeaky,mseDisplacementLeakyPerc*100,'-o','LineWidth',3,'MarkerSize',8);
hold on;
semilogx(frequencyDimLeakyStern,mseDisplacementLeakySternPerc*100,'-o','LineWidth',3,'MarkerSize',8);
legend('Classic Circuit Model','Leaky Dielectric Model','Leaky Dielectric Stern Model');
xlabel('Frequency (Hz) ');
ylabel('MSE of Displacement (%)') 
ylim([0,100])
set(gca,'FontSize', 20)

std(displacementData,[],2)
figure
semilogx(frequencyDimClassic,modelDisplacementClassic,'-*',frequencyDimClassic,displacementData','-x')
title('Classic')
figure
semilogx(frequencyDimClassic,modelDisplacementLeaky,'-*',frequencyDimClassic,displacementData','-x')
title('Leaky')
figure
semilogx(frequencyDimClassic,modelDisplacementLeakyStern,'-*',frequencyDimClassic,displacementData','-x')
title('Leaky Stern')
end