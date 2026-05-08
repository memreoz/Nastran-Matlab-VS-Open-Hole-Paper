function elem_data = read_bdf_geometry(input_bdf)

fid = fopen(input_bdf,'r');
if fid == -1
    error('BDF aç?lamad?');
end

lines = {};
while ~feof(fid)
    lines{end+1} = fgetl(fid);
end
fclose(fid);

%% --- GRID oku ---
node_map = containers.Map('KeyType','double','ValueType','any');

for i = 1:length(lines)

    if contains(lines{i},'GRID')

        f = split_fixed(lines{i});
        if length(f) < 6, continue; end

        nid = str2double(f{2});
        x   = str2double(f{4});
        y   = str2double(f{5});
        z   = str2double(f{6});

        if ~isnan(nid)
            node_map(nid) = [x y z];
        end
    end
end

%% --- ELEMAN centroid + theta ---
k = 1;

for i = 1:length(lines)

    if contains(lines{i},'CQUAD4')

        f = split_fixed(lines{i});
        if length(f) < 7, continue; end

        eid = str2double(f{2});
        g1  = str2double(f{4});
        g2  = str2double(f{5});
        g3  = str2double(f{6});
        g4  = str2double(f{7});

        % --- node kontrol ---
        if ~(isKey(node_map,g1)&&isKey(node_map,g2)&&...
             isKey(node_map,g3)&&isKey(node_map,g4))
            continue;
        end

        % --- centroid ---
        p1=node_map(g1); p2=node_map(g2);
        p3=node_map(g3); p4=node_map(g4);

        centroid = (p1+p2+p3+p4)/4;

        %% --- THETA OKUMA ---
        theta = 0;  % default

        if length(f) >= 8
            theta_raw = str2double(f{8});

            if ~isnan(theta_raw)
                theta = theta_raw;
            end
        end

        %% --- kay?t ---
        elem_data(k).eid   = eid;
        elem_data(k).x     = centroid(1);
        elem_data(k).y     = centroid(2);
        elem_data(k).theta = theta;   % ? EKLEND?

        k = k + 1;
    end
end

%% --- güvenlik ---
if k == 1
    error('Hiç CQUAD4 eleman okunamad?!');
end

end