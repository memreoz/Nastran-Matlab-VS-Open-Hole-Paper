close all; clear; clc;

nastran_exe = 'D:\MSC Nastran\bin\nastranw.exe';
input_bdf   = 'D:\Document\Analysis\Nastran\ex8_matlab\excode1.bdf';

[base_folder,~,~] = fileparts(input_bdf);

n_iter = 5;

%% geometry
elem_data = read_bdf_geometry(input_bdf);

x_vals = round([elem_data.x],6);
[~,~,col_id] = unique(x_vals);
n_col = max(col_id);

fprintf('Kolon say?s? = %d\n', n_col);

%% BASELINE
fprintf('\n===== BASELINE =====\n');

baseline_bdf = fullfile(base_folder,'baseline.bdf');
copyfile(input_bdf, baseline_bdf);

f06_base = run_nastran(nastran_exe, baseline_bdf);
stress_base = read_f06_composite_stress(f06_base);

if isempty(stress_base)
    error('Baseline stress okunamad?!');
end

baseline_obj = max([stress_base.smax]);

fprintf('Baseline obj = %.3f\n', baseline_obj);

%% INITIAL
theta = zeros(1,n_col);
best_theta = theta;
best_obj   = baseline_obj;

last_stress = stress_base;

history = zeros(n_iter,1);

%% ? ANA LOOP
for iter = 1:n_iter

    fprintf('\n===== ITER %d =====\n', iter);

    %% 1?? THETA ÜRET (F06’a ba?l?)
    theta_new = update_theta(best_theta, last_stress, elem_data, col_id, n_col);
    fprintf('Theta: ');
    fprintf('%.1f ', theta_new);
    fprintf('\n');

    %% 2?? NASTRAN ÇALI?TIR + STRESS AL
    [obj, stress_new] = evaluate_theta_with_stress(theta_new, ...
        input_bdf, nastran_exe, base_folder, elem_data, col_id, iter);

    fprintf('Obj = %.3f\n', obj);

    history(iter) = obj;

    %% 3?? KARAR
    if obj < best_obj
        best_obj   = obj;
        best_theta = theta_new;
        last_stress = stress_new;
        fprintf('? Improved\n');
    end

end

%% RESULT
fprintf('\n===== SONUÇ =====\n');
fprintf('Baseline = %.3f\n', baseline_obj);
fprintf('Best obj = %.3f\n', best_obj);

disp('Best theta:');
disp(best_theta);

figure
plot(history,'-o')
xlabel('Iteration')
ylabel('Max Stress')
title('Optimization History')
grid on