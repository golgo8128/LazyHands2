
% tmpephemat = [ 0,0,1,2,3,5,2,1,0,0; 0,3,3,5,3,5,2,1,0,0; 3,4,5,3,0,0,5,3,2,0 ]


function [ oephemat, num_signif_regions ] = ephemat_consec_signif_regions1(iephemat, ibase_thres, itop_thres)

    [ oephe_cells, num_signif_regions_cells ] = ...
        arrayfun(@(tmpi) ephe_consec_signif_regions1(iephemat(tmpi, :), ibase_thres, itop_thres), ...
            1:size(iephemat, 1), 'UniformOutput', false);

    oephemat = vertcat(oephe_cells{:});
    num_signif_regions = vertcat(num_signif_regions_cells{:});

end
