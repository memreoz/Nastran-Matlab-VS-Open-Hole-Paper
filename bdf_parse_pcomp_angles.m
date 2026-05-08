function angles = bdf_parse_pcomp_angles(lines, pl, cls)
% BDF_PARSE_PCOMP_ANGLES  Nastran PCOMP continuation satirlarindan kat acilarini okur.
%
% KULLANIM:
%   angles = bdf_parse_pcomp_angles(lines, pl, cls)
%
% GIRDILER:
%   lines : {cell} — BDF satir dizisi
%   pl    : int    — PCOMP header satirinin 1-bazli indeksi
%   cls   : [int]  — continuation satiri indeksleri
%
% CIKTI:
%   angles : double vektoru — THETA acilari [derece], bulundugu sirada
%
% FORMAT:
%   Nastran 8-char sabit format.
%   Her continuation satiri: 8 bosluk + [MID(8) T(8) THETA(8) SOUT(8)] x N_kat
%   THETA alani: col (col+16) .. (col+23), her kat icin col 32 artarak ilerler.

    angles  = [];
    all_idx = [pl, cls];

    for ii = 2 : numel(all_idx)     % pl (header) atla, sadece continuations
        ln = lines{all_idx(ii)};
        if numel(ln) < 32, continue; end

        col = 9;                     % 1-bazli: Field-2 baslangici (ilk 8 = continuation marker)

        while col + 23 <= numel(ln)
            % THETA alani: col+16 .. col+23 (1-bazli, 8 karakter)
            theta_raw = strtrim(ln(col+16 : col+23));
            if isempty(theta_raw), break; end

            v = str2double(theta_raw);
            if isnan(v), break; end

            angles(end+1) = v;       %#ok<AGROW>
            col = col + 32;          % Sonraki kat blogu
        end
    end
end
