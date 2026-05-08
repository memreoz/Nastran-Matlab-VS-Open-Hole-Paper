function write_bdf_with_theta(input_bdf, output_bdf, elem_data)

fid_in  = fopen(input_bdf,'r');
fid_out = fopen(output_bdf,'w');

% map
eid_map = containers.Map('KeyType','double','ValueType','double');
for i=1:length(elem_data)
    eid_map(elem_data(i).eid) = elem_data(i).theta;
end

while ~feof(fid_in)

    line = fgetl(fid_in);

    if startsWith(strtrim(line),'CQUAD4')

        % parçala (whitespace'e göre)
        tokens = strsplit(strtrim(line));

        % minimum kontrol
        if length(tokens) >= 7

            eid = str2double(tokens{2});

            if isKey(eid_map,eid)

                theta = eid_map(eid);

                if isnan(theta) || isinf(theta)
                    theta = 0;
                end

                theta = round(theta); % stabil

                % theta varsa overwrite et
                if length(tokens) >= 8
                    tokens{8} = num2str(theta);
                else
                    tokens{8} = num2str(theta);
                end

                % tekrar yaz
                line = sprintf('%-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s', tokens{:});
            end
        end
    end

    fprintf(fid_out,'%s\n',line);
end

fclose(fid_in);
fclose(fid_out);

end