function pmap = bdf_build_pcomp_map(lines)
% BDF_BUILD_PCOMP_MAP  BDF satir dizisinden patch eleman PCOMP haritasini olusturur.
%
% KULLANIM:
%   pmap = bdf_build_pcomp_map(lines)
%
% GIRDI:
%   lines : {Nx1 cell} — bdf_read_lines() ciktisi
%
% CIKTI:
%   pmap : struct — her alan bir patch elemani
%     pmap.eN.pcomp_line : int    — PCOMP header satirinin 1-bazli indeksi
%     pmap.eN.cont_lines : [int]  — continuation satirlarinin indeks vektoru
%     pmap.eN.pcomp_id   : int    — Nastran PCOMP karti ID
%
% NOT:
%   Sadece PATCH_SET_ELEM_1_N bolgeleri haritalanir.
%   PLATE_SET ve diger bolgeler atlanir.

    pmap = struct();

    for i = 1:numel(lines)
        ln  = lines{i};

        % PATCH_SET_ELEM_1_N yorumunu ara
        tok = regexp(ln, 'PATCH_SET_ELEM_1_(\d+)\s*$', 'tokens');
        if isempty(tok), continue; end

        eid = str2double(tok{1}{1});
        key = sprintf('e%d', eid);

        pcomp_line = -1;
        cont_lines = [];

        % Bu yorumun altindaki PCOMP + continuation satirlarini bul
        for j = i+1 : min(i+10, numel(lines))
            lj  = lines{j};
            ljt = strtrim(lj);

            if startsWith(ljt, 'PCOMP')
                pcomp_line = j;

            elseif pcomp_line > 0 && ~isempty(lj) && lj(1) == ' ' && ...
                   ~startsWith(ljt, '$') && ~startsWith(ljt, 'CQUAD4')
                % Bos satirla baslayan, yorum/eleman olmayan -> continuation
                cont_lines(end+1) = j;  %#ok<AGROW>

            elseif pcomp_line > 0 && ~startsWith(ljt, '$')
                % Yorum degil, continuation degil -> blok bitti
                break;
            end
            % $ ile baslayan yorum satirlari atlanir (devam eder)
        end

        if pcomp_line < 0
            warning('bdf_build_pcomp_map: Eleman %d icin PCOMP bulunamadi.', eid);
            continue;
        end

        hdr     = lines{pcomp_line};
        pid_str = strtrim(hdr(9 : min(16, numel(hdr))));

        pmap.(key).pcomp_line = pcomp_line;
        pmap.(key).cont_lines = cont_lines;
        pmap.(key).pcomp_id   = str2double(pid_str);
    end
end
