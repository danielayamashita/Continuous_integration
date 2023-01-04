function paramValue = getTestOverridenParameter( paramName, test )
%% This function retrieves the value of a scalar, real Simulink variable from a Simulink 
% Test Case or Test Iteration object returned by a Simulation test.
%
% The Simulink variable must be present in the test object, therefore it
% must have been selected as an overridden parameter in Simulink Test,
% either from the Parameter Override tab, or from the specification of table
% or scripted test % iterations.
%
% This function is used typically within a Custom Acceptance Function in Simulink
% Test.
%
% EXAMPLE OF USE
%    paramValue = getTestOverridenParameter( paramName, test );
%    In         = getTestOverridenParameter( 'In', test );
%
%    Also see CustomCriteria_example for an example of use within a
%    custom acceptance function.
%
% INPUTS
%   paramName   string      Name of Simulink overridden variable to retrieve
%   test        object      Test case/iteration result object returned by Simulink
%                           Test to the custom acceptance function
% 
% OUTPUTS 
%   paramValue Scalar/real  Value of the variable for this test
%                           case/iteration
%
% ALGORITHM
%   The function will retrieve the overridden parameter by using the low-level Simulink 
%   Test API. An anonymous function is used to locate the index of the
%   parameter with name 'paramName' (input argument) in the test results
%   object. if the result is not numeric, it is converted to double.
%    - For a test case: 
%        paramValue = test.TestResult.ParameterSet.ParameterOverrides(tempindex).Value;
%
%    - For a test iteration:
%        Try 
%          paramValue  = test.TestResult.IterationSettings.variableParameters(tempindex).value;
%        If nothing returned, parameter was not changed durung the itertaion, so try
%          paramValue = test.TestResult.ParameterSet.ParameterOverrides(tempindex).Value;
%
% REFERENCE DOCUMENTS
%   See Matlab help for SImulink Test, parameter override
% 
% IMPORTANT NOTE
%  - The Simulink variable must be present in the test object, therefore it
%    must have been selected as an overridden parameter in Simulink Test,
%    either from the Parameter Override tab, or from the specification of table
%    or scripted test % iterations.
%
%  - The function works only if the variable is scalar and real. To
%    retrieve more specific types (buses, etc), use the low-level API to
%    access to data within the test object.
%    See help for 'Process Test Results with Custom Scripts'
% 
%   - This function does not work for Equivalence Tests because two sets of
%     parameters are returned. Use the low-level API to explore the relevant
%     test results object and retrieve the variable.
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
    
    % Check if test was equivalence testing. If so, two sets of parameters
    % and data are returned, one for each simulation, can't choose which
    % one to select for assessing acceptance.
    if ~strcmp( test.TestResult.TestCaseType , 'Equivalence Test' )
        
        % Not an equivalence test, ok
        
        % Check if the current test is an iteration or not
        if isempty( test.sltest_iterationName )
            
            % No iteration
            % Retrieve value of overriden parameter from ParameterSet object
            tempindex  = find(arrayfun(@(n) strcmp(test.TestResult.ParameterSet.ParameterOverrides(n).Variable, paramName), 1:numel(test.TestResult.ParameterSet.ParameterOverrides)));
            paramValue = test.TestResult.ParameterSet.ParameterOverrides(tempindex).Value;
            if ~isnumeric(paramValue)
                paramValue = str2double( paramValue );
            end
            
        else
            
            % This is an iteration
            % Retrieve value from the IterationSettings object
            tempindex  = find(arrayfun(@(n) strcmp(test.TestResult.IterationSettings.variableParameters(n).parameterName, paramName), 1:numel(test.TestResult.IterationSettings.variableParameters)));
            if ~isempty( tempindex )
                paramValue  = test.TestResult.IterationSettings.variableParameters(tempindex).value;
            else
                % If not found,  parameter is not changed in the iteration, try retrieving it as if no iteration
                warning(['WARNING: Variable ' paramName ' not found, probably not changed in test iteration...']);
                tempindex  = find(arrayfun(@(n) strcmp(test.TestResult.ParameterSet.ParameterOverrides(n).Variable, paramName), 1:numel(test.TestResult.ParameterSet.ParameterOverrides)));
                paramValue = test.TestResult.ParameterSet.ParameterOverrides(tempindex).Value;
                if ~isnumeric(paramValue)
                    paramValue = str2double( paramValue );
                end
            end
        end
        
    else
        % Is an equivalence test
        error('Custom criteria function ''getTestOverridenParameter'' not available for equivalence tests, because 2 sets of results are returned.');
    end
    
elseif strcmp( class(test), 'sltest.testmanager.TestIterationResult' )
    
    if ~strcmp( test.TestResult.TestCaseType , 'Equivalence Test' )
        
        % Not an equivalence test
        % Passed input is a test iteration result from e.g. a test Manager result file saved as .mldatx file
        % So test is already a TestResult property
        tempindex  = find(arrayfun(@(n) strcmp(test.IterationSettings.variableParameters(n).parameterName, paramName), 1:numel(test.IterationSettings.variableParameters)));
        if ~isempty( tempindex )
            paramValue  = test.IterationSettings.variableParameters(tempindex).value;
        else
            % If not found,  parameter is not changed in the iteration, try retrieving it as if no iteration
            tempindex  = find(arrayfun(@(n) strcmp(test.ParameterSet.ParameterOverrides(n).Variable, paramName), 1:numel(test.ParameterSet.ParameterOverrides)));
            paramValue = test.ParameterSet.ParameterOverrides(tempindex).Value;
            if ~isnumeric(paramValue)
                paramValue = str2double( paramValue );
            end
        end
        
    else
        % Is an equivalence test
        error('Custom criteria function ''getTestOverridenParameter'' not available for equivalence tests, because 2 sets of results are returned.');
    end
end



