function result = read_f06_buckling(f06_file)

fid = fopen(f06_file, 'r');
if fid == -1
    error('F06 acilamadi: %s', f06_file);
end

result.lambda = [];
result.cycles = [];
result.mode   = [];

found = false;

while ~feof(fid) && ~found
    line = fgetl(fid);
    if ~ischar(line), continue; end

    if ~isempty(strfind(line, 'R E A L   E I G E N V A L U E S'))
        fgetl(fid);  % sutun basligini atla

        while ~feof(fid)
            dline = fgetl(fid);
            if ~ischar(dline), break; end
            if isempty(strtrim(dline)), continue; end

            nums = regexp(dline, '[-+]?\d+\.?\d*[Ee][+-]?\d+|[-+]?\d+\.?\d*', 'match');

            if length(nums) >= 3
                vals = str2double(nums);
                if vals(1) == round(vals(1)) && vals(1) > 0 && vals(1) < 100
                    result.mode(end+1)   = vals(1);
                    result.lambda(end+1) = vals(3);
                    if length(nums) >= 5
                        result.cycles(end+1) = vals(5);
                    end
                end
            else
                if ~isempty(result.lambda)
                    found = true;  % ilk blok tamamlandi, dur
                    break;
                end
            end
        end
    end
end

fclose(fid);

if ~isempty(result.lambda)
    fprintf('Kritik Yuk Carpani (Mod 1): %.4f\n', result.lambda(1));
else
    warning('Eigenvalue okunamadi!');
end
end