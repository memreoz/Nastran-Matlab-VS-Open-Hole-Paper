function theta_new = update_theta(theta_old, stress, elem_data, col_id, n_col)

col_stress = zeros(1,n_col);

for i = 1:length(stress)

    eid = stress(i).eid;

    % elem_data içinde bu eid'yi bul
    idx = find([elem_data.eid] == eid, 1);

    if isempty(idx)
        continue
    end

    col = col_id(idx);

    col_stress(col) = max(col_stress(col), stress(i).smax);

end

% normalize
col_stress = col_stress / max(col_stress + 1e-6);

% adaptive delta
delta = randn(1,n_col) .* (1 + 5*col_stress);

theta_new = theta_old + delta;

theta_new = max(min(theta_new,80),10);
theta_new = round(theta_new);

end