function [ scaled, centr, factr ] = scale_by_approx(iarr)

    factr = max(iarr) - min(iarr);
    centr = median(iarr);

    scaled = (iarr - centr) / factr;
    % iarr = scaled * factr + centr
    
end