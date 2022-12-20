

imzs   =  [ 100, 110, 120, 130, 140, 150, 160, 170, 180, 190 ];
iintsts = [   7,   8,   7,   8,  20,  40,  60,  20,   7,   9 ];

fragm_len = 4;
ii = 1;
oi = 1;
omzs = nan(1, length(imzs)*2);
ointsts = nan(1, length(imzs)*2);

while ii <= (length(imzs) - fragm_len + 1)

    if iintsts(ii) < iintsts(ii + 1) && iintsts(ii + 2) > iintsts(ii + 3)
        disp(ii);

        [ coeff_a, center_x, extrem_y, flag, omzs_fragm, ointsts_fragm ] = ...
            simple_Gaussian_fit_insert_peaktop1_1( ...
                imzs(ii:(ii+fragm_len-1)), ...
                iintsts(ii:(ii+fragm_len-1)));
        omzs(ii:(ii+length(omzs_fragm)-1)) = omzs_fragm;
        ointsts(ii:(ii+length(omzs_fragm)-1)) = ointsts_fragm;
        ii = ii + fragm_len;
        oi = oi + length(omzs_fragm);
    else
        omzs(oi) = imzs(ii);
        ointsts(oi) = iintsts(oi);
        oi = oi + 1;
        ii = ii + 1;
    end

end

omzs(oi:(oi + length(imzs) - ii)) = imzs(ii:length(imzs));
ointsts(oi:(oi + length(imzs) - ii)) = iintsts(ii:length(imzs));

dat_length = oi + length(imzs) - ii;
