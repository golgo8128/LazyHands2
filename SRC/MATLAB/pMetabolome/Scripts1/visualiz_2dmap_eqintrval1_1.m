
ephemat_rs2dm_file = joinpath(getenv('RS_TMP_DIR'), ...
    'rs_MSpectra', ...
    'kiff_hybrid_ephemat1_1.rs2dm'); % 1_2
    % 'kiff_roi_mat1_1.rs2dm');
    % 'kiff_zscore_mat1_1.rs2dm');
    % 'kiff_zscore_smoothed_mat1_1.rs2dm');
    % 'kiff_hybrid_ephemat1_2.rs2dm');
    % '101-QCE-P-C-5_ephemat_eqintrval11.rs2dm');


ephemat_vis = read_rs2d_file1_2(ephemat_rs2dm_file);

image(ephemat_vis.range_l_n([1, end]), ephemat_vis.range_l_m([1,end]), ephemat_vis.dat2d, 'CDataMapping','scaled');

set(gca,'YDir','normal');
caxis([0, 1000]); % caxis([0, 10]); caxis([0, 1.96]);
colorbar;

ephemat_vis.dat2d(64.8866 <= ephemat_vis.range_l_m & ephemat_vis.range_l_m <= 65.2208, 7.22577 <= ephemat_vis.range_l_n & ephemat_vis.range_l_n <= 7.78357)

ephemat_vis.dat2d(65.0 <= ephemat_vis.range_l_m & ephemat_vis.range_l_m <= 65.1, 7.22577 <= ephemat_vis.range_l_n & ephemat_vis.range_l_n <= 7.78357)

%%


roimat_rs2dm_file = joinpath(getenv('RS_TMP_DIR'), ...
    'rs_MSpectra', ...
    'kiff_roi_mat1_1.rs2dm'); % 1_2.rs2dm
roimat_vis = read_rs2d_file1_2(roimat_rs2dm_file);
image(roimat_vis.range_l_n([1, end]), roimat_vis.range_l_m([1,end]), roimat_vis.dat2d, 'CDataMapping','scaled');

set(gca,'YDir','normal');
caxis([0, 1]); % caxis([0, 10]); caxis([0, 1.96]);
colorbar;

roimat_vis.dat2d(64.8866 <= roimat_vis.range_l_m & roimat_vis.range_l_m <= 65.2208, 7.22577 <= roimat_vis.range_l_n & roimat_vis.range_l_n <= 7.78357)

roimat_vis.dat2d(65.0 <= roimat_vis.range_l_m & roimat_vis.range_l_m <= 65.1, 7.22577 <= roimat_vis.range_l_n & roimat_vis.range_l_n <= 7.78357)