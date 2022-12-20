
imhout_annotinfo_file = ...
    joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    'annotinfo_MHout_QCsample_101-QCE-P-C-5.tsv');

mhout_annotinfo_tbl = rsTable3('matrix');
mhout_annotinfo_tbl.read_file(imhout_annotinfo_file, ...
    'sel_collabels', ...
       {'m/z', 'MT', 'Intensity', 'Height', 'Area', 'S/N'});

ipeak_annot_file = ...
    joinpath(getenv("RS_PROJ_DIR"), 'MasterHands', 'Examples', ...
             'kiff_files1', 'QCsample_101-QCE-P-C-5_peakinfo1_11.tsv');

peak_annot_tbl = rsTable3('table');
peak_annot_tbl.read_file(ipeak_annot_file, ...
    'sep', '\t', ...
    'rowlabel_flag', false);
pk_annot_tbl = peak_annot_tbl.get_subtbl( ...
    peak_annot_tbl.rowlabels, ...
    {'Peak m/z', 'Peak MT start', 'Peak MT end', 'Peak MT top'});
pk_annot_tbl.set_rowlabels(transpose(peak_annot_tbl.get_colvec('Peak annotation')))
pk_annot_tbl.numerize()

%%

irsmspra_mhands_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5_11.rsmspra');  

prof_mhands = import_rsmspra_file1(irsmspra_mhands_file);

irsmspra_cntr_mhands_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5_centroided1_11.rsmspra');  

cntr_mhands = import_rsmspra_file1(irsmspra_cntr_mhands_file);

[ cntr_mhands_intsts_rsmat, cntr_mhands_closest_mzs_rsmat ] = ...
    cntr_mhands.get_ephes_rsmat(pk_annot_tbl.get_colvec('Peak m/z'));

irsmspra_cntr_agilent_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5_centroided_Agilent1_11.rsmspra');  

cntr_agilent = import_rsmspra_file1(irsmspra_cntr_agilent_file);

% [ cntr_agilent_intsts_rsmat, cntr_agilent_closest_mzs_rsmat ] = ...
%     cntr_agilent.get_ephes_rsmat(pk_annot_tbl.get_colvec('Peak m/z'));


iephemat_vis_rs2dm_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5_ephemat_eqintrval11.rs2dm');

ephemat_vis = read_rs2d_file1_2(iephemat_vis_rs2dm_file);
ephe_vis_rsmat = rsMat1(ephemat_vis.dat2d, ephemat_vis.range_l_m, ephemat_vis.range_l_n);

%%

noise_mt_range_bool = 2 <= ephemat_vis.range_l_n & ephemat_vis.range_l_n < 4;
noise_dat2d = double(ephemat_vis.dat2d( :, noise_mt_range_bool ));

dat2d_z = (double(ephemat_vis.dat2d) - mean(noise_dat2d, 2)) ./ std(noise_dat2d, 0, 2);

%%

% ephemat_curated_peaks_mz_idxs = discretize(pk_annot_tbl.get_colvec('Peak m/z'), ephemat.range_l_m); % 182.0504, range_l_m); % 
% ephemat_curated_peaks_mt_idxs = discretize(pk_annot_tbl.get_colvec('Peak MT top'), ephemat.range_l_n); % 13.8355, range_l_n); % 
[ ephemat_curated_peaks_mz_vals, ephemat_curated_peaks_mz_idxs ] = closest_values_in_sorted(double(ephemat_vis.range_l_m), ...
    pk_annot_tbl.get_colvec('Peak m/z')); % 182.0504, range_l_m); % 
[ ephemat_curated_peaks_mt_vals, ephemat_curated_peaks_mt_idxs ] = closest_values_in_sorted(double(ephemat_vis.range_l_n), ...
    pk_annot_tbl.get_colvec('Peak MT top')); % 13.8355, range_l_n); % 

valid_curated_peaks_idxs_bool = ~(isnan(ephemat_curated_peaks_mz_idxs) | isnan(ephemat_curated_peaks_mt_idxs));
metab_idxs = (1:length(valid_curated_peaks_idxs_bool));
valid_metab_idxs = metab_idxs(valid_curated_peaks_idxs_bool);

curated_peaks_zscores = ...
    arrayfun(@(tmpmzidx, tmpmtidx) dat2d_z(tmpmzidx, tmpmtidx), ...
        ephemat_curated_peaks_mz_idxs(valid_curated_peaks_idxs_bool), ...
        ephemat_curated_peaks_mt_idxs(valid_curated_peaks_idxs_bool));

curated_peaks_consec_signif = ...
    arrayfun(@(tmpmzidx, tmpmtidx) ephemat_ephe_consec_signif1(dat2d_z, tmpmzidx, tmpmtidx, 2.58), ...
        ephemat_curated_peaks_mz_idxs(valid_curated_peaks_idxs_bool), ...
        ephemat_curated_peaks_mt_idxs(valid_curated_peaks_idxs_bool));


curated_peaks_zscores_annot = ...
    horzcat(transpose(num2cell(valid_metab_idxs)), ...
            transpose(pk_annot_tbl.rowlabels(valid_curated_peaks_idxs_bool)), ...
            num2cell(curated_peaks_zscores), num2cell(curated_peaks_consec_signif));

disp(curated_peaks_zscores_annot);

%%
% Electropherogram of MasterHands and z-scores of closest idx values

metab_idx = 1; % Check 43
metab_annot = pk_annot_tbl.rowlabels{ metab_idx };
yyaxis left
cntr_mhands.plot_ephe(pk_annot_tbl.get_elem(metab_idx, 'Peak m/z'));
hold on;
scatter(pk_annot_tbl.get_elem(metab_annot, 'Peak MT top') , 0);
hold off;

% Z-score
yyaxis right
plot(ephemat_vis.range_l_n, ...
    dat2d_z(ephemat_curated_peaks_mz_idxs(metab_idx), :), 'red');


disp(curated_peaks_zscores_annot(metab_idx == valid_metab_idxs, :));

%%
% Electropherogram of MasterHands and closest values

metab_idx = 3;
metab_annot = pk_annot_tbl.rowlabels{ metab_idx };
metab_mz    = pk_annot_tbl.get_elem(metab_idx, 'Peak m/z');
cntr_mhands.plot_ephe(metab_mz);
hold on;
scatter(pk_annot_tbl.get_elem(metab_annot, 'Peak MT top') , 0);
hold on;
plot(ephemat_vis.range_l_n, ...
     ephemat_vis.dat2d(ephemat_curated_peaks_mz_idxs(metab_idx), :), 'p');

hold off;
disp(curated_peaks_zscores_annot(metab_idx == valid_metab_idxs, :));

figure;
target_mt_manual_estim = 10.09;
prof_mhands.plot_spectrum(target_mt_manual_estim);
hold on;
cntr_mhands.plot_spectrum(target_mt_manual_estim, 'o');
hold on;
cntr_agilent.plot_spectrum(target_mt_manual_estim, 'o');
hold on;
ephe_vis_rsmat.plot_colvec_by_colval(target_mt_manual_estim, 'p')
hold off;

legend('MH profile', 'MH targeted', 'Agilent targeted', "RS Closest");

%%

% image(range_l_m, range_l_n, log10(double(dat2d)+1), 'CDataMapping','scaled');
% image(range_l_n, range_l_m, log10(double(dat2d)), 'CDataMapping','scaled');

% dat2d_z(dat2d_z < 2.58) = 0;

image(ephemat_vis.range_l_n([1, end]), ephemat_vis.range_l_m([1,end]), dat2d_z, 'CDataMapping','scaled');
% ephemat.range_l_n and ephemat.range_l_m NOT accurately considered
% - they are located with identical intervals
% - see manual

% tmpd_focus = 30;
% 
% image(ephemat.range_l_n((1048-tmpd_focus):(1048 + tmpd_focus)), ... 
%     ephemat.range_l_m((12830 - tmpd_focus):(12830 + tmpd_focus)), ...
%     dat2d_z((12830 - tmpd_focus):(12830 + tmpd_focus), (1048-tmpd_focus):(1048 + tmpd_focus)), 'CDataMapping','scaled');

text(pk_annot_tbl.get_colvec('Peak MT top'), ...
    pk_annot_tbl.get_colvec('Peak m/z'), pk_annot_tbl.rowlabels)

set(gca,'YDir','normal');
caxis([0, 10]); % 1.96
colorbar;

%%




%%

% plot(range_l_m, log10(double(dat2d(:, 100))))
% surf(dat2d_z(5000:6000, 1200:1500))

dat2d_z_sel = dat2d_z(ephemat_vis.range_l_m > 50, 4 <=ephemat_vis.range_l_n & ephemat_vis.range_l_n < 25);
dat2d_z_noise = dat2d_z(ephemat_vis.range_l_m > 50, 2 <= ephemat_vis.range_l_n & ephemat_vis.range_l_n < 4);
% image(dat2d_z(range_l_m > 50 , range_l_n < 25))

sum(dat2d_z_sel > 6.00, [1, 2]) / sum(dat2d_z_sel > -inf, [1, 2]) % 1.96
sum(mat_dir_shift_sum_iter1(dat2d_z_sel > 6.00, 2^2 + 2^3, 1+10) > 0, [1, 2]) / sum(dat2d_z_sel > -inf, [1, 2]) % 1.96

