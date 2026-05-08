function line = join_fixed(f)

line = '';

for i = 1:length(f)
    line = [line sprintf('%-8s',f{i})];
end

end