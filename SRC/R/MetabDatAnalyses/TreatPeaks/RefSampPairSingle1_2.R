
source.RS("MetabDatAnalyses/TreatPeaks/AnnotListPair1_1.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/EpheScanner1_3.R")

source.RS("Usefuls1/data_range1.R")
source.RS("Usefuls1/split_by_distance1.R")
source.RS("Usefuls1/find_identical_elems_in_list1.R")


# For unit test, rsunit_test_RefSampPairSingle <- T and source it.

RefSampPairSingle <-
  setRefClass("RefSampPairSingle",
              fields = list(
                ref = "SampleMetabMeasure",
                smp = "SampleMetabMeasure",
                params = "list",
                adjust_mt_pair_ref = "matrix",
                adjust_mt_pair_smm = "matrix",
                # ref to its aligned, smp to its aligned
                h = "list" # score, etc.
              ))

RefSampPairSingle$methods(initialize =
  function(){
    
  })

RefSampPairSingle$methods(
  add_smm_pair = function(iref, ismp){
  
    # iref$find_bulk_peaks_all_ephe()
    # ismp$find_bulk_peaks_all_ephe()

    .self$ref <- iref
    .self$smp <- ismp
      
})

RefSampPairSingle$methods(
  gen_Reijenga = function(imark_pair = NULL){

    .self$params$annotlistpair <-
      AnnotListPair(.self$ref$annotlist,
                    .self$smp$annotlist)
    
    if(is.null(imark_pair)){
      .self$params$annotlistpair$gen_Reijenga(
        # .self$ref is used.
        .self$ref$annotlist$marks$IS_marks[1],
        .self$ref$annotlist$marks$IS_marks[2]
      )
    } else {
      .self$params$annotlistpair$gen_Reijenga(
        # .self$ref is used.
        imark_pair[1],
        imark_pair[2]
      )
    }

  })


RefSampPairSingle$methods(map_to_ref =
  function(imt_vec){
    
    return(.self$params$annotlistpair$map_to_ref_Reijenga(imt_vec))

  })

RefSampPairSingle$methods(map_from_ref =
  function(imt_vec){
                             
    return(.self$params$annotlistpair$map_from_ref_Reijenga(imt_vec))
                             
  })


RefSampPairSingle$methods(smm_unalign_to_ref_unalign_mt =
  function(isample_mt){
                              
    nearest_idx <-
      which.min(abs(.self$adjust_mt_pair_smm[ ,1 ] - isample_mt))
    aligned_mt <-
      .self$adjust_mt_pair_smm[ nearest_idx, 2 ]
    ref_aligned_nearest_idx <-
      which.min(abs(.self$adjust_mt_pair_ref[ , 2 ] - aligned_mt))
    ref_mt <-
      .self$adjust_mt_pair_ref[ ref_aligned_nearest_idx, 1 ]
    
    return(ref_mt)
                              
  })


RefSampPairSingle$methods(smm_unalign_to_ref_unalign_mts =
  function(isample_mts){
    
    return(sapply(isample_mts,
                  .self$smm_unalign_to_ref_unalign_mt))
    
  })

RefSampPairSingle$methods(ref_unalign_to_smm_unalign_mt =
  function(iref_mt){
  
    nearest_idx <-
      which.min(abs(.self$adjust_mt_pair_ref[ ,1 ] - iref_mt))
    aligned_mt <-
      .self$adjust_mt_pair_ref[ nearest_idx, 2 ]
    smm_aligned_nearest_idx <-
      which.min(abs(.self$adjust_mt_pair_smm[ , 2 ] - aligned_mt))
    smm_mt <-
      .self$adjust_mt_pair_smm[ smm_aligned_nearest_idx, 1 ]
    
    return(smm_mt)
                              
  })

RefSampPairSingle$methods(
  ref_unalign_to_smm_unalign_mts =
    function(iref_mts){

      return(sapply(iref_mts,
                    .self$ref_unalign_to_smm_unalign_mt))
                              
})


RefSampPairSingle$methods(match_peak_simple =
  function(imetabid, warn_no_match = TRUE){
    
    pk <- NULL
    
    if(imetabid %in% rownames(.self$ref$annotlist$annotlist_dfrm)){

      ref_mt_range <-
        .self$ref$annotlist$get_mt_range(imetabid)
      tgt_mt_range <-
        .self$map_from_ref(ref_mt_range)
      mz <- .self$ref$annotlist$get_mz(imetabid)
      
      ephe <- .self$smp$find_ephe_mz(mz)
      
      if(!is.null(ephe)){
        pk <- ephe$get_peak_highest_score(
          imt_range = tgt_mt_range
        )
      } else if(warn_no_match) {
        warning(sprintf("Failed to generate electropherogram for metabolite \"%s\" in the sample \"%s\".",
                        imetabid, .self$smp$samplenam))        
      }
      
    } else {
      warning(sprintf("Metabolite \"%s\" not found in the annotation list of the sample \"%s\".",
                      imetabid, .self$ref$samplenam))
    }
    
    return(pk)
    
  })

RefSampPairSingle$methods(annotate_landmarks =
  function(){

    annotated_metabids <- NULL
    
    for(metabid in .self$ref$annotlist$marks$landmarks){

      matched_pk <- .self$match_peak_simple(metabid)
      if(!is.null(matched_pk)){
        .self$smp$annotate_peak_metabid(matched_pk, metabid)
        annotated_metabids <- c(annotated_metabids, metabid)
        .self$smp$annotlist$marks$landmarks <-
            c(.self$smp$annotlist$marks$landmarks, metabid)
      }
            
    }
    
    return(annotated_metabids)

})


RefSampPairSingle$methods(
  match_peaks =
    function(icut_thres_mt     = 100,
             iextra_range_rate = 0.2,
             ippm              = 100,
             imt_adjust_method = "reijenga"){
  
      ephe_scanners <- list()
      
      smzs <-
        unique(.self$ref$annotlist$annotlist_dfrm[, "m/z"])
      
      for(cmz in smzs){
        
        cat(sprintf("Scanning m/z: %f ...\n", cmz))
        samp_ephe <- 
          .self$smp$find_ephe_mz(imz = cmz, ippm = ippm)
        
        if(is.null(samp_ephe)){
          
          warn(sprintf("Electropherogram (m/z: %f) extraction failed for sample %s",
                       cmz, .self$smp$samplenam))
          
        } else {
          
          ephe_scanner <-
            EPheScanner(.self,
                        imz = cmz,
                        ippm = ippm)
          ephe_scanner$segm_split_by_annot_peaks(
            icut_thres_mt, imz = cmz, ippm = ippm)
          ephe_scanner$gothrough_all_segms()
          
          ephe_scanners <-
            c(ephe_scanners, list(`as.character(cmz)` = ephe_scanner))
          
        }
        
      }
      
      return(ephe_scanners)
                              
  })






RefSampPairSingle$methods(plot_peak_in_ephe =
  function(imetabid = "",
           imz = NULL,
           imax_diff_mz = NULL, ippm = 100,
           extra_rate_mt     = 3.0,
           extra_rate_intsty = 0.2,
           col_ref = "gray", col_smp = "red",
           xlim = NULL, ylim = NULL,
           align_mode = "reijenga"){

    if(imetabid != ""){

      annot_name <-
        as.character(.self$ref$annotlist$annotlist_dfrm[ imetabid,
                                                         "Annotation Name" ])
      mz <- .self$ref$annotlist$get_mz(imetabid) # Can be NA
      mt <- .self$ref$annotlist$get_mt(imetabid) # Can be NA
      
      ephe_info_ref <-
        .self$ref$get_ephe_info_from_metabid(imetabid)
      ephe_info_smp <-
        .self$smp$get_ephe_info_from_metabid(imetabid)
      
      # NULL if only annotation list (no spectrum information) is prepared
      ephe_ref <- ephe_info_ref$ephe
      peak_ref <- ephe_info_ref$pk
      #
      
      ephe_smp <- ephe_info_smp$ephe
      peak_smp <- ephe_info_smp$pk
      
      if(!is.null(peak_ref)){
        peak_ref_range     <- peak_ref$get_mt_range()
        peak_intsty_tops   <- peak_ref$get_intensity_top()
      } else {
        peak_ref_range     <- mt
        peak_intsty_tops   <- NULL
      }
      
      if(!is.null(peak_smp)){
        peak_smp_range     <- peak_smp$get_mt_range()
        peak_intsty_tops   <- c(peak_intsty_tops,
                                peak_smp$get_intensity_top())
      } else {
        peak_smp_range     <- NULL
      }
      
      if(!is.null(ephe_ref$mz)){
        mz <- ephe_ref$mz
      } else if(!is.null(ephe_smp$mz)){
        mz <- ephe_smp$mz
      }
      
      if(!is.na(annot_name) && length(annot_name)){
        plot_title <- sprintf("[ m/z: %.4f ] %s: %s",
                              mz, imetabid, annot_name)

      } else {
        plot_title <- sprintf("[ m/z: %.4f ] %s",
                              mz, imetabid)
      }
      
    } else if(!is.null(imz)){
      
      annot_name <- ""
      mz         <- imz
      
      extra_rate_mt <- 0.1
      
      ephe_ref <-
        .self$ref$find_ephe_mz(imz, imax_diff_mz, ippm)
      ephe_smp <-
        .self$smp$find_ephe_mz(imz, imax_diff_mz, ippm)
      
      if(!is.null(ephe_ref)){
        peak_ref_range <- ephe_ref$get_mt_range()
      } else {
        peak_ref_range <- NULL
      }
      
      if(!is.null(ephe_smp)){
        peak_smp_range <- ephe_smp$get_mt_range()
      } else {
        peak_smp_range <- NULL 
      }
      
      if(!is.null(ephe_ref)){
        peak_intsty_tops <- max(ephe_ref$get_intstis())
      } else {
        peak_intsty_tops <- NULL
      }
      
      if(!is.null(ephe_smp)){
        peak_intsty_tops <- c(peak_intsty_tops,
                              max(ephe_smp$get_intstis()))
      }
      
      plot_title <- sprintf("[ m/z: %.4f ] ~%.4f",
                            ephe_smp$mz, mz)
      
    } else {
      
      stop("No metabolite ID or m/z given for multiple electropherogram plotting")
    
    }
    
    if((length(peak_ref_range) || length(peak_smp_range))
        && length(peak_intsty_tops)){
    
    
      if(align_mode == "reijenga"){
        peak_smp_range_adj <- .self$map_to_ref(peak_smp_range)
        xlab <- "Reference migration time (MT)"
      } else if(align_mode == "loess"){
        peak_smp_range_adj <-
          .self$smm_unalign_to_ref_unalign_mts(peak_smp_range)
        xlab <- "Reference migration time (MT)"
      } else {
        peak_smp_range_adj <- peak_smp_range
        xlab <- "Migration time (MT)"
      }
      
      peak_pair_range <-
        c(min(c(peak_ref_range, peak_smp_range_adj)),
          max(c(peak_ref_range, peak_smp_range_adj)))
      
      if(is.null(xlim)){
        xlim <-
          extra_range(peak_pair_range[1],
                      peak_pair_range[2],
                      ex_rate = extra_rate_mt,
                      conv_int = F)
      }
      
      if(is.null(ylim)){
        intsty_extra <-
          max(peak_intsty_tops) * (1+extra_rate_intsty)
        ylim <- c(0, intsty_extra)
  
      }
      
      plot_exist <- FALSE
      
      if(!is.null(ephe_ref)){
        ephe_ref$plot_res_find_peak_simple(
          col = col_ref,
          xlim = xlim, ylim = ylim,
          xlab = xlab,
          ylab = "Intensity",
          main = plot_title,
          ann = T)
        plot_exist <- TRUE
      } else if(
        !is.na(mz) &&
        !is.null(.self$ref$annotlist$get_metabs_similar_mz(imz = mz, ippm = ippm))){
        
        .self$ref$annotlist$plot_peak_poss_simple(
          imz = mz, ippm = ippm,
          col = col_ref,
          xlim = xlim, ylim = ylim,
          xlab = xlab,
          ylab = "Intensity",
          main = plot_title,
          ann = T)
        plot_exist <- TRUE
      }
      
      if(plot_exist){ par(new=T) }
      
      if(align_mode == "reijenga"){
        mts_adj <- .self$map_to_ref(ephe_smp$get_mts())
      } else if(align_mode == "loess"){
        mts_adj <-
          .self$smm_unalign_to_ref_unalign_mts(ephe_smp$get_mts())
      } else {
        mts_adj <- ephe_smp$get_mts()
      }     
  
      ephe_smp$plot_res_find_peak_simple(
        col = col_smp,
        mts = mts_adj,
        xlim = xlim, ylim = ylim,
        xlab = xlab,
        ylab = "Intensity",
        ann  = !plot_exist,
        main = title)
      par(new=F) 
      
      legend("topleft",
             legend = c(.self$ref$samplenam, .self$smp$samplenam),
             col    = c(col_ref, col_smp),
             lty    = 1)
    
    } else {
      if(is.null(imz)){
        mz_str <- "-"
      } else {
        mz_str <- as.character(imz)
      }
      warning(sprintf("No plot generated for ref.:%s, sample: %s, metabolite: %s, m/z: %s",
                      .self$ref$samplenam,
                      .self$smp$samplenam,
                      imetabid, mz_str))

    }
    
  })


RefSampPairSingle$methods(plot_Reijenga_adjust =
  function(){
    
    smp_mt_range     <- .self$smp$get_mt_range()
    # smp_mt_range_adj <- .self$map_to_ref(smp_mt_range) 
    
    smp_mt_plot <-
      (-10:110)/100 * (smp_mt_range[2] - smp_mt_range[1]) + smp_mt_range[1]
    
    smp_mt_plot_map_to_ref <- .self$map_to_ref(smp_mt_plot)
    
    reijenga_mtmat <-
      params$annotlistpair$params$reijenga_mtmat
    
    plot(smp_mt_plot,
         smp_mt_plot_map_to_ref,
         xlab = paste("Migration time (MT) of", .self$smp$samplenam),
         ylab = paste("Migration time (MT) of", .self$ref$samplenam),
         main = paste("Reijenga MT adjustment of", .self$smp$samplenam))
    points(reijenga_mtmat[,2], reijenga_mtmat[,1],
           pch = 16, col = "red")
    
    text(reijenga_mtmat[,2], reijenga_mtmat[,1],
         rownames(reijenga_mtmat),
         pos = 4, col = "red")
    
  })

if(exists("rsunit_test_RefSampPairSingle") &&
   rsunit_test_RefSampPairSingle){
  
  source.RS("FilePath/rsFilePath1.R")
  source.RS("MetabDatAnalyses/TreatPeaks/testdata1_2.R", reload = T)
  
  example_annotlist_file1 <-
    RSFPath("TRUNK", "cWorks", "Project",
            "MetabolomeGeneral", "CE-MS", "AnnotationList",
            "C_114_annotlist_160809-2_RSC1.csv")
  
  tmp_annotlist1 <- AnnotList(example_annotlist_file1)
  
  mtadjustpair <- RefSampPairSingle()
  mtadjustpair$add_smm_pair(tmp_ref0, tmp_smm3) # tmp_smm1
  mtadjustpair$gen_Reijenga()
  print(mtadjustpair$map_to_ref(1:10))
  
  tmp_match_pk <- mtadjustpair$match_peak_simple("G011")
  
  print(mtadjustpair$annotate_landmarks())
  mtadjustpair$plot_peak_in_ephe("107")
  mtadjustpair$plot_Reijenga_adjust()
  # mtadjustpair$params$annotlistpair$params$reijenga_mtmat
  
}


