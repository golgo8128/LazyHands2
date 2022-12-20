

irsmspra_cntr_mhands_file = joinpath(getenv('RS_PROJ_DIR'), ...
    'MasterHands', 'Examples', 'kiff_files1', ...
    '101-QCE-P-C-5_11.rsmspra');  

mhands_cntr = import_rsmspra_file1(irsmspra_cntr_mhands_file);

%% 

% mhands_cntr.plot_spectrum(10)
mhands_cntr.plot_ephe(50.9953)
% mhands_cntr.plot_ephe(116.069)
% mhands_cntr.plot_ephe(126.028) # T004	Taurine
