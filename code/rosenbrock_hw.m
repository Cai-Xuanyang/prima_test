function rosenbrock_hw()
%   Constraints: Unconstrained, Bound (x<=0), Linear (sum(x)<=1, x>=0), Nonlinear (sum(x^2)<=1, x>=0)
%   Initial point: [-1, -1, ..., -1]
% --- Automatically configure environment paths ---
clc;
current_dir = fileparts(mfilename('fullpath'));

% Manually add the two core paths of the prima solver
prima_interfaces = fullfile(current_dir, 'prima-main', 'matlab', 'interfaces');
prima_mex = fullfile(current_dir, 'prima-main', 'matlab', 'mex_gateways');

% Check if folders exist and add them to the MATLAB search path
if exist(prima_interfaces, 'dir') && exist(prima_mex, 'dir')
    addpath(prima_interfaces);
    addpath(prima_mex);
    fprintf('Prima solver environment configured successfully\n\n');
else
    error('Cannot find the core folders of prima!\nPlease ensure the prima-main folder is in the same directory as rosenbrock_hw.m!');
end

n = input('Enter the dimension n of the Rosenbrock function (default is 5): ');
if isempty(n)
    n = 5; 
    fprintf('No input, using default dimension n = %d\n', n);
end

fprintf('\nMinimize the %d-dimensional Rosenbrock function subject to various constraints:\n', n);
fprintf('Initial point: [');
for i = 1:n-1
    fprintf('-1, ');
end
fprintf('-1]\n');

x0 = -ones(n, 1);  % Initial point [-1, -1, ..., -1]

%% 1. Unconstrained
fprintf('\n1. No constraints:\n');
[x1, fx1, ~, ~] = prima(@chrosen, x0);
fprintf('   f(x) = %.6e\n', fx1);
fprintf('   x = [');
for i = 1:n-1
    fprintf('%.6f, ', x1(i));
end
fprintf('%.6f]\n', x1(n));

%% 2. Bound constraints: x <= 0
fprintf('\n2. Bound constraints --- x <= 0:\n');
ub = zeros(n, 1);  % Upper bound is 0
[x2, fx2, ~, ~] = prima(@chrosen, x0, [], [], [], [], [], ub);
fprintf('   f(x) = %.6e\n', fx2);
fprintf('   Constraint check: max(x) = %.6f <= 0\n', max(x2));
fprintf('   x = [');
for i = 1:n-1
    fprintf('%.6f, ', x2(i));
end
fprintf('%.6f]\n', x2(n));

%% 3. Linear constraints: sum(x) <= 1, x >= 0
fprintf('\n3. Linear constraints --- sum(x) <= 1, x >= 0:\n');
A = ones(1, n);   % sum(x) <= 1
b = 1;
lb = zeros(n, 1); % x >= 0
[x3, fx3, ~, ~] = prima(@chrosen, x0, A, b, [], [], lb, []);
fprintf('   f(x) = %.6e\n', fx3);
fprintf('   Constraint check: sum(x) = %.6f <= 1, min(x) = %.6f >= 0\n', sum(x3), min(x3));
fprintf('   x = [');
for i = 1:n-1
    fprintf('%.6f, ', x3(i));
end
fprintf('%.6f]\n', x3(n));

%% 4. Nonlinear constraints: sum(x^2) <= 1, x >= 0
fprintf('\n4. Nonlinear constraints --- sum(x^2) <= 1, x >= 0:\n');
lb = zeros(n, 1);
nonlcon = @nlc2;  % New nonlinear constraint function
[x4, fx4, ~, ~] = prima(@chrosen, x0, [], [], [], [], lb, [], nonlcon);
fprintf('   f(x) = %.6e\n', fx4);
fprintf('   Constraint check: sum(x^2) = %.6f <= 1, min(x) = %.6f >= 0\n', sum(x4.^2), min(x4));
fprintf('   x = [');
for i = 1:n-1
    fprintf('%.6f, ', x4(i));
end
fprintf('%.6f]\n', x4(n));

return


function f = chrosen(x)  % Standard Rosenbrock function
% f(x) = sum_{i=1}^{n-1} [100*(x_{i+1} - x_i^2)^2 + (1 - x_i)^2]
f = sum(100*(x(2:end) - x(1:end-1).^2).^2 + (1 - x(1:end-1)).^2);
return