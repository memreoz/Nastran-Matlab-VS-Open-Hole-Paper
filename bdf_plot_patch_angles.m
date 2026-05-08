function angle_matrix = bdf_plot_patch_angles(varargin)
% BDF_PLOT_PATCH_ANGLES  Patch elemanlarinin laminasyon acilerini 10x10 grid olarak gorsellestirir.
%
% KULLANIM:
%   (A) BDF dosyasindan oku:
%       bdf_plot_patch_angles('model.bdf')
%       bdf_plot_patch_angles('model.bdf', 'ply', 1)           % 1. kat acilari
%       bdf_plot_patch_angles('model.bdf', 'ply', 2, 'fig', 2) % 2. kat, figure 2
%
%   (B) Daha onceden olusturulmus pmap'ten:
%       lines = bdf_read_lines('model.bdf');
%       pmap  = bdf_build_pcomp_map(lines);
%       bdf_plot_patch_angles(lines, pmap)
%       bdf_plot_patch_angles(lines, pmap, 'ply', 2)
%
%   (C) Manuel aci matrisi (dis koddan):
%       M = zeros(10,10);  M(3,5) = 45; ...
%       bdf_plot_patch_angles(M)
%
% OPSIYONEL ISIM-DEGER CIFTLERI:
%   'ply'     : int     — gosterilecek kat numarasi (varsayilan: 1)
%   'fig'     : int     — figure numarasi          (varsayilan: 1)
%   'title'   : string  — grafik basligi           (varsayilan: otomatik)
%   'cmap'    : string  — renk haritasi            (varsayilan: 'hsv')
%   'clim'    : [min max] — renk skalasi limiti    (varsayilan: otomatik)
%   'showval' : logical   — hucre ici deger yazisi (varsayilan: true)
%   'fontsize': int       — hucre yazi boyutu      (varsayilan: 9)
%
% CIKTI:
%   angle_matrix : 10x10 double — M(row,col) = patch eleman acisi
%                  Satir 1 (ust) = elem 91-100, Satir 10 (alt) = elem 1-10
%
% ELEMAN-MATRIS ESLEMESI (gorseldeki numaralandirma):
%   elem_id = (10 - mat_row)*10 + mat_col
%   mat_row = 10 - floor((elem_id-1)/10)
%   mat_col = mod(elem_id-1, 10) + 1

% =========================================================================

    %% --- Girdi cozumleme ---
    [lines, pmap, angle_matrix_in, ply_idx, opts] = parse_inputs(varargin{:});

    %% --- Aci matrisini olustur ---
    if ~isempty(angle_matrix_in)
        % Manuel matris verildi
        angle_matrix = angle_matrix_in;
        source_label = 'Manuel giris';
    else
        % BDF / pmap'ten oku
        angle_matrix = extract_angle_matrix(lines, pmap, ply_idx);
        source_label = sprintf('Kat %d', ply_idx);
    end

    %% --- Gorsel ---
    figure(opts.fig_num);
    clf;

    ax = axes('Parent', gcf);
    hold(ax, 'on');

    % Renk skalasi limitleri
    valid_vals = angle_matrix(~isnan(angle_matrix));
    if isempty(valid_vals)
        clim_vals = [-90, 90];
    elseif ~isempty(opts.clim)
        clim_vals = opts.clim;
    else
        clim_vals = [min(valid_vals), max(valid_vals)];
        if clim_vals(1) == clim_vals(2)
            clim_vals = clim_vals + [-45, 45];
        end
    end

    % Renk haritasi
    colormap(ax, opts.cmap);

    % 10x10 hucre ciz
    for r = 1:10
        for c = 1:10
            val = angle_matrix(r, c);
            elem_id = (10 - r)*10 + c;

            % Renk hesapla
            if isnan(val)
                face_color = [0.85, 0.85, 0.85];   % gri = tanimsiz
            else
                t = (val - clim_vals(1)) / max(clim_vals(2) - clim_vals(1), 1e-9);
                t = max(0, min(1, t));
                cdata = colormap(ax);
                n_colors = size(cdata, 1);
                ci = max(1, min(n_colors, round(t * (n_colors-1)) + 1));
                face_color = cdata(ci, :);
            end

            % Hucre dikdortgeni (x=sutun, y=ters-satir -> ust=buyuk)
            x0 = c - 1;  y0 = 10 - r;
            rectangle('Position', [x0, y0, 1, 1], ...
                'FaceColor', face_color, ...
                'EdgeColor', [0.3, 0.3, 0.3], ...
                'LineWidth', 0.8, ...
                'Parent', ax);

            % Hucre ici metin
            if opts.showval
                % Aci degeri (ust)
                if isnan(val)
                    ang_str = '—';
                else
                    ang_str = sprintf('%g°', val);
                end
                % Eleman ID (alt, kucuk)
                text(x0 + 0.5, y0 + 0.62, ang_str, ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment',   'middle', ...
                    'FontSize',  opts.fontsize, ...
                    'FontWeight', 'bold', ...
                    'Color', text_color(face_color), ...
                    'Parent', ax);

                text(x0 + 0.5, y0 + 0.22, sprintf('%d', elem_id), ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment',   'middle', ...
                    'FontSize',  opts.fontsize - 2, ...
                    'Color', text_color(face_color) * 0.8, ...
                    'Parent', ax);
            end
        end
    end

    %% --- Eksen ayarlari ---
    xlim(ax, [0, 10]);
    ylim(ax, [0, 10]);
    axis(ax, 'equal');
    set(ax, 'XTick', 0.5:1:9.5, 'XTickLabel', arrayfun(@num2str, 1:10, 'UniformOutput', false));
    set(ax, 'YTick', 0.5:1:9.5, 'YTickLabel', arrayfun(@num2str, 10:-1:1, 'UniformOutput', false));
    set(ax, 'TickLength', [0 0]);
    set(ax, 'FontSize', 9);
    xlabel(ax, 'Sutun (sol \rightarrow sag)', 'FontSize', 11);
    ylabel(ax, 'Satir (ust \rightarrow alt)',  'FontSize', 11);
    box(ax, 'on');

    % Renk cubugu
    cb = colorbar(ax);
    caxis(ax, clim_vals);
    ylabel(cb, 'Aci [°]', 'FontSize', 10);

    % Baslik
    if isempty(opts.title_str)
        title_str = sprintf('Patch Eleman Laminasyon Acilari — %s', source_label);
    else
        title_str = opts.title_str;
    end
    title(ax, title_str, 'FontSize', 13, 'FontWeight', 'bold');

    hold(ax, 'off');
    drawnow;

    %% --- Konsol ozeti ---
    fprintf('\n--- Patch Aci Matrisi (Kat %d) ---\n', ply_idx);
    fprintf('     ');
    for c = 1:10, fprintf('  C%-2d', c); end
    fprintf('\n');
    for r = 1:10
        fprintf('R%02d: ', r);
        for c = 1:10
            if isnan(angle_matrix(r,c))
                fprintf('   ? ');
            else
                fprintf('%5g', angle_matrix(r,c));
            end
        end
        fprintf('\n');
    end
    fprintf('(R1=ust satir: elem 91-100, R10=alt satir: elem 1-10)\n\n');
end


%% =========================================================================
%  YARDIMCI: Aci matrisini pmap'ten cikar
%% =========================================================================

function M = extract_angle_matrix(lines, pmap, ply_idx)
% EXTRACT_ANGLE_MATRIX  pmap'ten 10x10 aci matrisi olusturur.

    M = nan(10, 10);

    for elem_id = 1:100
        key = sprintf('e%d', elem_id);
        if ~isfield(pmap, key), continue; end

        e      = pmap.(key);
        angles = bdf_parse_pcomp_angles(lines, e.pcomp_line, e.cont_lines);

        if ply_idx <= numel(angles)
            val = angles(ply_idx);
        else
            val = NaN;    % Bu kat bu elemanda tanimli degil
        end

        % Eleman ID -> matris indeksi
        mat_row = 10 - floor((elem_id - 1) / 10);
        mat_col = mod(elem_id - 1, 10) + 1;
        M(mat_row, mat_col) = val;
    end
end


%% =========================================================================
%  YARDIMCI: Metin rengi (koyu zemin -> beyaz, acik zemin -> siyah)
%% =========================================================================

function c = text_color(bg)
% TEXT_COLOR  Arka plan rengine gore okunakli yazi rengi dondurur.
    luminance = 0.299*bg(1) + 0.587*bg(2) + 0.114*bg(3);
    if luminance < 0.5
        c = [1, 1, 1];   % beyaz
    else
        c = [0, 0, 0];   % siyah
    end
end


%% =========================================================================
%  YARDIMCI: Girdi cozumleme
%% =========================================================================

function [lines, pmap, angle_matrix, ply_idx, opts] = parse_inputs(varargin)

    lines        = {};
    pmap         = struct();
    angle_matrix = [];
    ply_idx      = 1;

    % Varsayilan opsiyonlar
    opts.fig_num   = 1;
    opts.title_str = '';
    opts.cmap      = 'hsv';
    opts.clim      = [];
    opts.showval   = true;
    opts.fontsize  = 9;

    if isempty(varargin)
        error('bdf_plot_patch_angles: En az bir girdi gerekli.');
    end

    % Ilk arguman tipine gore mod belirle
    arg1 = varargin{1};
    rest_start = 2;

    if ischar(arg1)
        % MOD A: BDF dosya yolu
        lines = bdf_read_lines(arg1);
        pmap  = bdf_build_pcomp_map(lines);

    elseif isstruct(arg1)
        % Bu olmamali (eski cagri sekli) — hata ver
        error('bdf_plot_patch_angles: Birinci arguman BDF yolu veya matris olmali.');

    elseif isnumeric(arg1) && numel(arg1) == 100
        % MOD C: 1x100 veya 100x1 veya 10x10 aci matrisi/vektoru
        if isvector(arg1)
            % Vektor -> matrise donustur
            v = arg1(:);
            tmp = nan(10,10);
            for eid = 1:100
                r = 10 - floor((eid-1)/10);
                c = mod(eid-1,10) + 1;
                tmp(r,c) = v(eid);
            end
            angle_matrix = tmp;
        else
            angle_matrix = reshape(arg1, 10, 10);
        end

    elseif isnumeric(arg1) && all(size(arg1) == [10, 10])
        % MOD C: 10x10 matris
        angle_matrix = arg1;

    elseif iscell(arg1)
        % MOD B: lines cell dizisi verildi, ikinci arg pmap olmali
        lines = arg1;
        if numel(varargin) >= 2 && isstruct(varargin{2})
            pmap = varargin{2};
            rest_start = 3;
        else
            pmap = bdf_build_pcomp_map(lines);
        end

    else
        error('bdf_plot_patch_angles: Desteklenmeyen girdi tipi.');
    end

    % Isim-deger ciftlerini isle
    i = rest_start;
    while i <= numel(varargin)
        key = varargin{i};
        if ~ischar(key)
            i = i + 1; continue;
        end
        val = varargin{i+1};
        switch lower(key)
            case 'ply',      ply_idx        = val;
            case 'fig',      opts.fig_num   = val;
            case 'title',    opts.title_str = val;
            case 'cmap',     opts.cmap      = val;
            case 'clim',     opts.clim      = val;
            case 'showval',  opts.showval   = val;
            case 'fontsize', opts.fontsize  = val;
            otherwise
                warning('bdf_plot_patch_angles: Bilinmeyen opsiyon: %s', key);
        end
        i = i + 2;
    end
end
