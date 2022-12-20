
icentroid_rsmspra_file = joinpath(getenv('RS_TMP_DIR'), ...
    'rs_MSpectra', '101-QCE-P-C-5_Agilent_ephe1.rsmspra');


fh = fopen(icentroid_rsmspra_file);
raw_rsmmsd = uint8(fread(fh, 'uint8'));
fclose(fh);


[ mts, spectra_mzs, spectra_intsts ] = ...
    read_rsmspra_dat1(raw_rsmmsd, 'mt_var_type', 'double', ...
        'mz_var_type', 'double', ...
        'intst_var_type', 'single');

