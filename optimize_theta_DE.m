function [best_theta, best_obj, history] = optimize_theta_DE( ...
    input_bdf, nastran_exe, base_folder, elem_data, col_id, n_col, ...
    theta_init, n_iter)

%% PARAMETERS
NP = 12;        % population size
F  = 0.6;       % mutation factor
CR = 0.8;       % crossover rate

theta_min = 5;
theta_max = 85;

%% INITIAL POPULATION
pop = zeros(NP, n_col);

for i = 1:NP
    pop(i,:) = theta_init + randn(1,n_col)*10;
end

pop = max(min(pop, theta_max), theta_min);

obj_pop = inf(NP,1);

%% INITIAL EVALUATION
fprintf('\n===== INITIAL POPULATION =====\n');

for i = 1:NP   % ? parfor kald?r?ld?

    obj_pop(i) = evaluate_theta(pop(i,:), ...
        input_bdf, nastran_exe, base_folder, elem_data, col_id, i);

    fprintf('Init %d / %d -> Obj = %.3f\n', i, NP, obj_pop(i));

end

[best_obj, idx] = min(obj_pop);
best_theta = pop(idx,:);

history = zeros(n_iter,1);

%% MAIN LOOP
for iter = 1:n_iter

    fprintf('\n===== ITER %d =====\n', iter);

    new_pop = pop;
    new_obj = obj_pop;

    for i = 1:NP   % ? parfor kald?r?ld?

        % random 3 farkl? birey seç
        idxs = randperm(NP,3);
        a = pop(idxs(1),:);
        b = pop(idxs(2),:);
        c = pop(idxs(3),:);

        % MUTATION
        mutant = a + F*(b - c);

        % CROSSOVER
        trial = pop(i,:);
        j_rand = randi(n_col);

        for j = 1:n_col
            if rand < CR || j == j_rand
                trial(j) = mutant(j);
            end
        end

        % LIMIT
        trial = max(min(trial, theta_max), theta_min);

        % EVALUATION
        obj_trial = evaluate_theta(trial, ...
            input_bdf, nastran_exe, base_folder, elem_data, col_id, i);

        fprintf('Iter %d | Case %d -> Obj = %.3f\n', iter, i, obj_trial);

        % SELECTION
        if obj_trial < obj_pop(i)
            new_pop(i,:) = trial;
            new_obj(i)   = obj_trial;
        end

    end

    pop = new_pop;
    obj_pop = new_obj;

    % global best
    [current_best, idx] = min(obj_pop);

    if current_best < best_obj
        best_obj   = current_best;
        best_theta = pop(idx,:);
    end

    history(iter) = best_obj;

    fprintf('>>> BEST OBJ = %.4f\n', best_obj);
    fprintf('>>> BEST THETA = ');
    fprintf('%.2f ', best_theta);
    fprintf('\n');

end

end