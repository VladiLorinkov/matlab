%% This script hides all signals in all test cases in a signal builder with a specified leading or trailing string
%It is usable only on Matlab-Simulink model and is convenient for Signal
%Handling models that are using Signal Builder as testing environment


%finds all Signal builder blocks in the model and list them in array
findAllSBs = find_system(bdroot, 'StartFcn','sigbuilder_block(''start'');');

selectedSB = listdlg('ListString', findAllSBs, 'SelectionMode', 'single', 'ListSize', [500 300]);

if(isempty(selectedSB))
    errordlg('No Signal Builder was selected')
    error('No Signal Builder was selected')
end

%Collect user data of leading and/or trailing strings
inputString={'Enter leading string:', 'Enter trailing string:'};
inStr = inputdlg(inputString,'Collect data',[1 35]);


%If there was no valid data entered, throw an error
if(isempty(inStr{1}) && isempty(inStr{2}))
    errordlg('No data input was specified');
    error('no data input was specified');

    
% If both leading and trailing strings were specified make sure it is
% not human error
elseif(~isempty(inStr{1}) && ~isempty(inStr{2}))
        quest = {'OK', 'Cancel'};
        answer = questdlg('Both leading and trailing strings were found, are you sure?','Warning');

        if(~strcmp(answer, 'YES'))
                errordlg('Script terminated');
                error('Terminated by user');
        end   
end

%opening of the selected signal builder and getting the data from it
open_system(findAllSBs(selectedSB), 'OpenFcn')
set(get_param(cell2mat(findAllSBs(selectedSB)), 'Userdata'), 'visible', 'off');
[time, data, signals, testGroups] = signalbuilder(cell2mat(findAllSBs(selectedSB)));
numGroups = size(testGroups, 2);

