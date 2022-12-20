
% iephe = [ 3, 2, 0, 1, 2, 3, 2, 1, 0, 0, 1, 2, 5, 2, 0, 1, 1, 3];
% ibase_thres = 2;
% imax_thres  = 5;

function [ oephe, num_signif_regions ] = ephe_consec_signif_regions1(iephe, ibase_thres, itop_thres)

    num_signif_regions = 0;

    oephe_signif_region_bool = zeros(1, length(iephe));
    csignif_idx_start = NaN; % or -1?
    top_val = -Inf;
    
    for i = 1:length(iephe)
        if iephe(i) >= ibase_thres
    
            if isnan(csignif_idx_start)
                csignif_idx_start = i;
            end
    
            if top_val < iephe(i)
                top_val = iephe(i);
            end
    
        else
    
            if ~isnan(csignif_idx_start)
                if top_val >= itop_thres
                    csignif_idx_end = i - 1;
                    oephe_signif_region_bool(csignif_idx_start:csignif_idx_end) = 1;
                    num_signif_regions = num_signif_regions + 1;
                end
                csignif_idx_start = NaN;
                top_val = -Inf;
            end
    
        end
    
    end
    
    if ~isnan(csignif_idx_start)
        if top_val >= itop_thres
            csignif_idx_end = i; % <---
            oephe_signif_region_bool(csignif_idx_start:csignif_idx_end) = 1;
            num_signif_regions = num_signif_regions + 1;
        end
    end

    oephe = iephe;
    oephe(~oephe_signif_region_bool) = 0;

end
