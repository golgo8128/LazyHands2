function [ mts, spectra_mzs, spectra_intsts ] ...
    = read_rsmspra_file1(irsmspra_file, varargin)
% Doc

    fh = fopen(irsmspra_file);
    raw_rsmmsd = uint8(fread(fh, 'uint8'));
    fclose(fh);

    fprintf('Read file %s.\n', irsmspra_file);

    [ mts, spectra_mzs, spectra_intsts ] = ...
        read_rsmspra_dat1(raw_rsmmsd, varargin{:});

    fprintf('Imported data from file %s.\n', irsmspra_file);

end