
function num_consec = ephemat_ephe_consec_signif1(iephemat, imz_idx, imt_idx, ithres)

    num_consec = 0;
    if iephemat(imz_idx, imt_idx) >= ithres
        
        num_consec = 1;

        cmt_idx = imt_idx - 1;
        while cmt_idx > 0
            if iephemat(imz_idx, cmt_idx) >= ithres
                num_consec = num_consec + 1;
                cmt_idx = cmt_idx - 1;
            else
                break
            end
        end

        cmt_idx = imt_idx + 1;
        while cmt_idx <= size(iephemat, 2)
            if iephemat(imz_idx, cmt_idx) >= ithres
                num_consec = num_consec + 1;
                cmt_idx = cmt_idx + 1;
            else
                break
            end
        end

    end

end

% tmpmat1 = [ 0,0,0,0,0,0,0,0,0,0;2,0,0,2,2,2,2,2,0,2;0,0,0,0,0,0,0,0,0,0 ]
