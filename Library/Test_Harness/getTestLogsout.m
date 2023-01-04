function [signalValues, signalTime] = getTestLogsout( signalName , test )
%% This function retrieves a logged Simulink signal from a Simulink 
% Test Case or Test Iteration object returned by a Simulation test.
% The Simulink signal must be present in the test object, therefore it
% must be logged during the test.
%
% This function is used typically within a Custom Acceptance Function in Simulink
% Test.
% 
% EXAMPLE OF USE
%    [signalValues, signalTime]   = getTestLogsout( signalName , test );
%    [TripSignal, TripSignalTime] = getTestLogsout( 'TripSignal' , test );
%
%   Also see CustomCriteria_example for an example of use within a
%   custom acceptance function.
%
% INPUTS
%   signalName   string     Name of logged Simulink signal to retrieve
%   test         object     Test case/iteration result object returned by Simulink
%                           Test to the custom acceptance function
% 
% OUTPUTS 
%   signalValues Real  Series of values of the Simulink signal for this test
%                      case/iteration
%   signalTime   Real  Time stamp for each signal sample
%
% ALGORITHM
%   The function will retrieve the logged signal by using the low-level Simulink Test API:
%    - For a test case: 
%         signalValues = test.sltest_simout.get('logsout').get(signalName).Values.Data;
%         signalTime   = test.sltest_simout.get('logsout').get(signalName).Values.Time;
%    - For a test iteration an anonymous function is used to find the index of the signal and then:
%         signalValues = test.getOutputRuns.getSignalByIndex(tempindex).dataValues.Data;
%         signalTime   = test.getOutputRuns.getSignalByIndex(tempindex).dataValues.Time;
% 
% REFERENCE DOCUMENTS
%   See Matlab help for 'Process Test Results with Custom Scripts'
% 
% IMPORTANT NOTE
%  - The Simulink signal must be present in the test object, therefore it
%    must be logged during the test.
%
% AUTHOR, TITLE
%   Benoit LEPRETTRE - SESA31961 - Model-Based Design & Algorithms Fellow
%
% HISTORY
%   Date       Name     Comments
%   2017       BLE      Initial version
%   2021       BLE      Documented version for the Core library
%
% RIGHTS & CONFIDENTIALITY
% This code is the property of Schneider Electric Industries S.A.S. It
% shall not be published or distributed without the explicit consent of the
% Library Manager.
% Contact info: benoit.leprettre@se.com


% Check if the input class if a custom criteria class of a test result class
if strcmp( class(test), 'sltest.internal.STMCustomCriteria' )
    
    %% First check that some logs are present
    assert( ~isempty( test.sltest_simout.get('logsout') ) , 'The test results do not contain any ''logsout'' results - Please enable logging in test model.');
    
    %% If logsout are present, extract signal
    if strcmp(class(test.sltest_simout.get('logsout').get(signalName).Values),'struct')
        signalValues = test.sltest_simout.get('logsout').get(signalName).Values;
        fields =  fieldnames(signalValues);
        temp = getfield(signalValues,fields{1});
        while strcmp(class(temp),'struct')
            fields =  fieldnames(temp);
            temp = getfield(temp,fields{1});
        end
        signalTime = temp.time;
    else
        signalValues = test.sltest_simout.get('logsout').get(signalName).Values.Data;
        signalTime   = test.sltest_simout.get('logsout').get(signalName).Values.Time;
    end
    
    
else
    % Passed input is a test iteration result from e.g. a test Manager result file saved as .mldatx file
    % So test is already a TestResult property
    tempindex    = find(arrayfun(@(n) strcmp(test.getOutputRuns.getSignalByIndex(n).signalLabel, signalName), 1:test.getOutputRuns.SignalCount ) );
    signalValues = test.getOutputRuns.getSignalByIndex(tempindex).dataValues.Data;
    signalTime   = test.getOutputRuns.getSignalByIndex(tempindex).dataValues.Time;
    
end

