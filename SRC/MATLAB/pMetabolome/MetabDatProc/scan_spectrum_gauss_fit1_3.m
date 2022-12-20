

% imzs   =  [ 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, ...
%             200, 210, 220, 230, 240, 250, 260, 270, 280, 290] * 100;
% iintsts = [   7,   8,   7,   8,  20,  40,  60,  20,   7,   9, ...
%               7,   8,   7,   8,  20,  60,  60,  20,   7,   9 ];
% scatter(omzs, ointsts);

function [ omzs, ointsts, dat_length, lsqr_flag_f, not_peak_top_flag ] ...
    = scan_spectrum_gauss_fit1_3(imzs, iintsts) %#codegen

    fragm_len = 4;
    ii = 1;
    oi = 1;
    omzs = nan(1, length(imzs)*2);
    ointsts = nan(1, length(imzs)*2);
    
    lsqr_flag_f       = 0;
    not_peak_top_flag = 0;

    while ii <= (length(imzs) - fragm_len + 1)
    
        if iintsts(ii) < iintsts(ii + 1) && iintsts(ii + 2) > iintsts(ii + 3)
            [ ~, ~, extrem_y, lsqr_flag, omzs_fragm, ointsts_fragm, ~, ~, ~ ] = ...
                simple_Gaussian_fit_insert_peaktop1_2( ...
                    imzs(ii:(ii+fragm_len-1)), ...
                    iintsts(ii:(ii+fragm_len-1)));
            if lsqr_flag > 0
                lsqr_flag_f = lsqr_flag;
            end

            if extrem_y >= max(iintsts(ii:(ii+fragm_len - 1)))
                omzs(ii:(ii+length(omzs_fragm)-1)) = omzs_fragm;
                ointsts(ii:(ii+length(omzs_fragm)-1)) = ointsts_fragm;
                ii = ii + fragm_len;
                oi = oi + length(omzs_fragm);
                continue;
            else
                not_peak_top_flag = 1;
            end
        end
    
        omzs(oi) = imzs(ii);
        ointsts(oi) = iintsts(oi);
        oi = oi + 1;
        ii = ii + 1;
    
    end
    
    omzs(oi:(oi + length(imzs) - ii)) = imzs(ii:length(imzs));
    ointsts(oi:(oi + length(imzs) - ii)) = iintsts(ii:length(imzs));
    
    dat_length = oi + length(imzs) - ii;

end



