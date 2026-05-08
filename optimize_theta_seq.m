function [best_theta, best_obj, history] = optimize_theta_seq( ...
    input_bdf, nastran_exe, base_folder, elem_data, col_id, n_col, ...
    theta_init, n_iter)

%% INITIAL
best_theta = theta_init;

best_obj = evaluate_theta(best_theta, ...
    input_bdf, nastran_exe, base_folder, elem_data, col_id, 0);

step_size = 5;

history = zeros(n_iter,1);

%% MAIN LOOP
for iter = 1:n_iter

    fprintf('\n===== ITER %d =====\n', iter);

    %% ? YEN? THETA (FEEDBACK BASED)
    delta = step_size * randn(1,n_col);
    delta = max(min(delta,10),-10);

    theta_new = best_theta + delta;

    % limit
    theta_new = max(min(theta_new,80),10);
    theta_new = round(theta_new);

    fprintf('Theta = ');
    fprintf('%.2f ', theta_new);
    fprintf('\n');

    %% ? NASTRAN ÇALI?TIR (TEK TEK)
    obj = evaluate_theta(theta_new, ...
        input_bdf, nastran_exe, base_folder, elem_data, col_id, iter);

    fprintf('Obj = %.3f\n', obj);

    history(iter) = obj;

    %% ? KARAR (F06'A GÖRE)
    if obj < best_obj

        best_obj   = obj;
        best_theta = theta_new;

        step_size = step_size * 0.8;

        fprintf('? Improved\n');

    else
        step_size = step_size * 1.2;
    end

end

end