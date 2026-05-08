function f06_file = run_nastran(nastran_exe, bdf_file)

[folder, name, ~] = fileparts(bdf_file);
old_dir = cd(folder);

cmd = sprintf('"%s" "%s" scr=yes old=no', nastran_exe, bdf_file);
fprintf('Running: %s\n', cmd);
status = system(cmd);

cd(old_dir);

f06_file = fullfile(folder, [name '.f06']);

% F06 olusana kadar bekle (max 300 sn)
fprintf('F06 bekleniyor');
timeout = 300;
t0 = tic;
while ~isfile(f06_file) && toc(t0) < timeout
    pause(5);
    fprintf('.');
end
fprintf('\n');

if ~isfile(f06_file)
    error('F06 olusumadi (timeout)');
end

% F06 yazilmasi tamamlanana kadar bekle
pause(3);

fprintf('F06 hazir: %s\n', f06_file);
end