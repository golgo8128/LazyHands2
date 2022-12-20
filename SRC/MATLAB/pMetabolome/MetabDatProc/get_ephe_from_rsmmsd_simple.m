function [ intsts, closest_mzs ] = ...
    get_ephe_from_rsmmsd_simple(target_mz, spectra_mzs, spectra_intsts)

    [ closest_mzs, mzs_idxs ] = ...
        arrayfun(@(tmpx) closest_value_in_sorted(spectra_mzs{tmpx}, ...
                                                 target_mz), ...
            1:length(spectra_mzs));
    
    intsts = ...
        arrayfun(@(tmpx) spectra_intsts{tmpx}(mzs_idxs(tmpx)), ...
                 1:length(spectra_mzs));

end