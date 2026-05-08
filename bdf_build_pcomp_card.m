function card = bdf_build_pcomp_card(pid, mat_id, ply_t, fail_flag, angles)
% BDF_BUILD_PCOMP_CARD  Nastran sabit-format PCOMP karti satirlarini uretir.
%
% KULLANIM:
%   card = bdf_build_pcomp_card(pid, mat_id, ply_t, fail_flag, angles)
%
% GIRDILER:
%   pid       : int    — PCOMP property ID
%   mat_id    : int    — malzeme karti ID (MAT8 vb.)
%   ply_t     : double — ply kalinligi [mm]
%   fail_flag : string — SOUT alani ('YES' veya 'NO')
%   angles    : double vektoru — kat acilari [derece], kat sayisi serbest
%
% CIKTI:
%   card : {1xN cell} — yazilmaya hazir satir stringleri
%          card{1}    = 'PCOMP   <PID>   '   (header)
%          card{2..N} = continuation satirlari
%
% FORMAT KURALLARI:
%   Nastran 8-karakter sabit format, max 80 karakter/satir.
%   1 continuation satiri = 8 bosluk + max 2 kat x 4 alan (MID T THETA SOUT)
%                         = 8 + 2*32 = 72 karakter (limit icinde)
%   3+ kat = birden fazla continuation satiri.

    % Header: "PCOMP   " (8 char) + PID (8 char)
    header = sprintf('PCOMP   %-8d', pid);
    card   = {header};

    k     = 1;
    n_ply = numel(angles);

    while k <= n_ply
        row = '        ';      % 8 bosluk (continuation marker, col 1-8)

        for col_slot = 1:2    % MAX 2 KAT/SATIR -> 72 char <= 80 char limiti
            if k > n_ply, break; end

            row = [row, ...   %#ok<AGROW>
                sprintf('%-8d', mat_id),           ...  % MID   (8 char)
                nastran_real(ply_t),                ...  % T     (8 char)
                nastran_real(angles(k)),            ...  % THETA (8 char)
                sprintf('%-8s', fail_flag)];             % SOUT  (8 char)
            k = k + 1;
        end

        card{end+1} = row;    %#ok<AGROW>
    end
end


%% -------------------------------------------------------------------------
%  Yerel yardimci: Nastran 8-karakter gercek sayi alani
%% -------------------------------------------------------------------------

function s = nastran_real(val)
% NASTRAN_REAL  Gercek sayiyi 8-karakterlik Nastran alanina sigstirir.
%   Ondalik yeterince kisaysa '%g', uzunsa '%.3f' kullanir.

    s_raw = num2str(val, '%g');
    if numel(s_raw) > 8
        s_raw = sprintf('%.3f', val);
    end
    s = sprintf('%-8s', s_raw);
end
