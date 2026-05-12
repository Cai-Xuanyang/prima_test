function optiprofiler_test_hw()
% OPTIPROFILER_TEST_HW 

    clc;
    fprintf('\nStarting OptiProfiler hardware standard test...\n\n');
    
    % --- 0. Core Environment Configuration ---
    current_dir = fileparts(mfilename('fullpath'));
    prima_interfaces = fullfile(current_dir, 'prima-main', 'matlab', 'interfaces');
    prima_mex = fullfile(current_dir, 'prima-main', 'matlab', 'mex_gateways');
    optiprofiler_src = fullfile(current_dir, 'optiprofiler-main', 'matlab', 'optiprofiler', 'src');
    
    addpath(prima_interfaces);
    addpath(prima_mex);
    addpath(optiprofiler_src);
    
    pause(1);

    % --- 1. Define Solvers ---
   
    s_d = @(fun, x0, ~) prima(fun, x0, struct('precision', 'double'));
    s_s = @(fun, x0, ~) prima(fun, x0, struct('precision', 'single'));
    s_q = @(fun, x0, ~) prima(fun, x0, struct('precision', 'quadruple'));

    % --- 2. Configure Common Test Options ---
    common_options = struct();
    common_options.ptype = 'u';      
    common_options.mindim = 2;      
    common_options.maxdim = 20;     
    common_options.plibs = {'s2mpj'}; 
    
    options_plain = common_options;
    options_plain.feature_name = 'plain';
    
    options_noisy = common_options;
    options_noisy.feature_name = 'noisy';

    % --- 3. Execute Test Workflow ---
    num_rounds = 3; 

    % Test Group 1.1: double vs single (plain)
    run_test_simple({s_d, s_s}, options_plain, 'Test Group 1.1', num_rounds);

    % Test Group 1.2: double vs single (noisy)
    run_test_simple({s_d, s_s}, options_noisy, 'Test Group 1.2', num_rounds);

    % Test Group 2.1: double vs quadruple (plain)
    run_test_simple({s_d, s_q}, options_plain, 'Test Group 2.1', num_rounds);

    % Test Group 2.2: double vs quadruple (noisy)
    run_test_simple({s_d, s_q}, options_noisy, 'Test Group 2.2', num_rounds);

    fprintf('\n\n All tests have been completed!\n');
end

% --- Helper Function: Execute a single test group ---
function run_test_simple(solvers, options, group_name, num_rounds)
    fprintf('--- Starting %s: Running %d rounds ---\n', group_name, num_rounds);
    
    for k = 1:num_rounds
        fprintf('  [%s] Running round %d... ', group_name, k);
        try
            scores = benchmark(solvers, options);
            fprintf('Done.\n');
        catch ME
            fprintf('Failed: %s\n', ME.message);
        end
    end
    
    fprintf('--- %s Finished ---\n\n', group_name);
end