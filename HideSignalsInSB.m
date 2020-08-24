%% This script hides all signals in all test cases in a signal builder with a specified leading or trailing string
%It is usable only on Matlab-Simulink model and is convenient for Signal
%handling models that are using Signal Builder as testing environment.
%Developed in Matlab 2016b and not sure if it is compatible with other
%versions

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

        if(~strcmp(answer, 'Yes'))
                errordlg('Script terminated');
                error('Terminated by user');
        end   
end

searchLead = (~isempty(inStr{1}));
searchTrail = (~isempty(inStr{2}));
processGroups = waitbar(0, 'Loading data');

%opening of the selected signal builder and extracting the data from it
open_system(findAllSBs(selectedSB), 'OpenFcn')
set(get_param(cell2mat(findAllSBs(selectedSB)), 'Userdata'), 'visible', 'off');
[time, data, signals, testGroups] = signalbuilder(cell2mat(findAllSBs(selectedSB)));
    
%local signal builder data to extract the shown signals from a test case
sbData = get(get_param(cell2mat(findAllSBs(selectedSB)), 'UserData'), 'UserData');
numGroups = size(testGroups, 2);

%expressions for matching the leading and the trailing strings of the shown
%signals
leadStrExpr = strcat(inStr{1}, '.*');
trailStrExpr = strcat('.*', inStr{2});


%looping trough all test cases of the signal builder
for iGroup = 1:numGroups
    waitbar(iGroup/numGroups,processGroups, sprintf('%d / %d', iGroup, numGroups))
    
    %switching the test case
    signalbuilder(cell2mat(findAllSBs(selectedSB)), 'activegroup', iGroup);
    
    %getting the shown signals in the test case
    activeSigIdx = sbData.dataSet(iGroup).activeDispIdx; 
    shownSignalNames = signals(activeSigIdx);
    
    
    matchLead = [];
    matchTrail = [];
    foundSignalsLead = [];
    foundSignalsTrail = [];
    signalsToHide = [];
    
    %search for a match from data input for leading string
    if (searchLead)
        matchLead = regexp(shownSignalNames, leadStrExpr);
        %indexing the matched signals
        foundSignalsLead  = cellfun('length', matchLead);
    end

    %search for a match from data input for trailing string
    if (searchTrail)
        matchTrail = regexp(shownSignalNames, trailStrExpr);
        %indexing the matched signals
        foundSignalsTrail = cellfun('length', matchTrail);
    end
    
    %if there is no match in current testcase, switch the next one
    if(isempty(foundSignalsLead) && isempty(foundSignalsTrail)) 
        continue;
    end

    % create a list of all signals that are going to be hidden and store in
    % signalsToHide variable
    shownSignals = size(shownSignalNames, 2);
    for iSignal = 1:shownSignals
        if (~isempty(foundSignalsLead))
            
            %append the signal names with matched leading string
            if(foundSignalsLead(iSignal))
            signalsToHide{end+1} = shownSignalNames{iSignal};
            end
            
        end
        
        if(~isempty(foundSignalsTrail))
        
            %append the signal names with matched trailing string
            if(foundSignalsTrail(iSignal))
            signalsToHide{end+1} = shownSignalNames{iSignal};
            end
            
        end
    end

    hideSignalsSz = size(signalsToHide, 2);
    %looping trough the signals that are to be hidden
    for iSignal = 1:hideSignalsSz
        signalbuilder(cell2mat(findAllSBs(selectedSB)), 'hidesignal', signalsToHide{iSignal}, iGroup);
        breakme2 = 0;
    end

%signalbuilder(cell2mat(findAllSBs(selectedSB)), 'activegroup', iGroup);
end

close(processGroups)

