
iannotlist_file = ...
    joinpath(getenv('RS_TRUNK_DIR'), ...
        'cWorks', 'Project', 'MetabolomeGeneral', ...
        'CE-MS', 'AnnotationList', 'C_114_annotlist_160809-2_RSC1.csv');
annotlist_tbl = rsTable3('table');
annotlist_tbl.read_file(iannotlist_file, ...
    'sep', ',(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))', ...
    'rowlabel_flag', false);

% irs2dm_file = joinpath(getenv('RS_PROJ_DIR'), ...
%     'MasterHands', 'Examples', 'kiff_files1', ...
%     '101-QCE-P-C-5.rsmspra');
    % '101-QCE-P-C-5_centroided1_6.rsmspra');

irs2dm_file = joinpath(getenv('RS_TMP_DIR'), ...
    'rs_MSpectra', '101-QCE-P-C-5_Agilent_ephe1.rsmspra');


% intst_var_type = 'int32';

% irs2dm_file = joinpath(getenv('RS_TMP_DIR'), ...
%    'rs_MSpectra', 'test3.rsmspra');
% intst_var_type = 'int64';

% fh = fopen(irs2dm_file);
% raw_rsmmsd = uint8(fread(fh, 'uint8'));
% fclose(fh);

% [ mts, spectra_mzs, spectra_intsts ] = ...
%     read_rsmspra_dat1(raw_rsmmsd, 'intst_var_type', intst_var_type);

[ mts, spectra_mzs, spectra_intsts ] = ...
    read_rsmspra_file1(irs2dm_file); % , 'intst_var_type', intst_var_type);

%% 

% [v, idx_l] = closest_value_in_sorted(spectra_mzs{1000}, 100)
 
% target_mz = 100;
% [ intsts, closest_mzs ] = ...
%     get_ephe_from_rsmmsd_simple(target_mz, spectra_mzs, spectra_intsts)

% [ closest_mzs, mzs_idxs ] = ...
%     arrayfun(@(tmpx) closest_value_in_sorted(spectra_mzs{tmpx}, ...
%                                              target_mz), ...
%         1:length(mts));
% 
% intsts = ...
%     arrayfun(@(tmpx) spectra_intsts{tmpx}(mzs_idxs(tmpx)), 1:length(mts));

%%

target_mzs = str2double(annotlist_tbl.get_colvec(4));
[ intsts_mat, closest_mzs_mat ] = ...
    get_ephes_from_rsmmsd_simple(target_mzs, spectra_mzs, spectra_intsts);

%%



