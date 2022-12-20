

% imzs   =  [ 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, ...
%             200, 210, 220, 230, 240, 250, 260, 270, 280, 290] * 100;
% iintsts = [   7,   8,   7,   8,  20,  40,  60,  20,   7,   9, ...
%               7,   8,   7,   8,  20,  60,  60,  20,   7,   9 ];
% scatter(omzs, ointsts);

%
% https://jp.mathworks.com/help/coder/gs/generating-c-code-from-matlab-code-at-the-command-line.html
% https://jp.mathworks.com/help/coder/ug/cpp-code-generation.html
% https://jp.mathworks.com/help/coder/ug/generate-and-modify-an-example-cc-main-function.html
% https://jp.mathworks.com/help/coder/ug/structure-of-example-cc-main-function.html

% Test with:
% codegen scan_spectrum_gauss_fit1_4 -args { coder.typeof(1,[ 1 Inf ]), coder.typeof(1,[ 1 Inf ]) } -test scan_spectrum_gauss_fit1_4_test1

% Generate C++ code with:
% codegen scan_spectrum_gauss_fit1_4 -args { coder.typeof(1,[ 1 Inf ]), coder.typeof(1,[ 1 Inf ]) } -lang:c++ -config:lib -report -package 'scan_spectrum_gauss_fit1_4_Pack1'
% (For old compiler, add -std:c++03)


function [ omzs, ointsts, dat_length, not_peak_top_flag ] ...
    = scan_spectrum_gauss_fit1_4(imzs, iintsts) %#codegen

    fragm_len = 4;
    ii = 1;
    oi = 1;
    omzs = nan(1, length(imzs)*2); % Enough size of output array
    ointsts = nan(1, length(imzs)*2); % Enough size of output array
    
    not_peak_top_flag = 0;

    while ii <= (length(imzs) - fragm_len + 1)
    
        if iintsts(ii) < iintsts(ii + 1) && iintsts(ii + 2) > iintsts(ii + 3) ...
                && all(iintsts(ii:(ii+fragm_len-1)) > 0) % No zero's allowed
            [ ~, center_x, extrem_y, omzs_fragm, ointsts_fragm, ~, ~, ~ ] = ...
                simple_Gaussian_fit_insert_peaktop1_3( ...
                    imzs(ii:(ii+fragm_len-1)), ...
                    iintsts(ii:(ii+fragm_len-1)));

            if extrem_y >= max(iintsts(ii:(ii+fragm_len - 1))) ...
                    && imzs(ii + 1) < center_x && center_x < imzs(ii + 2)
                % && imzs(ii + 0) < center_x && center_x < imzs(ii + 3)
                omzs(oi:(oi+length(omzs_fragm)-1)) = omzs_fragm;
                ointsts(oi:(oi+length(omzs_fragm)-1)) = ointsts_fragm;
                ii = ii + fragm_len;
                oi = oi + length(omzs_fragm);
                continue;
            else
                not_peak_top_flag = 1;
            end
        end
    
        omzs(oi) = imzs(ii);
        ointsts(oi) = iintsts(ii);
        oi = oi + 1;
        ii = ii + 1;
    
    end
    
    omzs(oi:(oi + length(imzs) - ii)) = imzs(ii:length(imzs));
    ointsts(oi:(oi + length(imzs) - ii)) = iintsts(ii:length(imzs));
    
    dat_length = oi + length(imzs) - ii;

end



