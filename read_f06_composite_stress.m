function stress_data = read_f06_composite_stress(f06_file)

fid = fopen(f06_file,'r');
if fid==-1
    error('F06 aç?lamad?');
end

stress_data = [];
k = 1;

while ~feof(fid)

    line = fgetl(fid);
    if ~ischar(line), continue, end

    %% SAYILARI ÇEK
    nums = regexp(line,'[-+]?\d*\.?\d+E[+-]?\d+|[-+]?\d+\.?\d*','match');

    %% ? EN AZ 8 SAYI OLSUN YETER
    if length(nums) < 8
        continue
    end

    nums = str2double(nums);

    %% ? SAFE INDEXING
    try
        stress_data(k).eid   = nums(2);
        stress_data(k).ply   = nums(3);
        stress_data(k).s1    = nums(4);
        stress_data(k).s2    = nums(5);
        stress_data(k).s12   = nums(6);
        stress_data(k).angle = nums(end-2);
        stress_data(k).smax  = nums(end);
        k = k + 1;
    catch
        continue
    end

end

fclose(fid);

fprintf('Toplam stress kayd?: %d\n', length(stress_data));

if isempty(stress_data)
    warning('Hiç stress okunamad?!');
end

end