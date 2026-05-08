function s = bdf_fmt_angles(ang)
% BDF_FMT_ANGLES  Kat acisi vektorunu okunakli string olarak formatlar.
%
% KULLANIM:
%   s = bdf_fmt_angles([0, 90, 0])   % -> '0/90/0'
%   s = bdf_fmt_angles([45, -45, 0]) % -> '45/-45/0'
%   s = bdf_fmt_angles([])           % -> '?'

    if isempty(ang)
        s = '?';
        return;
    end
    parts = arrayfun(@(x) sprintf('%g', x), ang, 'UniformOutput', false);
    s = strjoin(parts, '/');
end
