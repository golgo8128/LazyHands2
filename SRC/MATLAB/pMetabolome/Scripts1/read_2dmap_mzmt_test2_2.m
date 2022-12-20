
ephemat_rs2dm_file = joinpath(getenv("RS_TMP_DIR"), 'rs_MSpectra', ...
    '101-QCE-P-C-5_2d_featmap_mzmt1.rs2dm');
[ ephemat_rs2d ] = ...
    read_rs2d_file1_2(ephemat_rs2dm_file);

image(ephemat_rs2d.range_l_n([1, end]), ephemat_rs2d.range_l_m([1,end]), ephemat_rs2d.dat2d, 'CDataMapping','scaled');
% ephemat.range_l_n and ephemat.range_l_m NOT accurately considered

set(gca,'YDir','normal');
caxis([0, 1000]); % 1.96
colorbar;

%%

figure;

ephemat_roi_rs2dm_file = joinpath(getenv("RS_TMP_DIR"), 'rs_MSpectra', ...
    '101-QCE-P-C-5_roi_2d_featmap_mzmt1.rs2dm');
[ ephemat_roi_rs2d ] = ...
    read_rs2d_file1_2(ephemat_roi_rs2dm_file);

image(ephemat_roi_rs2d.range_l_n([1, end]), ephemat_roi_rs2d.range_l_m([1,end]), ephemat_roi_rs2d.dat2d, 'CDataMapping','scaled');
% ephemat.range_l_n and ephemat.range_l_m NOT accurately considered

set(gca,'YDir','normal');
caxis([0, 1000]); % 1.96
colorbar;
