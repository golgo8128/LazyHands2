
# For unit test, rsunit_test_MetabBatchSimple <- T and source it.

source.RS("FilePath/path_str_proc1.R")
# source.RS("MetabDatAnalyses/TreatPeaks/PeakGrps1_1.R")
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")


MetabBatchSimple <-
  setRefClass("MetabBatchSimple",
    fields = list(
        sample_metab_meas_list = "list",
        ref                    = "ANY", # Intended for SampleMetabMeasure
        # peak_grps              = "PeakGrps",
        ref_annotlist          = "AnnotList",
        refsamppairset         = "ANY", # Intended as RefSamplePairSet
        xcms_MSnbase           = "ANY", # Be careful about the sample order;
        xcms_XCMSnExp          = "ANY", # Reference will be the first sample.
        xcms_XCMSnExp_aligned  = "ANY"
      )) # "ANY" as generic class name?


MetabBatchSimple$methods(initialize =
    function(iannotlist = NULL){

      if(!is.null(iannotlist)){
        .self$ref_annotlist <- iannotlist
      }
            
    })


MetabBatchSimple$methods(set_to_ref =
      function(iref){

        .self$ref <- iref
        
        hits <-
          sapply(.self$sample_metab_meas_list,
                 function(tmpsmm){ identical(iref, tmpsmm) })
        if(any(hits)){
          .self$sample_metab_meas_list[[ which(hits) ]] <- NULL
        }
        
        # if(nrow(.self$ref_annotlist$annotlist_dfrm) == 0){
        #  .self$ref_annotlist <- iref$annotlist
        # } else if(nrow(iref$annotlist$annotlist_dfrm) == 0){
        iref$annotlist <- .self$ref_annotlist
        # }
        
        .self$gen_refsamppairset()
        
    })


MetabBatchSimple$methods(import_from_mzml_files =
    function(imzML_files){

      target_mz_range_mat <- .self$ref_annotlist$get_mz_range_dfrm()
      
      xcms_rawdat_obj <-
        readMSData(imzML_files, mode = "onDisk")
      chromats_extracted <-
        chromatogram(xcms_rawdat_obj, mz = target_mz_range_mat)
      
      if(nrow(target_mz_range_mat) != nrow(chromats_extracted)){
        stop("[ ERROR ] Missing electropherograms from xcms")
        # Will this ever happen?
      }
      
      .self$xcms_MSnbase <- xcms_rawdat_obj
      
      for(sample_idx in 1:ncol(chromats_extracted)){
        
        smm <-
          SampleMetabMeasure(
            idatfilnam = fileNames(xcms_rawdat_obj)[ sample_idx ],
            isamplenam = filename_wo_ext(basename(fileNames(xcms_rawdat_obj))[ sample_idx ]))
        
        for(chromat_idx in 1:nrow(chromats_extracted)){
          chromat <- chromats_extracted[ chromat_idx, sample_idx ]
          
          migtimes <- rtime(chromat)
          intsties <- intensity(chromat)
          ephe_mat <- cbind(migtimes, intsties)
          
          # if(any(is.na(migtimes))){
          #   stop("NA in MTs")
          # }
          
          # if(any(is.na(intsties))){
          #   stop("NA in intensities")
          # }
          
          ephe_mat <- ephe_mat[ !is.na(intsties), ]
          
          ephe <- EPherogram(ephe_mat)
          ephe$set_mz(.self$ref_annotlist$annotlist_dfrm[ chromat_idx, "m/z" ])
          smm$add_ephe(ephe) 
          
          print(.self$ref_annotlist$annotlist_dfrm[ chromat_idx, ])
          
        }
        
        .self$add_sample(smm)
        
      }
      
    })



MetabBatchSimple$methods(
  find_bulk_peaks_all_ephe =
    function(){
    
      for(csmm in .self$sample_metab_meas_list){
        csmm$find_bulk_peaks_all_ephe()
      }
        
    })


MetabBatchSimple$methods(
  find_IS_marks =
    function(){
      
      for(csmm in .self$sample_metab_meas_list){
        csmm$find_IS_marks(.self$ref_annotlist)
      }
      
    })


MetabBatchSimple$methods(add_sample =
    function(isample_metab_meas){
      isample_metab_meas$set_batch(.self)
      .self$sample_metab_meas_list <-
        c(.self$sample_metab_meas_list, isample_metab_meas)
    })


MetabBatchSimple$methods(gather_annot_mt =
  function(){

    odfrm <- .self$ref$annotlist$annotlist_dfrm[, "MT", drop=F]
    colnames(odfrm) <- .self$ref$samplenam
    for(csmm in .self$sample_metab_meas_list){
      cdfrm <- csmm$annotlist$annotlist_dfrm[, "MT", drop=F]
      colnames(cdfrm) <- csmm$samplenam
      odfrm <- merge(odfrm, cdfrm, by = "row.names", all = T)
      rownames(odfrm) <- odfrm[, "Row.names"]
      odfrm <- odfrm[, colnames(odfrm) != "Row.names"]  
    }
    
    return(odfrm)
    
  })


MetabBatchSimple$methods(gen_refsamppairset =
  function(){
    
    source.RS("MetabDatAnalyses/TreatPeaks/RefSampPairSet1_2.R")
    
    pairset <- RefSampPairSet(.self)
    pairset$add_ref(.self$ref)
    
    for(csmm in .self$sample_metab_meas_list){
      pairset$add_smp(csmm)
    }

    .self$refsamppairset <- pairset
    
    return(pairset)
    
  })


MetabBatchSimple$methods(gen_Reijenga =
  function(){
                             
    .self$refsamppairset$gen_Reijenga()
    
  })

MetabBatchSimple$methods(annotate_landmarks =
  function(){
    
    for(cpair in .self$refsamppairset$refsmp_pairs_l){
      cpair$annotate_landmarks()
    }
    
  })


MetabBatchSimple$methods(set_xcms_peakgrp_info =
  function(){

    xcms_chromPeaks_all_mat <- NULL
    metabids_all <- NULL
    smmsall <- c(list(.self$ref), .self$sample_metab_meas_list)
    for(i in 1:length(smmsall)){
      
      csmm <- smmsall[[ i ]]
      xcms_chromPeak_single <-
        csmm$xcms_chromPeaks(i)
      
      xcms_chromPeaks_all_mat <-
        rbind(xcms_chromPeaks_all_mat,
              xcms_chromPeak_single$mat)
      metabids_all <- c(metabids_all,
                        xcms_chromPeak_single$metabids)
      # print(xcms_chromPeak_single$metabids)
      
    }
    
    metabid_to_peaks <-
      split(1:nrow(xcms_chromPeaks_all_mat),
            metabids_all)
    
    peakgrps <- list()
    for(metabid in names(metabid_to_peaks)){
      if(nchar(metabid) && length(metabid_to_peaks[[ metabid ]]) >= 2){
        peakgrps <-
          c(peakgrps, list(metabid_to_peaks[[ metabid ]]))
      }
    }
    
    peakgrp_mat <- matrix(nrow = length(peakgrps), ncol = 10)
    colnames(peakgrp_mat) <-
      c("mzmed", "mzmin", "mzmax", "rtmed",
        "rtmin", "rtmax",
        "npeaks", "X1", "peakidx", "ms_level")
    peakgrp_mat[, "ms_level" ] <- 1
    peakgrp_fd <- as.data.frame(peakgrp_mat)
    peakgrp_fd$peakidx <- peakgrps
    # peakgrp_fd$ms_level <- 1
    
    
    xcms_data_with_peaks <- as(.self$xcms_MSnbase, "XCMSnExp")
    # findChromPeaks(.self$h$raw_data,
    #                CentWaveParam(peakwidth = c(20, 80), snthresh = 10))
    # This was necessary to get "XCMSnExp" class
    chromPeaks(xcms_data_with_peaks) <- xcms_chromPeaks_all_mat
    featureDefinitions(xcms_data_with_peaks) <- DataFrame(peakgrp_fd)    
    
    .self$xcms_XCMSnExp <- xcms_data_with_peaks
    return(xcms_data_with_peaks)
    
  })
    

MetabBatchSimple$methods(align_xcms =
  function(ipkgrpp){
    
    .self$set_xcms_peakgrp_info()
    
    .self$xcms_XCMSnExp_aligned <-
      adjustRtime(.self$xcms_XCMSnExp, ipkgrpp)
    
    .self$refsamppairset$calc_adjust_mt_pairs_xcms()
    # self$refsamppairset has object .self (MetabBatchSimple) in its field.
    
    
  })


MetabBatchSimple$methods(find_bulk_peaks_all_samples =
  function(...){

    for(msample in .self$sample_metab_meas_list){
     
      msample$find_bulk_peaks_all_ephe(...)
       
    }
    
  })


if(exists("rsunit_test_MetabBatchSimple") &&
   rsunit_test_MetabBatchSimple){

  source.RS("MetabDatAnalyses/TreatPeaks/Epherogram1_2.R")
  source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")

  tmp_batch <- MetabBatchSimple()
  
  tmp_intsty1 <-
    c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
      2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
      3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
      4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
      0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
      2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
      3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
      3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1)
  
  tmp_mt1 <- 1:length(tmp_intsty1) / 2
  tmp_ephe_mat1 <- cbind(tmp_mt1, tmp_intsty1)
  tmp_ephe1 <- EPherogram(tmp_ephe_mat1, 70.63)
  
  tmp_intsty2 <-
    c(rep(c(0,1,2,1,2,1,0,1,1,1), 70),
      c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
        4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
        0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
        3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1))
  
  tmp_mt2 <- 1:length(tmp_intsty2) / 2
  tmp_ephe_mat2 <- cbind(tmp_mt2, tmp_intsty2)
  tmp_ephe2 <- EPherogram(tmp_ephe_mat2, 76.87)
  
  tmp_smm1 <- SampleMetabMeasure("Hypothetical sample file 1")
  tmp_smm1$add_ephe(tmp_ephe1)
  tmp_smm1$add_ephe(tmp_ephe2)
  tmp_batch$add_sample(tmp_smm1)

  tmp_smm2 <- SampleMetabMeasure("Hypothetical sample file 2")
  tmp_smm2$add_ephe(tmp_ephe1)
  # ??? Adding the electropherogram that appears in sample 1 as well
  tmp_smm2$add_ephe(tmp_ephe2)
  tmp_batch$add_sample(tmp_smm2)

  
    
    
}
