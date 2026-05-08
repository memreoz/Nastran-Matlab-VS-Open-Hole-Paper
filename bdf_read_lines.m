function lines = bdf_read_lines(filepath)
% BDF_READ_LINES  BDF dosyasini satir hucre dizisi olarak okur.
%
% KULLANIM:
%   lines = bdf_read_lines('model.bdf')
%
% CIKTI:
%   lines : {Nx1 cell} — her eleman bir satir string

    fid = fopen(filepath, 'r');
    if fid < 0
        error('bdf_read_lines: Dosya acilamadi: %s', filepath);
    end
    lines = {};
    while ~feof(fid)
        lines{end+1} = fgetl(fid);  %#ok<AGROW>
    end
    fclose(fid);
end
