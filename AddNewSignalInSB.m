%% This script adds new signal in all found and selected signal builders with desired index
%It is usable only on Matlab-Simulink model and is convenient for Signal
%handling models that are using Signal Builder as testing environment.
%Developed in Matlab 2016b and not sure if it is compatible with other
%versions

%finds all Signal builder blocks in the model and list them in array
findAllSBs = find_system(bdroot, 'StartFcn','sigbuilder_block(''start'');');

%create list of selected signal builders
selectedSBs = listdlg('ListString', findAllSBs, 'SelectionMode', 'single', 'ListSize', [500 300], 'SelectionMode', 'multiple');

if(isempty(selectedSBs))
    error('You have not selected Signal builder');
end

%User input gathering
prompt = {'New Signal name:', 'Default value:'};
dlgTitle = 'User input';
dimension = [1 65];
defVal = {'signal1', '0'};

userInput = inputdlg(prompt,dlgTitle,dimension, defVal);
newSignalName = userInput{1};
newSignalVal = str2num(userInput{2});

if(isempty(newSignal{1}))
    error('You have not entered the name of the new signal');
end

%loop trough all selected SBs
while ~isempty(selectedSBs)

    open_system(findAllSBs(selectedSBs(end)), 'OpenFcn');
    [time, data, signals, testGroups] = signalbuilder(cell2mat(findAllSBs(selectedSBs(end))));
    
    %get the current signal builder time range of the test groups
    sbTimeStart = time{1}(1);
    sbTimeEnd = time{1}(end);
    
    %appends the new signal to the last operating testing group of the
    %signal builder
    signalbuilder(cell2mat(findAllSBs(selectedSBs(end))), 'appendsignal',[sbTimeStart sbTimeEnd] , [newSignalVal newSignalVal], newSignalName);
    
    selectedSBs(end) = NaN;
    selectedSBs = selectedSBs(:,~all(isnan(selectedSBs)));
end

