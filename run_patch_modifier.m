%% =========================================================================
%  run_patch_modifier.m
%  =========================================================================
%  modify_patch_bdf() fonksiyonunun ornek kullanim scripti.
%  Burasi dis bir koddan cagrilabilecek tipik bir driver'dir.
%
%  DOSYA YAPISI (tum .m dosyalari ayni klasorde olmali):
%    modify_patch_bdf.m          <- Ana API fonksiyonu
%    bdf_read_lines.m
%    bdf_write_lines.m
%    bdf_build_pcomp_map.m
%    bdf_apply_changes.m
%    bdf_build_pcomp_card.m
%    bdf_parse_pcomp_angles.m
%    bdf_fmt_angles.m
%    bdf_verify.m
%    run_patch_modifier.m        <- Bu script (ornek driver)
% =========================================================================

clc; clear; close all;

%% ===== YOLLAR ===========================================================

BASE_DIR  = 'D:\Document\VSCL\ANALYSIS\NASTRAN_MATLAB_VS_PRJ';
BDF_IN    = fullfile(BASE_DIR, 'OHC_VS_PATCH_SET_MATLAB.bdf');
BDF_OUT   = fullfile(BASE_DIR, 'modified_v1.bdf');

%% ===== DEGISTIRILECEK ELEMANLAR =========================================
% elem_id : patch eleman numarasi (1-100)
% angles  : kat acilari [derece], kat sayisi serbest

ec = struct('elem_id', {}, 'angles', {});

ec(end+1).elem_id = 45;   ec(end).angles = [90,  -45,  0  ];
ec(end+1).elem_id = 46;  ec(end).angles = [0,    45, -45  ];
ec(end+1).elem_id = 47;  ec(end).angles = [55,  -30,  90  ];
ec(end+1).elem_id = 48;  ec(end).angles = [90,  -9,  90  ];
ec(end+1).elem_id = 93;  ec(end).angles = [30,  -30,  90  ];
ec(end+1).elem_id = 94;  ec(end).angles = [30,  -30,  90  ];
ec(end+1).elem_id = 95;  ec(end).angles = [30,  -8,  0  ];
ec(end+1).elem_id = 96;  ec(end).angles = [30,  -6,  90  ];
%% ===== OPSIYONLAR =======================================================

opts.bdf_output = BDF_OUT;
opts.mat_id     = 1;
opts.ply_t      = 0.131;
opts.fail_flag  = 'YES';
opts.verbose    = true;
opts.verify     = true;

%% ===== CALISTIR =========================================================

result = modify_patch_bdf(BDF_IN, ec, opts);

%% ===== SONUCLARI KULLAN =================================================

fprintf('Cikti BDF : %s\n', result.bdf_output);
fprintf('Dogrulama : %s\n', ternary(result.verify_ok, 'GECTI', 'HATA VAR'));
fprintf('Satir delta: %+d\n', result.n_lines_out - result.n_lines_in);

% Herhangi bir elemana ait guncel PCOMP bilgisini sorgulamak icin:
elem_id = 5;
key = sprintf('e%d', elem_id);
if isfield(result.pmap, key)
    fprintf('\nElem %d: PCOMP ID = %d\n', elem_id, result.pmap.(key).pcomp_id);
end

% Sonraki adim: Nastran calistirma (isteğe bagli)
% if result.verify_ok
%     nastran_cmd = sprintf('nastran %s', result.bdf_output);
%     system(nastran_cmd);
% end


%% =========================================================================
%  PARAMETRIK TARAMA ORNEGI
%  Bir elemani farkli acilarla tarat, her seferinde BDF olustur.
% =========================================================================
% 
% sweep_angles = -90 : 15 : 90;
% for k = 1:numel(sweep_angles)
%     ec_sw(1).elem_id = 50;
%     ec_sw(1).angles  = [sweep_angles(k), -sweep_angles(k), 0];
%
%     opts_sw.bdf_output = fullfile(BASE_DIR, sprintf('sweep_%03d.bdf', k));
%     opts_sw.verbose    = false;
%     opts_sw.verify     = false;
%
%     modify_patch_bdf(BDF_IN, ec_sw, opts_sw);
%     fprintf('Sweep %2d/%2d: theta=%+4d -> %s\n', ...
%         k, numel(sweep_angles), sweep_angles(k), opts_sw.bdf_output);
% end


%% =========================================================================
%  TUMU DEGISTIRME ORNEGI
%  100 patch elemana farkli fonksiyon tabanli aci ata.
% =========================================================================
%
% ec_all = struct('elem_id',{}, 'angles',{});
% for eid = 1:100
%     theta = round(45 * sind(eid * 3.6));   % ornek: sinusoidal dagilim
%     ec_all(end+1).elem_id = eid;
%     ec_all(end).angles    = [theta, -theta, 0];
% end
%
% opts_all.bdf_output = fullfile(BASE_DIR, 'OHC_VAT_sinusoidal.bdf');
% opts_all.verbose    = false;
% result_all = modify_patch_bdf(BDF_IN, ec_all, opts_all);
% fprintf('VAT BDF olusturuldu: %s\n', result_all.bdf_output);


%% =========================================================================
%  YEREL YARDIMCI
%% =========================================================================

function s = ternary(cond, a, b)
    if cond, s = a; else, s = b; end
end
