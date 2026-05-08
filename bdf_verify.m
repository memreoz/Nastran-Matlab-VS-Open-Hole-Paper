function ok = bdf_verify(bdf_output, elem_changes, verbose)
% BDF_VERIFY  Yazilan BDF dosyasindaki PCOMP acilerini dogrular.
%
% KULLANIM:
%   ok = bdf_verify('output.bdf', elem_changes, true)
%
% GIRDILER:
%   bdf_output   : string      — kontrol edilecek BDF dosya yolu
%   elem_changes : struct dizi — beklenen degisiklikler (.elem_id, .angles)
%   verbose      : logical     — sonuclari ekrana yazdir
%
% CIKTI:
%   ok : logical — tum aciler dogru ise true, herhangi biri yanlissa false

    if nargin < 3, verbose = true; end

    % Cikti BDF'i oku
    v_lines = bdf_read_lines(bdf_output);

    % PCOMP haritasini yeniden olustur
    v_pmap = bdf_build_pcomp_map(v_lines);

    ok = true;

    for ci = 1:numel(elem_changes)
        eid     = elem_changes(ci).elem_id;
        exp_ang = elem_changes(ci).angles;
        vkey    = sprintf('e%d', eid);

        if ~isfield(v_pmap, vkey)
            if verbose
                fprintf('  [HATA] Elem %d cikti BDF''de bulunamadi!\n', eid);
            end
            ok = false;
            continue;
        end

        got_ang = bdf_parse_pcomp_angles( ...
            v_lines, ...
            v_pmap.(vkey).pcomp_line, ...
            v_pmap.(vkey).cont_lines);

        % Kayan nokta karsilastirmasi (toleransli)
        match = (numel(exp_ang) == numel(got_ang)) && ...
                all(abs(exp_ang(:) - got_ang(:)) < 1e-6);

        if match
            if verbose
                fprintf('  [OK]   Elem %-3d -> [%s]\n', eid, bdf_fmt_angles(got_ang));
            end
        else
            if verbose
                fprintf('  [HATA] Elem %-3d: beklenen [%s], bulunan [%s]\n', ...
                    eid, bdf_fmt_angles(exp_ang), bdf_fmt_angles(got_ang));
            end
            ok = false;
        end
    end
end
