function [commandedFrequencies,commandedVoltage] = commandFrequency(paramsFileName,targetDisplacement,chooseModel)
classicModel = 0;
leakyDielectricModel = 1;

P = py.sys.path;
insert(P,int32(0),'C:\Users\miguel\Anaconda2\Lib\site-packages');
mod = py.importlib.import_module('commandFrequency');
py.reload(mod);

if (chooseModel==classicModel)
    outputClassicModel = struct(py.commandFrequency.openLoopClassic(paramsFileName,targetDisplacement));
    commandedFrequencies = double(py.array.array('d',py.numpy.nditer(outputClassicModel.commandedFrequencies)));
    commandedVoltage = outputClassicModel.Vpp;
elseif (chooseModel==leakyDielectricModel)
    outputLeakyModel = struct(py.commandFrequency.openLoopLeakyDielectric(paramsFileName,targetDisplacement));
    commandedFrequencies = double(py.array.array('d',py.numpy.nditer(outputLeakyModel.commandedFrequencies)));
    commandedVoltage = outputLeakyModel.Vpp;
end
end

