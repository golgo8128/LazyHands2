function [ rms ] ...
    = import_rsmspra_file1(irsmspra_file)

    [ mspectra ] ...
        = read_rsmspra_file1_2(irsmspra_file);
    rms = rsMassSpectra1(mspectra.mts, mspectra.mzss, mspectra.intstss);

end
