function result = modify_patch_bdf(bdf_input, elem_changes, options)
% MODIFY_PATCH_BDF  Nastran BDF dosyasindaki patch eleman laminasyon acilerini degistirir.
%
% KULLANIM:
%   result = modify_patch_bdf(bdf_input, elem_changes)
%   result = modify_patch_bdf(bdf_input, elem_changes, options)
%
% GIRDILER:
%   bdf_input    : string — kaynak BDF dosyasi tam yolu
%
%   elem_changes : struct dizisi — degistirilecek elemanlar
%                  .elem_id  (int)    : patch eleman numarasi (1-100)
%                  .angles   (double) : kat acilari vektoru [derece]
%                  Ornek:
%                    ec(1).elem_id = 5;  ec(1).angles = [45, -45, 0];
%                    ec(2).elem_id = 23; ec(2).angles = [0,  45, -45];
%
%   options      : struct — opsiyonel ayarlar (tum alanlari opsiyonel)
%                  .bdf_output  (string)  : cikti BDF yolu; bos=otomatik
%                  .mat_id      (int)     : malzeme karti ID    (varsayilan: 1)
%                  .ply_t       (double)  : ply kalinligi [mm]  (varsayilan: 0.131)
%                  .fail_flag   (string)  : SOUT alani          (varsayilan: 'YES')
%                  .verbose     (logical) : ekrana yazdir        (varsayilan: true)
%                  .verify      (logical) : cikti BDF dogrula    (varsayilan: true)
%
% CIKTI:
%   result : struct
%     .bdf_output   : string  — yazilan BDF tam yolu
%     .n_changed    : int     — degistirilen eleman sayisi
%     .n_lines_in   : int     — girdi BDF satir sayisi
%     .n_lines_out  : int     — cikti BDF satir sayisi
%     .verify_ok    : logical — dogrulama sonucu (options.verify=true ise)
%     .pmap         : struct  — tum patch elemanlarinin PCOMP haritasi
%
% ORNEK KULLANIM (dis scriptten):
%   ec(1).elem_id = 5;  ec(1).angles = [45, -45, 0];
%   ec(2).elem_id = 23; ec(2).angles = [0,  45, -45];
%   opts.bdf_output = 'model_v2.bdf';
%   opts.verbose    = true;
%   result = modify_patch_bdf('baseline.bdf', ec, opts);
%   if result.verify_ok
%       % Nastran'i calistir...
%   end
%
% BAGIMSIZ FONKSIYONLAR (ayri .m dosyalari):
%   bdf_read_lines       — BDF dosyasini satir hucre dizisi olarak okur
%   bdf_write_lines      — Satir hucre dizisini BDF olarak yazar
%   bdf_build_pcomp_map  — Patch PCOMP haritasini olusturur
%   bdf_apply_changes    — Laminasyon degisikliklerini uygular
%   bdf_verify           — Cikti BDF'i dogrular
%   bdf_build_pcomp_card — Nastran PCOMP karti satirlarini uretir

% =========================================================================

    %% --- Girdi dogrulamalari ---
    if nargin < 2 || isempty(elem_changes)
        error('modify_patch_bdf: elem_changes bos olamaz.');
    end
    if nargin < 3 || isempty(options)
        options = struct();
    end

    % Opsiyonlari coz (varsayilanlarla)
    cfg = parse_options(options, bdf_input);

    %% --- 1. BDF oku ---
    if cfg.verbose
        fprintf('\n[1/4] Okunuyor : %s\n', bdf_input);
    end
    lines = bdf_read_lines(bdf_input);
    if cfg.verbose
        fprintf('      %d satir okundu.\n', numel(lines));
    end

    %% --- 2. Patch PCOMP haritasi ---
    if cfg.verbose
        fprintf('[2/4] PCOMP konumlari haritaliyor...\n');
    end
    pmap = bdf_build_pcomp_map(lines);
    if cfg.verbose
        fprintf('      %d adet patch PCOMP haritalandi.\n', numel(fieldnames(pmap)));
    end

    %% --- 3. Degisiklikleri uygula ---
    if cfg.verbose
        fprintf('[3/4] Laminasyon acilari guncelleniyor...\n\n');
        fprintf('  %-6s  %-8s  %-20s  %s\n', 'Elem', 'PCOMP', 'Eski aciler', 'Yeni aciler');
        fprintf('  %s\n', repmat('-', 1, 60));
    end
    [lines_out, pmap, n_changed] = bdf_apply_changes(lines, pmap, elem_changes, cfg);

    %% --- 4. BDF yaz ---
    if cfg.verbose
        fprintf('\n[4/4] Yaziliyor : %s\n', cfg.bdf_output);
    end
    bdf_write_lines(lines_out, cfg.bdf_output);

    %% --- Ozet ---
    if cfg.verbose
        fprintf('\n====================================\n');
        fprintf(' TAMAMLANDI\n');
        fprintf('====================================\n');
        fprintf(' Girdi : %s\n', bdf_input);
        fprintf(' Cikti : %s\n', cfg.bdf_output);
        fprintf(' Satir : %d (delta: %+d)\n', numel(lines_out), numel(lines_out)-numel(lines));
        fprintf(' Degistirilen eleman: %d\n', n_changed);
    end

    %% --- Dogrulama ---
    verify_ok = true;
    if cfg.verify
        if cfg.verbose, fprintf('\n--- Dogrulama (cikti BDF) ---\n'); end
        verify_ok = bdf_verify(cfg.bdf_output, elem_changes, cfg.verbose);
        if cfg.verbose
            if verify_ok
                fprintf('  Tum aciler basariyla dogrulandi.\n');
            else
                fprintf('  DIKKAT: Bazi aciler eslesmiyor!\n');
            end
            fprintf('=====================================\n\n');
        end
    end

    %% --- Cikti struct ---
    result.bdf_output  = cfg.bdf_output;
    result.n_changed   = n_changed;
    result.n_lines_in  = numel(lines);
    result.n_lines_out = numel(lines_out);
    result.verify_ok   = verify_ok;
    result.pmap        = pmap;
end


%% =========================================================================
%  YARDIMCI: Opsiyon cozumleme
%% =========================================================================

function cfg = parse_options(options, bdf_input)
    % bdf_output
    if isfield(options, 'bdf_output') && ~isempty(options.bdf_output)
        cfg.bdf_output = options.bdf_output;
    else
        [d, n, e] = fileparts(bdf_input);
        cfg.bdf_output = fullfile(d, [n, '_modified', e]);
    end
    % Malzeme parametreleri
    cfg.mat_id    = get_opt(options, 'mat_id',    1);
    cfg.ply_t     = get_opt(options, 'ply_t',     0.131);
    cfg.fail_flag = get_opt(options, 'fail_flag', 'YES');
    % Davranis
    cfg.verbose   = get_opt(options, 'verbose',   true);
    cfg.verify    = get_opt(options, 'verify',    true);
end

function val = get_opt(options, field, default)
    if isfield(options, field)
        val = options.(field);
    else
        val = default;
    end
end
