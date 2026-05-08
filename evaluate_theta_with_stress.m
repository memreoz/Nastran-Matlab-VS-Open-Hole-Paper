function [obj, stress] = evaluate_theta_with_stress(theta, ...
    input_bdf, nastran_exe, base_folder, elem_data, col_id, case_id)

%% assign
for k = 1:length(elem_data)
    elem_data(k).theta = theta(col_id(k));
end

%% write
uid = round(1e8 * rand);
mod_bdf = fullfile(base_folder, sprintf('case_%d_%d.bdf', case_id, uid));

write_bdf_with_theta(input_bdf, mod_bdf, elem_data);

%% run
try
    f06_file = run_nastran(nastran_exe, mod_bdf);
catch
    obj = 1e6;
    stress = [];
    return;
end

%% read
stress = read_f06_composite_stress(f06_file);

if isempty(stress)
    obj = 1e6;
    return;
end

%% objective
s = [stress.smax];
obj = max(s);

end