
# For unit test, rsunit_test_MetabBatchSimple <- T and source it.

source.RS("MetabDatAnalyses/TreatPeaks/PeakGrps1_1.R")
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")

MetabBatchSimple <-
  setRefClass("MetabBatchSimple",
    fields = list(
        sample_metab_meas_list = "list",
        peak_grps              = "PeakGrps",
        ref_annotlist          = "AnnotList",
        xcms_MSnbase           = "ANY",
        xcms_XCMSnExp          = "ANY"
        
      )) # "ANY" as generic class name?


MetabBatchSimple$methods(initialize =
    function(){
      
    })

MetabBatchSimple$methods(import_from_mzml_files =
    function(imzML_files, iannotlist){

      # iannotlist           <- AnnotList(iannotlist_file)
      .self$ref_annotlist <- iannotlist
      target_mz_range_mat <- iannotlist$get_mz_range_dfrm()
      
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
            isamplenam = basename(fileNames(xcms_rawdat_obj)[ sample_idx ]))
        
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
          ephe$set_mz(iannotlist$annotlist_dfrm[ chromat_idx, "m/z" ])
          smm$add_ephe(ephe) 
          
          print(iannotlist$annotlist_dfrm[ chromat_idx, ])
          
        }
        
        .self$add_sample(smm)
        
      }
      
    })


MetabBatchSimple$methods(add_sample =
    function(isample_metab_meas){
      isample_metab_meas$set_batch(.self)
      .self$sample_metab_meas_list <-
        c(.self$sample_metab_meas_list, isample_metab_meas)
    })


MetabBatchSimple$methods(set_xcms_peakgrp_info =
  function(){

    xcms_chromPeaks_all_mat <- NULL
    metabids_all <- NULL
    for(i in 1:length(.self$sample_metab_meas_list)){
      
      csmm <- .self$sample_metab_meas_list[[ i ]]
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
    

MetabBatchSimple$methods(find_bulk_peaks_all_samples =
  function(...){

    for(msample in .self$sample_metab_meas_list){
     
      msample$find_bulk_peaks_all_ephe(...)
       
    }
    
  })


if(exists("rsunit_test_MetabBatchSimple") &&
   rsunit_test_MetabBatchSimple){

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
  tmp_ephe1 <- EPherogram(tmp_ephe_mat1)
  
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
  tmp_ephe2 <- EPherogram(tmp_ephe_mat2)
  
  tmp_smm1 <- SampleMetabMeasure("Hypothetical sample file 1")
  tmp_smm1$add_ephe(tmp_ephe1, 70.63)
  tmp_smm1$add_ephe(tmp_ephe2, 75.87)
  tmp_batch$add_sample(tmp_smm1)

  tmp_smm2 <- SampleMetabMeasure("Hypothetical sample file 2")
  tmp_smm2$add_ephe(tmp_ephe1, 71.63)
  # ??? Adding the electropherogram that appears in sample 1 as well
  tmp_smm2$add_ephe(tmp_ephe2, 76.87)
  tmp_batch$add_sample(tmp_smm2)

  
    
    
}
