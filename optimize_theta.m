function [best_theta, best_obj, history] = optimize_theta(...
    input_bdf, nastran_exe, base_folder, elem_data, col_id, n_col, ...
    theta_init, obj_init, n_iter)

best_theta = theta_init;
best_obj   = obj_init;

step_size = 5;
history = zeros(n_iter,1);

for iter = 1:n_iter

    fprintf('\n===== ITER %d =====\n', iter);

    %% theta üret (stabil versiyon)
    delta = step_size*randn(1,n_col);
    delta = max(min(delta,10),-10);

    theta_new = best_theta + delta;

    % limit
    theta_new = max(min(theta_new,85),5);

    %% elemanlara ata
    for i = 1:length(elem_data)
        elem_data(i).theta = theta_new(col_id(i));
    end
    fprintf('Theta = ');
    fprintf('%.2f ', theta_new);
    fprintf('\n');

    %% BDF yaz
    mod_bdf = fullfile(base_folder, sprintf('mod_%d.bdf',iter));
    write_bdf_with_theta(input_bdf, mod_bdf, elem_data);

    %% çöz
    f06_file = run_nastran(nastran_exe, mod_bdf);

    %% stress oku
    stress = read_f06_composite_stress(f06_file);
    

    if isempty(stress)
        fprintf('? invalid çözüm ? skip\n');
        continue
    end

    obj = max([stress.smax]);
    history(iter) = obj;

    fprintf('Obj = %.3f\n', obj);

    %% update
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