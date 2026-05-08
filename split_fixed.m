function f = split_fixed(line)

n = ceil(length(line)/8);
f = cell(1,n);

for i = 1:n
    s = (i-1)*8+1;
    e = min(i*8,length(line));
    f{i} = strtrim(line(s:e));
end

end

function line = join_fixed(f)

line = '';

for i = 1:length(f)
    line = [line sprintf('%-8s',f{i})];
end

end