function obj = evaluate_theta(theta, ...
    input_bdf, nastran_exe, base_folder, elem_data, col_id, case_id)

%% ---- PARAM ----
theta_min = 10;
theta_max = 80;

%% ---- THETA SAFETY ----
theta = max(min(theta, theta_max), theta_min);
theta = round(theta);   % ? önemli (Nastran stabilite)

%% ---- ASSIGN ----
for k = 1:length(elem_data)
    elem_data(k).theta = theta(col_id(k));
end

%% ---- UNIQUE FILE NAME ----
uid = round(1e8 * rand);

mod_bdf = fullfile(base_folder, ...
    sprintf('case_%d_%d.bdf', case_id, uid));

%% ---- WRITE BDF ----
try
    write_bdf_with_theta(input_bdf, mod_bdf, elem_data);
catch
    fprintf('? BDF yazma hatas?\n');
    obj = 1e6;
    return;
end

%% ---- RUN NASTRAN ----
try
    f06_file = run_nastran(nastran_exe, mod_bdf);
catch
    fprintf('? Nastran crash (run)\n');
    obj = 1e6;
    return;
end

%% ---- CHECK F06 ----
if ~isfile(f06_file)
    fprintf('? F06 yok\n');
    obj = 1e6;
    return;
end

%% ---- READ STRESS ----
try
    stress = read_f06_composite_stress(f06_file);
catch
    fprintf('? F06 okuma hatas?\n');
    obj = 1e6;
    return;
end

if isempty(stress)
    fprintf('? Stress bo?\n');
    obj = 1e6;
    return;
end

%% ---- OBJECTIVE ----
s = [stress.smax];

% RMS + stabilizasyon
obj = sqrt(mean(s.^2));

%% ---- NAN/INF CHECK ----
if isnan(obj) || isinf(obj)
    obj = 1e6;
end

%% ---- OPTIONAL CLEANUP ----
try
    delete(mod_bdf);
    delete(f06_file);
catch
end

end