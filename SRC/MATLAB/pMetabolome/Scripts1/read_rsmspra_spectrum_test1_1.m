
irs2dm_prof_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5.rsmspra');
    % '101-QCE-P-C-5_centroided1_6.rsmspra');   

irs2dm_cntr_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5_centroided1_7.rsmspra');   

fh = fopen(irs2dm_prof_file);
raw_rsmmsd = uint8(fread(fh, 'uint8'));
fclose(fh);

fprintf("File %s read.\n", irs2dm_prof_file);

[ mts_prof, spectra_mzs_prof, spectra_intsts_prof ] = ...
    read_rsmspra_dat1(raw_rsmmsd);

fh = fopen(irs2dm_cntr_file);
raw_rsmmsd = uint8(fread(fh, 'uint8'));
fclose(fh);

fprintf("File %s read.\n", irs2dm_cntr_file);

[ mts_cntr, spectra_mzs_cntr, spectra_intsts_cntr ] = ...
    read_rsmspra_dat1(raw_rsmmsd);

clear('raw_rsmmsd');

peakinfo_file = ...
    joinpath(getenv('RS_PROJ_DIR'), ...
        'MasterHands', 'Examples', 'kiff_files1', ...
        'QCsample_101-QCE-P-C-5_peakinfo1_7.tsv');

peakinfo_tbl = rsTable3('matrix');
peakinfo_tbl.read_file(peakinfo_file, ...
    'rowlabel_flag', true);

%% 

metab_idx = 13;
metab_rowlabel = peakinfo_tbl.rowlabels{ metab_idx };
colnam_to_val_h = ...
    peakinfo_tbl.get_rowvec_hash(metab_rowlabel);
peak_MT_top = colnam_to_val_h("Peak MT top");
peak_mz     = colnam_to_val_h("Peak m/z");

[ peak_MT_top_cntr, peak_MT_cntr_idx ] = ...
    closest_value_in_sorted(mts_cntr, peak_MT_top);
[ peak_mz_top_cntr, peak_mz_cntr_idx ] = ...
    closest_value_in_sorted(spectra_mzs_cntr{ peak_MT_cntr_idx }, ...
                            peak_mz);
peak_intst_top_cntr = ...
    spectra_intsts_cntr{ peak_MT_cntr_idx }(peak_mz_cntr_idx);

[ peak_MT_top_prof, peak_MT_prof_idx ] = ...
    closest_value_in_sorted(mts_prof, peak_MT_top_cntr);
[ peak_mz_top_prof, peak_mz_prof_idx ] = ...
    closest_value_in_sorted(spectra_mzs_prof{ peak_MT_prof_idx }, ...
                            peak_mz);

prof_mz_range_lo_idx = max([1, peak_mz_prof_idx - 5 ]);
prof_mz_range_hi_idx = max([1, peak_mz_prof_idx + 5 ]);

plot(spectra_mzs_prof{ peak_MT_prof_idx }(prof_mz_range_lo_idx:prof_mz_range_hi_idx), ...
     spectra_intsts_prof{ peak_MT_prof_idx }(prof_mz_range_lo_idx:prof_mz_range_hi_idx));
hold on;
scatter(peak_mz_top_cntr, peak_intst_top_cntr);
hold off;

ephe_intsies = ...
    arrayfun(@(tmpidx) spectra_intsts_cntr{tmpidx}(metab_idx), ...
                1:length(mts_cntr));

figure;
plot(mts_cntr, ephe_intsies);


