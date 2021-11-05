
source.RS("MetabDatAnalyses/TreatPeaks/MetabBatchSimple2_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")
source.RS("Usefuls1/data_range1.R")

# For unit test, rsunit_test_SampleMetabMeasure <- T and source it.

SampleMetabMeasure <-
  setRefClass("SampleMetabMeasure",
    fields = list(
      batch     = "MetabBatchSimple",
      datfilnam = "character",
      samplenam = "character",
      ephe_list = "list",
      ephe_mzs  = "numeric",
      annotlist = "AnnotList", # Electropherogram may not contain all peaks here
                               # (ex. Uncharacterized peaks not in the reference)
      h         = "list"
    ))

SampleMetabMeasure$methods(show =
    function(){

      cat(sprintf("Sample measurement %s\n",
                  .self$samplenam))
      
    })

SampleMetabMeasure$methods(initialize =
  function(idatfilnam = "", isamplenam = ""){
    
    .self$datfilnam <- idatfilnam
    .self$samplenam <- isamplenam
    .self$annotlist <- AnnotList()
    .self$annotlist$set_samplemetabmeasure(.self)
      
  })

SampleMetabMeasure$methods(add_ephe =
  function(iephe_obj){
    
    .self$ephe_list <- c(.self$ephe_list, iephe_obj)
    .self$ephe_mzs  <- c(.self$ephe_mzs, iephe_obj$mz)
    iephe_obj$sampmmeasr <- .self
    
    })

SampleMetabMeasure$methods(annotate_peak_metabid =
  function(ipk, imetabid){

    ipk$peak_annot_id <- imetabid
    .self$annotlist$reg_mz(imetabid, ipk$epherogram_obj$mz)
    .self$annotlist$reg_mt(imetabid, ipk$mt_top)
    
  })


SampleMetabMeasure$methods(find_bulk_peaks_all_ephe =
  function(...){
    for(ephe in .self$ephe_list){
    
      ephe$find_bulk_peaks(...)
        
    }
    
  })




SampleMetabMeasure$methods(set_batch =
  function(ibatch){

    .self$batch <- ibatch
                               
  })


SampleMetabMeasure$methods(set_annotlist =
  function(iannotlist){
  
    .self$annotlist <- iannotlist
    .self$annotlist$set_samplemetabmeasure(.self)
                               
  })


SampleMetabMeasure$methods(update_annotlist_based_on_peaks =
  function(){

    # Maybe annotation list should be imported for getting ISs information
    # before doing this.
    # Peaks not in the electropherograms (ex. uncharacterized peaks)
    # will not be changed.
    
    for(ephe in .self$ephe_list){
      for(pk in ephe$get_peaks()){
        if(length(pk$peak_annot_id)){
          
          .self$annotlist$reg_mz(pk$peak_annot_id,
                                 ephe$mz)
          .self$annotlist$reg_mt(pk$peak_annot_id,
                                 pk$mt_top)
          
        }
      }
    }
                               
  })



SampleMetabMeasure$methods(find_ephe_mz =
  function(imz, imax_diff_mz = NULL, ippm = 100){

    if(is.null(imax_diff_mz)){
      diffs_mz   <- (.self$ephe_mzs - imz) / imz
      diff_thres <- ippm / 10^6
    } else {
      diffs_mz   <- .self$ephe_mzs - imz
      diff_thres <- imax_diff_mz
    }
    
    idx_min <- which.min(abs(diffs_mz))
    if(abs(diffs_mz[ idx_min ]) <= diff_thres){
      return(.self$ephe_list[[ idx_min ]])
      } else {
      return(NULL)
    }
      
  })


SampleMetabMeasure$methods(find_IS_marks =
  function(imhannot, zscore_thres = 3.72){
    
    internal_stds_ids <-
      imhannot$marks$IS_marks
    internal_stds_mzs <-
      imhannot$annotlist_dfrm[ internal_stds_ids, "m/z"]
    
    ret_pks <- list()
    for(i in 1:length(internal_stds_ids)){
      aid <- internal_stds_ids[ i ]
      cmz <- internal_stds_mzs[ i ]
      
      cephe <- .self$find_ephe_mz(cmz)
      if(!is.null(cephe)){
        hpk <- cephe$get_peak_highest_score()
        if(!is.null(hpk) && hpk$h$zscore >= zscore_thres){
          hpk$peak_annot_id       <- aid
          hpk$h$internal_std_flag <- TRUE
          # print(.self$annotlist$annotlist_dfrm)
          .self$annotlist$reg_mz(aid, cephe$mz) # cmz
          .self$annotlist$reg_mt(aid, hpk$mt_top)
          .self$annotlist$reg_IS(aid)
          ret_pks <- c(ret_pks, hpk)
        }
      }
      
    }
    
    return(ret_pks)
        
  })


SampleMetabMeasure$methods(get_peaks =
  function(imz_range = NULL, imt_range = NULL){
  
    pks_accu <- NULL
    for(ephe in .self$ephe_list){
      if(is.null(imz_range) ||
         (imz_range[1] <= ephe$mz && ephe$mz < imz_range[2])){
        pks_accu <- c(pks_accu, ephe$get_peaks(imt_range))  
      }
    }
  
    return(pks_accu)
  
})

SampleMetabMeasure$methods(plot_peaks =
  function(imz_range = NULL, imt_range = NULL){

    pks_l       <- .self$get_peaks()  
    pk_top_mts  <- sapply(pks_l, function(tmppk){ tmppk$mt_top })
    pk_mzs      <- sapply(pks_l, function(tmppk){ tmppk$epherogram_obj$mz })    
    pk_scores   <- sapply(pks_l, function(tmppk){ tmppk$h$zscore })
    pk_annotids <- sapply(pks_l, function(tmppk){ tmppk$peak_annot_id })
    
    annot_bools <- nchar(pk_annotids) > 0
    
    xlim <- extra_range(min(pk_top_mts), max(pk_top_mts))
    ylim <- extra_range(min(pk_mzs)    , max(pk_mzs))
    
    # extra_range(val_min, val_max, ex_rate = 0.1
    
    plot(pk_top_mts, pk_mzs, 
         xlab = "Migration time (MT)",
         ylab = "m/z",
         main = paste("Peaks in", .self$samplenam),
         xlim = xlim, ylim = ylim)
    
    points(pk_top_mts[ annot_bools ],
           pk_mzs[ annot_bools ],
           col = "orange", pch = 16)
    
    text(pk_top_mts[ annot_bools ],
         pk_mzs[ annot_bools ],
         pk_annotids[ annot_bools ],
         pos = 1,
         col = "orange", pch = 16)

})

SampleMetabMeasure$methods(get_IS_marks =
  function(){

    ret_pks <- list()
    for(ephe in .self$ephe_list){
     
      for(pk in ephe$peak_list){
        if(!is.null(pk$h$internal_std_flag) &&
           pk$h$internal_std_flag){
          ret_pks <- c(ret_pks, pk)
        }
      }
       
    }
   
    return(ret_pks)
     
  })

SampleMetabMeasure$methods(get_ephe_info_from_metabid =
  function(imetabid){

    mz <- .self$annotlist$get_mz(imetabid)
    mt <- .self$annotlist$get_mt(imetabid)
    ephe <- .self$find_ephe_mz(mz, imax_diff_mz = 0)
    pk <- ephe$get_peak_from_metabid(imetabid)
    
    return(list(ephe = ephe, mt = mt, pk = pk))

  })
    
SampleMetabMeasure$methods(get_mt_range =
  function(icommon_range_flag = F){

    mt_starts <-
      sapply(.self$ephe_list, function(tmpephe){ tmpephe$get_mt_range()[1] })
    mt_ends <-
      sapply(.self$ephe_list, function(tmpephe){ tmpephe$get_mt_range()[2] })
    
    if(icommon_range_flag){
      return(c(max(mt_starts), min(mt_ends)))
    } else {
      return(c(min(mt_starts), max(mt_ends)))
    }
    
  })


SampleMetabMeasure$methods(xcms_chromPeaks =
  function(isample_num = NA){
    
    mzs       <- sapply(.self$get_peaks(),
                        function(tmppk){ tmppk$epherogram_obj$mz })
    mt_tops   <- sapply(.self$get_peaks(),
                        function(tmppk){ tmppk$mt_top })
    mt_lefts  <- sapply(.self$get_peaks(),
                        function(tmppk){ tmppk$mt_start })    
    mt_rights <- sapply(.self$get_peaks(),
                       function(tmppk){ tmppk$mt_end })   
    metabids  <- sapply(.self$get_peaks(),
                        function(tmppk){ tmppk$peak_annot_id }) 
    
    mat <- cbind(mzs, mzs, mzs, mt_tops, mt_lefts, mt_rights,
                 matrix(NA, length(.self$get_peaks()), 3),
                 rep(isample_num, length(.self$get_peaks())))
    colnames(mat) <-
      c("mz", "mzmin", "mzmax", "rt", "rtmin", "rtmax",
        "into", "maxo", "sn", "sample")
    
    return(list(metabids = metabids, mat = mat))
    
  })


SampleMetabMeasure$methods(import_mzML_peak_range_info =
  function(imzML_file,
           ipeak_range_info_file){

    source.RS("MetabDatAnalyses/TreatPeaks/PeakSingle1_1.R")
    
    peak_range_info_dfrm <-
      read.table(ipeak_range_info_file, sep = "\t",
                 header = T, row.names = 1,
                 quote = "", check.names = F, comment.char = "")
    
    mzML_obj <-
      readMSData(imzML_file, mode = "onDisk")
    
    mz_ranges <-
      cbind(peak_range_info_dfrm[[ "Peak m/z" ]] * (1-0.1^6),
            peak_range_info_dfrm[[ "Peak m/z" ]] * (1+0.1^6))
    
    chromats <-
      chromatogram(mzML_obj, mz = mz_ranges)
    
    # One peak for one electropherogram
    # Measured m/z of Ile and Leu slightly differ.
    # Corresponding m/z's in the actual sample may be identical.
    for(i in 1:nrow(peak_range_info_dfrm)){
      
      metabid  <- rownames(peak_range_info_dfrm)[ i ]
      annot    <- peak_range_info_dfrm[ i, "Peak annotation" ]
      print(annot)
      cmz      <- peak_range_info_dfrm[ metabid, "theoretical m/z" ] # Maybe better than Peak m/z
      chromat  <- chromats[ i, 1 ]
      # chromat <- chromatogram(mzML_obj,
      #                         mz = c(cmz * (1-0.1^6), cmz * (1+0.1^6)))
      ephe_mat <- cbind(rtime(chromat), intensity(chromat))
      ephe     <- EPherogram(ephe_mat)
      ephe$set_mz(cmz)
      
      mt_start <- peak_range_info_dfrm[ i, "Peak MT start" ] * 60
      mt_end   <- peak_range_info_dfrm[ i, "Peak MT end" ]   * 60
      
      start_idx <- which.min(abs(ephe_mat[,1] - mt_start))
      end_idx   <- which.min(abs(ephe_mat[,1] - mt_end))
      
      pk <- PeakSingle(ephe, start_idx, end_idx)
      ephe$add_peak(pk)
      .self$add_ephe(ephe)
      .self$annotate_peak_metabid(pk, metabid)
      # pk$set_annot_id(metabid)
      
    }
    
    # .self$update_annotlist_based_on_peaks()    

  })

    
SampleMetabMeasure$methods(import_peak_range_info =
  function(ipeak_range_info_file){
    # Under construction
    
    source.RS("MetabDatAnalyses/TreatPeaks/PeakSingle1_1.R")
    
    peak_range_info_dfrm <-
      read.table(ipeak_range_info_file, sep = "\t",
                 header = T, row.names = 1,
                 quote = "", check.names = F, comment.char = "")
    
    # mzML_obj <-
    #   readMSData(imzML_file, mode = "onDisk")
    
    mz_ranges <-
      cbind(peak_range_info_dfrm[[ "Peak m/z" ]] * (1-0.1^6),
            peak_range_info_dfrm[[ "Peak m/z" ]] * (1+0.1^6))
    
    # chromats <-
    #   chromatogram(mzML_obj, mz = mz_ranges)
    
    # One peak for one electropherogram
    # Measured m/z of Ile and Leu slightly differ.
    # Corresponding m/z's in the actual sample may be identical.
    for(i in 1:nrow(peak_range_info_dfrm)){
      
      metabid  <- rownames(peak_range_info_dfrm)[ i ]
      annot    <- peak_range_info_dfrm[ i, "Peak annotation" ]
      # print(annot)
      cmz      <- peak_range_info_dfrm[ metabid, "theoretical m/z" ] # Maybe better than Peak m/z

      # chromat  <- chromats[ i, 1 ]
      # chromat <- chromatogram(mzML_obj,
      #                         mz = c(cmz * (1-0.1^6), cmz * (1+0.1^6)))
      # ephe_mat <- cbind(rtime(chromat), intensity(chromat))
      # ephe     <- EPherogram(ephe_mat)
      # ephe$set_mz(cmz)
      ephe <- .self$find_ephe_mz(cmz)
      
      
      mt_start <- peak_range_info_dfrm[ i, "Peak MT start" ] * 60
      mt_end   <- peak_range_info_dfrm[ i, "Peak MT end" ]   * 60
      
      start_idx <- which.min(abs(ephe$get_mts() - mt_start))
      end_idx   <- which.min(abs(ephe$get_mts() - mt_end))
      
      pk <- PeakSingle(ephe, start_idx, end_idx)
      ephe$add_peak(pk)
      .self$add_ephe(ephe)
      .self$annotate_peak_metabid(pk, metabid)
      # pk$set_annot_id(metabid)
      
    }
    
    # .self$update_annotlist_based_on_peaks()    
    
  })



if(exists("rsunit_test_SampleMetabMeasure") &&
   rsunit_test_SampleMetabMeasure){

  source.RS("MetabDatAnalyses/TreatPeaks/Epherogram1_2.R")
  
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
  tmp_ephe1$set_mz(182.04)
  
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
  
  tmp_mt2 <- (1:length(tmp_intsty2)+1) / 2
  tmp_ephe_mat2 <- cbind(tmp_mt2, tmp_intsty2)
  tmp_ephe2 <- EPherogram(tmp_ephe_mat2)
  tmp_ephe2$set_mz(87.09)
  
  tmp_smm <- SampleMetabMeasure()
  tmp_smm$add_ephe(tmp_ephe1)
  tmp_smm$add_ephe(tmp_ephe2)
  
  tmp_smm$find_bulk_peaks_all_ephe()

  tmp_annotlist_file1 <-
    RSFPath("TRUNK", "cWorks", "Project",
            "MetabolomeGeneral", "CE-MS",
            "AnnotationList",
            "C_114_annotlist_160809-2_RSC1.csv")
  
  tmpmhannotlist1 <- AnnotList(tmp_annotlist_file1)  
  tmpispks <- tmp_smm$find_IS_marks(tmpmhannotlist1)
  
  tmp_smm$plot_peaks()
  
  # pks_l <- tmp_smm$get_peaks()
  # sapply(pks_l, function(tmppk){ tmppk$mt_top })
  # sapply(pks_l, function(tmppk){ tmppk$epherogram_obj$mz })
  # sapply(pks_l, function(tmppk){ tmppk$h$zscore })
  
  
}
