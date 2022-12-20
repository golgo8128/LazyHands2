

irsmspra_simple_file = joinpath(getenv('RS_TMP_DIR'), ...
    'rs_MSpectra', '101-QCE-P-C-5_centroided_Agilent1_11.rsmspra');
    % 'testmspectrum_mini11.rsmspra');  

[ mspectra ] ...
    = read_rsmspra_file1_2(irsmspra_simple_file);
