function [ mspectra ] ...
    = read_rsmspra_file1_2(irsmspra_file)
% Doc

    fh = fopen(irsmspra_file);
    raw_rsmmsd = uint8(fread(fh, 'uint8'));
    fclose(fh);

    fprintf('Read file %s.\n', irsmspra_file);

    [ mts, spectra_mzs, spectra_intsts ] = ...
        read_rsmspra_dat1_2(raw_rsmmsd);

    fprintf('Imported data from file %s.\n', irsmspra_file);

    mspectra.mts = mts;
    mspectra.mzss = spectra_mzs;
    mspectra.intstss = spectra_intsts;

% All elements will have the same dimension ??
%     mspectra = struct( ...
%         'mts', { mts }, ...
%         'spectra_mzs', spectra_mzs, ...
%         'spectra_intsts', spectra_intsts);

end