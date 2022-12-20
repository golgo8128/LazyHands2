function [ mts, spectra_mzs, spectra_intsts ] = ...
    read_rsmspra_dat1_2(raw_rsmmsd)

    function [ oval ] = swapbc(ival, iswapflag)
    
        if iswapflag
            oval = swapbytes(ival);
        else
            oval = ival;
        end
    end

    ENDIAN_CHECK_VAL = 0x01020304;
    CHECK_VAL_OFFSET_FROM = sizeof('int32') + 1;
    CHECK_VAL_OFFSET_TO   = sizeof('int32') + 4;

    VARINFO_MT_IDX        = 9;
    VARINFO_MZ_IDX        = 10;
    VARINFO_INTST_IDX     = 11;
    VARINFO_RPOS_IDX      = 12;

    varinfo_mt = ...
      vartype_symb_info(char(typecast( ...
                raw_rsmmsd(VARINFO_MT_IDX), ...
                'int8')));
    varinfo_mz = ...
      vartype_symb_info(char(typecast( ...
                raw_rsmmsd(VARINFO_MZ_IDX), ...
                'int8')));
    varinfo_intst = ...
      vartype_symb_info(char(typecast( ...
                raw_rsmmsd(VARINFO_INTST_IDX), ...
                'int8')));
    varinfo_rpos = ...
      vartype_symb_info(char(typecast( ...
                raw_rsmmsd(VARINFO_RPOS_IDX), ...
                'int8')));
      
    mt_var_type     = varinfo_mt.var_type;
    pos_var_type    = varinfo_rpos.var_type;
    mz_var_type     = varinfo_mz.var_type;
    intst_var_type = varinfo_intst.var_type;

    rcheck_val = typecast( ...
        raw_rsmmsd(CHECK_VAL_OFFSET_FROM:CHECK_VAL_OFFSET_TO), ...
                   'int32');
    
    if rcheck_val == ENDIAN_CHECK_VAL
        swflag = 0;
    elseif swapbytes(rcheck_val) == ENDIAN_CHECK_VAL
        swflag = 1;
    else
        error('Binary data Endian check error : %s\n', irs2dm_file);
    end
    
    flex_preced_head_size = swapbc(typecast(raw_rsmmsd(1:4), 'int32'), swflag);
    
    rpos_spectra_head_start0 = flex_preced_head_size;
      % Caution: In R and MATLAB, index starts with 1, but rpos starts with 0.
      
    num_mspectra = ...
        swapbc(typecast( ...
           raw_rsmmsd((rpos_spectra_head_start0 + 1) ...
              :(rpos_spectra_head_start0 + sizeof('int32'))), 'int32'), ...
              swflag);
    
    rpos_mts_start0          = rpos_spectra_head_start0 + sizeof('int32');
    rpos_rpos_mzs_start0     = rpos_mts_start0 + num_mspectra * sizeof(mt_var_type); 
    rpos_mzs_sizes_start0    = rpos_rpos_mzs_start0 + num_mspectra * sizeof(pos_var_type); 
    rpos_rpos_intsts_start0  = rpos_mzs_sizes_start0+ num_mspectra * sizeof('int32'); 
    rpos_intsts_sizes_start0 = rpos_rpos_intsts_start0 + num_mspectra * sizeof(pos_var_type); 
    rpos_maindata_start0       = rpos_intsts_sizes_start0+ num_mspectra * sizeof('int32');
      
    mts = swapbc(typecast( ...
        raw_rsmmsd((rpos_mts_start0 + 1):(rpos_rpos_mzs_start0)), ...
            mt_var_type), swflag); 
    
    rposs_mzss = ...
       swapbc(typecast( ...
          raw_rsmmsd((rpos_rpos_mzs_start0 + 1):(rpos_mzs_sizes_start0)), ...
             pos_var_type), swflag);

    if rposs_mzss(1) ~= rpos_maindata_start0
       error("Spectra start relative position inconsistency (%d != %d)", ...
             rposs_mzss(1), rpos_maindata_start0);
    end

    
    mzss_sizes = ...
        swapbc(typecast( ...
           raw_rsmmsd((rpos_mzs_sizes_start0+ 1):(rpos_rpos_intsts_start0)), ...
              'int32'), swflag);
    
    
    rposs_intstss = ...
        swapbc(typecast( ...
           raw_rsmmsd((rpos_rpos_intsts_start0 + 1):(rpos_intsts_sizes_start0)), ...
              pos_var_type), swflag);
      
    intstss_sizes = ...
        swapbc(typecast( ...
           raw_rsmmsd((rpos_intsts_sizes_start0+ 1):(rpos_maindata_start0)), ...
              'int32'), swflag);  
    
    rpos_first_intsts_start0 = uint64(rposs_mzss(1)) + uint64(mzss_sizes(1));
    if rposs_intstss(1) ~= rpos_first_intsts_start0
        error("First intensity start relative position inconsistency (%d != %d)", ...
              rposs_intstss(1), rpos_first_intsts_start0);
    end

    if num_mspectra > 1
        rpos_2nd_spectra_start0 = uint64(rpos_first_intsts_start0) + uint64(intstss_sizes(1));
        if rposs_mzss(2) ~= rpos_2nd_spectra_start0
            error("2nd m/z's start relative position inconsistency (%d != %d)", ...
                  rposs_mzss(2), rpos_2nd_spectra_start0);
        end
    end

    % spectra_mzs_intsts = cell(num_mspectra, 2);
    spectra_mzs    = cell(num_mspectra, 1);
    spectra_intsts = cell(num_mspectra, 1);
    
    for i = 1:num_mspectra
    
        rpos_mzs = rposs_mzss(i);
        mzs_size = mzss_sizes(i);
        mzs = ...
           swapbc(typecast( ...
              raw_rsmmsd((uint64(rpos_mzs) + uint64(1)):(uint64(rpos_mzs) + uint64(mzs_size))), ...
                mz_var_type), swflag);
    
        rpos_intsts = rposs_intstss(i);
        intsts_size = intstss_sizes(i);
        intsts = ...
           swapbc(typecast( ...
              raw_rsmmsd((uint64(rpos_intsts) + uint64(1)):(uint64(rpos_intsts) + uint64(intsts_size))), ...
                 intst_var_type), swflag);

        % spectra_mzs_intsts{i, 1} = mzs;
        % spectra_mzs_intsts{i, 2} = intsts;
        spectra_mzs{i} = mzs;
        spectra_intsts{i} = intsts;
    
    end   
    
end
