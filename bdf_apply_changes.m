function [lines_out, pmap, n_changed] = bdf_apply_changes(lines, pmap, elem_changes, cfg)
% BDF_APPLY_CHANGES  PCOMP laminasyon degisikliklerini BDF satir dizisine uygular.
%
% KULLANIM:
%   [lines_out, pmap, n_changed] = bdf_apply_changes(lines, pmap, elem_changes, cfg)
%
% GIRDILER:
%   lines        : {Nx1 cell}  — bdf_read_lines() ciktisi
%   pmap         : struct      — bdf_build_pcomp_map() ciktisi
%   elem_changes : struct dizi — degistirilecek elemanlar (.elem_id, .angles)
%   cfg          : struct      — ayarlar (.mat_id, .ply_t, .fail_flag, .verbose)
%
% CIKTILAR:
%   lines_out : {Mx1 cell} — guncellenmus BDF satirlari
%   pmap      : struct     — guncellenmis satir indeksleriyle pmap
%   n_changed : int        — basariyla degistirilen eleman sayisi

    lines_out = lines;
    n_changed = 0;

    for ci = 1:numel(elem_changes)
        eid    = elem_changes(ci).elem_id;
        angles = elem_changes(ci).angles;
        key    = sprintf('e%d', eid);

        if ~isfield(pmap, key)
            warning('bdf_apply_changes: Eleman %d BDF icinde bulunamadi, atlaniyor.', eid);
            continue;
        end

        % pmap shift_map ile canli guncelleniyor — direkt kullan
        pl  = pmap.(key).pcomp_line;
        cls = pmap.(key).cont_lines;
        pid = pmap.(key).pcomp_id;

        % Mevcut acilari parse et (sadece log icin)
        old_ang  = bdf_parse_pcomp_angles(lines_out, pl, cls);

        % Yeni PCOMP karti satirlarini uret
        new_card = bdf_build_pcomp_card(pid, cfg.mat_id, cfg.ply_t, cfg.fail_flag, angles);

        n_old = 1 + numel(cls);       % header + continuation satirlari
        n_new = numel(new_card);
        delta = n_new - n_old;

        % Eski blogu sil, yerine yeni karti ekle
        all_del   = [pl, cls];
        before    = lines_out(1 : all_del(1)-1);
        after     = lines_out(all_del(end)+1 : end);
        lines_out = [before, new_card, after];

        % Diger elemanlarin satir indekslerini kaydir
        pmap = pmap_shift(pmap, key, all_del(1), delta);

        n_changed = n_changed + 1;

        if cfg.verbose
            fprintf('  %-6d  %-8d  %-20s  %s\n', ...
                eid, pid, bdf_fmt_angles(old_ang), bdf_fmt_angles(angles));
        end
    end
end


%% -------------------------------------------------------------------------
%  Yerel yardimci: satir indeksi kaydirici
%% -------------------------------------------------------------------------

function pmap = pmap_shift(pmap, skip_key, from_line, delta)
% PMAP_SHIFT  from_line'dan sonraki tum pmap girislerin satir numaralarini kaydirur.
% Degistirilen elemana ait giris (skip_key) atlanir.

    keys = fieldnames(pmap);
    for k = 1:numel(keys)
        if strcmp(keys{k}, skip_key), continue; end
        if pmap.(keys{k}).pcomp_line > from_line
            pmap.(keys{k}).pcomp_line = pmap.(keys{k}).pcomp_line + delta;
            pmap.(keys{k}).cont_lines = pmap.(keys{k}).cont_lines + delta;
        end
    end
end
