
iephemat_vis_rs2dm_file = joinpath(getenv('RS_TMP_DIR'), ... % getenv('RS_PROJ_DIR')
    'rs_MSpectra', 'kiff_ephemat1_1.rs2dm');
    % 'MasterHands', 'Examples', 'kiff_files1', ...
    % '101-QCE-P-C-5_ephemat11.rs2dm'); % '101-QCE-P-C-5_ephemat_eqintrval11.rs2dm');

ephemat_vis_obj = read_rs2d_file1_2(iephemat_vis_rs2dm_file, 'obj');

noise_mt_range_bool = 2 <= ephemat_vis_obj.colvals & ephemat_vis_obj.colvals <= 4;
noise_dat2d = double(ephemat_vis_obj.mat( :, noise_mt_range_bool ));

dat2d_z = (double(ephemat_vis_obj.mat) - mean(noise_dat2d, 2)) ./ std(noise_dat2d, 0, 2);
dat2d_z_smoothed = mat_dir_shift_sum1(dat2d_z, 2^0 + 2^1 + 2^2 + 2^3) / 4;

image(ephemat_vis_obj.colvals, ephemat_vis_obj.rowvals, dat2d_z_smoothed, 'CDataMapping','scaled');
set(gca,'YDir','normal');
caxis([0, 10]); % 1.96
colorbar;

dat2d_z_obj = rsMat1(dat2d_z, ephemat_vis_obj.rowvals, ephemat_vis_obj.colvals);
dat2d_z_smoothed_obj = rsMat1(dat2d_z_smoothed, ephemat_vis_obj.rowvals, ephemat_vis_obj.colvals);

ephemat_vis_obj.gen_sub_rsmat_bybool( ...
    65.0 <= ephemat_vis_obj.rowvals & ephemat_vis_obj.rowvals <= 65.1, ...
    7.22577 <= ephemat_vis_obj.colvals & ephemat_vis_obj.colvals <= 7.78357).display_mat();

dat2d_z_obj.gen_sub_rsmat_bybool( ...
    65.0 <= dat2d_z_obj.rowvals & dat2d_z_obj.rowvals <= 65.1, ...
    7.22577 <= dat2d_z_obj.colvals & dat2d_z_obj.colvals <= 7.78357).display_mat();

% dat2d_z_smoothed_obj.gen_sub_rsmat_bybool( ...
%     65.0 <= dat2d_z_smoothed_obj.rowvals & dat2d_z_smoothed_obj.rowvals <= 65.1, ...
%     7.22577 <= dat2d_z_smoothed_obj.colvals & dat2d_z_smoothed_obj.colvals <= 7.78357).display_mat();

% aves = mean(noise_dat2d, 2);
% aves(65.0 <= ephemat_vis_obj.rowvals & ephemat_vis_obj.rowvals <= 65.1)
% stds = std(noise_dat2d, 0, 2);
% stds(65.0 <= ephemat_vis_obj.rowvals & ephemat_vis_obj.rowvals <= 65.1)

%%

izsoremat_vis_rs2dm_file = joinpath(getenv('RS_TMP_DIR'), ... % getenv('RS_PROJ_DIR')
    'rs_MSpectra', 'kiff_zscore_smoothed_mat1_1.rs2dm'); % 'kiff_zscore_mat1_1.rs2dm'); % 'kiff_zscore_smoothed_mat1_1.rs2dm');
zscoremat_vis_obj = read_rs2d_file1_2(izsoremat_vis_rs2dm_file, 'obj');

image(zscoremat_vis_obj.colvals, zscoremat_vis_obj.rowvals, zscoremat_vis_obj.mat, 'CDataMapping','scaled');
set(gca,'YDir','normal');
caxis([0, 10]); % 1.96
colorbar;


zscoremat_vis_obj.gen_sub_rsmat_bybool(...
    56.9 <= zscoremat_vis_obj.rowvals & zscoremat_vis_obj.rowvals <= 57.1, ...
    5 <= zscoremat_vis_obj.colvals & zscoremat_vis_obj.colvals <= 7).display_mat();

% Compare zsoremat_vis_obj and dat2d_z_obj

%%


roimat_rs2dm_file = joinpath(getenv('RS_TMP_DIR'), ...
    'rs_MSpectra', ...
    'kiff_roi_mat1_1.rs2dm'); % 1_2.rs2dm
roimat_vis_obj = read_rs2d_file1_2(roimat_rs2dm_file, 'obj');

image(roimat_vis_obj.colvals, roimat_vis_obj.rowvals, roimat_vis_obj.mat, 'CDataMapping','scaled');
set(gca,'YDir','normal');
caxis([0, 1]); % caxis([0, 10]); caxis([0, 1.96]);
colorbar;

roimat_vis_obj.gen_sub_rsmat_bybool(...
    261.1 <= roimat_vis_obj.rowvals & roimat_vis_obj.rowvals <= 261.2, ...
    15 <= roimat_vis_obj.colvals & roimat_vis_obj.colvals <= 16).display_mat();

%%

hybrid_ephemat_vis_rs2dm_file = joinpath(getenv('RS_TMP_DIR'), ... % getenv('RS_PROJ_DIR')
    'rs_MSpectra', 'kiff_hybrid_ephemat_eq_intrvl_top1_2.rs2dm');
hybrid_ephemat_vis_obj = read_rs2d_file1_2(hybrid_ephemat_vis_rs2dm_file, 'obj');

image(hybrid_ephemat_vis_obj.colvals, hybrid_ephemat_vis_obj.rowvals, hybrid_ephemat_vis_obj.mat, 'CDataMapping','scaled');
set(gca,'YDir','normal');
caxis([0, 1000]); % 1.96
colorbar;


hybrid_ephemat_vis_obj.gen_sub_rsmat_bybool(...
    65.0 <= hybrid_ephemat_vis_obj.rowvals & hybrid_ephemat_vis_obj.rowvals <= 65.1, ...
    7.22577 <= hybrid_ephemat_vis_obj.colvals & hybrid_ephemat_vis_obj.colvals <= 7.78357).display_mat();


%%

hybrid_zscoremat_vis_rs2dm_file = joinpath(getenv('RS_TMP_DIR'), ... % getenv('RS_PROJ_DIR')
    'rs_MSpectra', 'kiff_hybrid_zscore_eqintrvl_mat1_1.rs2dm');
hybrid_zscoremat_vis_obj = read_rs2d_file1_2(hybrid_zscoremat_vis_rs2dm_file, 'obj');

image(hybrid_zscoremat_vis_obj.colvals, hybrid_zscoremat_vis_obj.rowvals, hybrid_zscoremat_vis_obj.mat, 'CDataMapping','scaled');
set(gca,'YDir','normal');
caxis([0, 10]); % 1.96
colorbar;


hybrid_zscoremat_vis_obj.gen_sub_rsmat_bybool(...
    65.0 <= hybrid_zscoremat_vis_obj.rowvals & hybrid_zscoremat_vis_obj.rowvals <= 65.1, ...
    7.22577 <= hybrid_zscoremat_vis_obj.colvals & hybrid_zscoremat_vis_obj.colvals <= 7.78357).display_mat();


%% Check by electropherogram

irsmspra_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5_11.rsmspra');
kiff_rms = import_rsmspra_file1(irsmspra_file);
kiff_rms.plot_ephe(152.9890);




