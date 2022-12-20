
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

irsmspra_cntr_mhands_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5_centroided1_11.rsmspra');  

% [ mts_cntr_mhands, spectra_mzs_cntr_mhands, spectra_intsts_cntr_mhands ] ...
mhands_cntr = read_rsmspra_file1_2(irsmspra_cntr_mhands_file);

[ cntr_mhands_intsts_mat, cntr_mhands_closest_mzs_mat ] = ...
    get_ephes_from_rsmmsd_simple(pk_annot_tbl.get_colvec('Peak m/z'), ...
        mhands_cntr);

%%

iephemat_rs2dm_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5_ephemat11.rs2dm');

ephemat = read_rs2d_file1_2(iephemat_rs2dm_file);

%%

noise_mt_range_bool = 2 <= ephemat.range_l_n & ephemat.range_l_n < 4;
noise_dat2d = double(ephemat.dat2d( :, noise_mt_range_bool ));

dat2d_z = (double(ephemat.dat2d) - mean(noise_dat2d, 2)) ./ std(noise_dat2d, 0, 2);

%%

curated_peaks_mz_idxs = discretize(pk_annot_tbl.get_colvec('Peak m/z'), ephemat.range_l_m); % 182.0504, range_l_m); % 
curated_peaks_mt_idxs = discretize(pk_annot_tbl.get_colvec('Peak MT top'), ephemat.range_l_n); % 13.8355, range_l_n); % 
valid_curated_peaks_idxs = ~(isnan(curated_peaks_mz_idxs) | isnan(curated_peaks_mt_idxs));

curated_peaks_zscores = ...
    arrayfun(@(tmpmzidx, tmpmtidx) dat2d_z(tmpmzidx, tmpmtidx), ...
        curated_peaks_mz_idxs(valid_curated_peaks_idxs), ...
        curated_peaks_mt_idxs(valid_curated_peaks_idxs));

curated_peaks_zscores_annot = ...
    horzcat(transpose(pk_annot_tbl.rowlabels(valid_curated_peaks_idxs)), ...
            num2cell(curated_peaks_zscores));

disp(curated_peaks_zscores_annot);

%%

metab_idx = 5;
metab_annot = pk_annot_tbl.rowlabels{ metab_idx };
yyaxis left
plot(mhands_cntr.mts, cntr_mhands_intsts_mat(metab_idx,:));
hold on;
scatter(pk_annot_tbl.get_elem(metab_annot, 'Peak MT top') , 0);
hold off;
yyaxis right
plot(ephemat.range_l_n, dat2d_z(curated_peaks_mz_idxs(metab_idx), :), 'red');

disp(curated_peaks_zscores_annot(metab_idx, :));

%%

% image(range_l_m, range_l_n, log10(double(dat2d)+1), 'CDataMapping','scaled');
% image(range_l_n, range_l_m, log10(double(dat2d)), 'CDataMapping','scaled');
image(ephemat.range_l_n, ephemat.range_l_m, dat2d_z, 'CDataMapping','scaled');
set(gca,'YDir','normal');
caxis([0, 1.96]);
colorbar;

%%

% plot(range_l_m, log10(double(dat2d(:, 100))))
% surf(dat2d_z(5000:6000, 1200:1500))

dat2d_z_sel = dat2d_z(ephemat.range_l_m > 50, 4 <=ephemat.range_l_n & ephemat.range_l_n < 25);
dat2d_z_noise = dat2d_z(ephemat.range_l_m > 50, 2 <= ephemat.range_l_n & ephemat.range_l_n < 4);
% image(dat2d_z(range_l_m > 50 , range_l_n < 25))

sum(dat2d_z_sel > 1.96, [1, 2]) / sum(dat2d_z_sel > -inf, [1, 2])
% sum(mat_dir_shift_sum1(dat2d_z_sel > 1.96, 2^2 + 2^3) > 0, [1, 2]) / sum(dat2d_z_sel > -inf, [1, 2])
