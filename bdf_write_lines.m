function bdf_write_lines(lines, filepath)
% BDF_WRITE_LINES  Satir hucre dizisini BDF dosyasi olarak yazar.
%
% KULLANIM:
%   bdf_write_lines(lines, 'output.bdf')
%
% GIRDILER:
%   lines    : {Nx1 cell} — yazilacak satir stringleri
%   filepath : string     — hedef dosya yolu

    fid = fopen(filepath, 'w');
    if fid < 0
        error('bdf_write_lines: Dosya yazilamadi: %s', filepath);
    end
    for i = 1:numel(lines)
        ln = lines{i};
        if ischar(ln)
            fprintf(fid, '%s\r\n', ln);
        end
    end
    fclose(fid);
end
