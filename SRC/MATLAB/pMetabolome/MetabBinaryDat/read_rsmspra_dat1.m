function [ mts, spectra_mzs, spectra_intsts ] = ...
    read_rsmspra_dat1(raw_rsmmsd, varargin)

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
    
    p = inputParser;
    addRequired(p,'raw_rsmmsd');
    addParameter(p, 'mt_var_type', 'single');
    addParameter(p, 'pos_var_type', 'int32');
    addParameter(p, 'mz_var_type', 'single');
    addParameter(p, 'intst_var_type', 'int32');
    parse(p, raw_rsmmsd, varargin{:})

    mt_var_type    = p.Results.mt_var_type;
    pos_var_type   = p.Results.pos_var_type;
    mz_var_type    = p.Results.mz_var_type;
    intst_var_type = p.Results.intst_var_type;

    % irs2dm_file = joinpath(getenv('RS_PROJ_DIR'), ...
    %     'MasterHands', 'Examples', 'kiff_files1', ...
    %     '101-QCE-P-C-5_centroided1_6.rsmspra');
    % irs2dm_file = joinpath(getenv('RS_TMP_DIR'), ...
    %     'rs_MSpectra', 'test3.rsmspra');
       
    % fh = fopen(irs2dm_file);
    % raw_rsmmsd = uint8(fread(fh, 'uint8'));
    % fclose(fh);
    
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
    
    rpos_spectra_info_start0 = flex_preced_head_size;
      % Caution: In R and MATLAB, index starts with 1, but rpos starts with 0.
      
    num_mspectra = ...
        swapbc(typecast( ...
           raw_rsmmsd((rpos_spectra_info_start0 + 1) ...
              :(rpos_spectra_info_start0 + sizeof('int32'))), 'int32'), ...
              swflag);
    
    rpos_mts_start0          = rpos_spectra_info_start0 + sizeof(pos_var_type);
    rpos_rpos_mzs_start0     = rpos_mts_start0 + num_mspectra * sizeof(mt_var_type); 
    rpos_mzs_sizes_start0    = rpos_rpos_mzs_start0 + num_mspectra * sizeof(pos_var_type); 
    rpos_rpos_intsts_start0  = rpos_mzs_sizes_start0+ num_mspectra * sizeof('int32'); 
    rpos_intsts_sizes_start0 = rpos_rpos_intsts_start0 + num_mspectra * sizeof(pos_var_type); 
    rpos_spectra_start0       = rpos_intsts_sizes_start0+ num_mspectra * sizeof('int32');
      
    mts = swapbc(typecast( ...
        raw_rsmmsd((rpos_mts_start0 + 1):(rpos_rpos_mzs_start0)), ...
            mt_var_type), swflag); 
    
    rposs_mzss = ...
       swapbc(typecast( ...
          raw_rsmmsd((rpos_rpos_mzs_start0 + 1):(rpos_mzs_sizes_start0)), ...
             pos_var_type), swflag);

    if rposs_mzss(1) ~= rpos_spectra_start0
       error("In file %s, spectra start relative position inconsistency (%d != %d)", ...
             rs_mspectra_data_file, rposs_mzss(1), rpos_spectra_start0);
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
           raw_rsmmsd((rpos_intsts_sizes_start0+ 1):(rpos_spectra_start0)), ...
              'int32'), swflag);  
    
    
    % spectra_mzs_intsts = cell(num_mspectra, 2);
    spectra_mzs    = cell(num_mspectra, 1);
    spectra_intsts = cell(num_mspectra, 1);
    
    for i = 1:num_mspectra
    
        rpos_mzs = rposs_mzss(i);
        mzs_size = mzss_sizes(i);
        mzs = ...
           swapbc(typecast( ...
              raw_rsmmsd((rpos_mzs + 1):(rpos_mzs + mzs_size)), ...
                mz_var_type), swflag);
    
        rpos_intsts = rposs_intstss(i);
        intsts_size = intstss_sizes(i);
        intsts = ...
           swapbc(typecast( ...
              raw_rsmmsd((rpos_intsts + 1):(rpos_intsts + intsts_size)), ...
                 intst_var_type), swflag);
    
        
        % spectra_mzs_intsts{i, 1} = mzs;
        % spectra_mzs_intsts{i, 2} = intsts;
        spectra_mzs{i} = mzs;
        spectra_intsts{i} = intsts;
    
    end   
    
end
