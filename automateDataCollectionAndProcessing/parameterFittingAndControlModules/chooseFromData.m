function targetDisplacement = chooseFromData(dataFileName)
nTargets=15;
P = py.sys.path;
insert(P,int32(0),'C:\Users\miguel\Anaconda2\Lib\site-packages');
mod = py.importlib.import_module('fitParamsToData');
py.reload(mod);

output = struct(py.fitParamsToData.loadDataForFitting(dataFileName));
displacementMean=py.numpy.mean(output.displacementData,py.int(0));
maxDisplacement=max(displacementMean);
targetDisplacement = linspace(0.1*maxDisplacement,0.9*maxDisplacement,nTargets);


end