
source.RS("MetabDatAnalyses/TreatPeaks/AnnotListPair1_1.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")

source.RS("Usefuls1/data_range1.R")

# For unit test, rsunit_test_RefSampPairSingle <- T and source it.

RefSampPairSingle <-
  setRefClass("RefSampPairSingle",
              fields = list(
                ref = "SampleMetabMeasure",
                smp = "SampleMetabMeasure",
                params = "list",
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

RefSampPairSingle$methods(match_peak_simple =
  function(imetabid){
    
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
      return(pk)
    } else {
      return(NULL)
    }
    
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

RefSampPairSingle$methods(plot_peak_in_ephe =
  function(imetabid,
           extra_rate_mt     = 3.0,
           extra_rate_intsty = 0.2,
           col_ref = "gray", col_smp = "red",
           xlim = NULL, ylim = NULL){

    ephe_info_ref <-
      .self$ref$get_ephe_info_from_metabid(imetabid)
    ephe_info_smp <-
      .self$smp$get_ephe_info_from_metabid(imetabid)
    
    ephe_ref <- ephe_info_ref$ephe
    ephe_smp <- ephe_info_smp$ephe
    
    peak_ref <- ephe_info_ref$pk
    peak_smp <- ephe_info_smp$pk
    
    peak_ref_range     <- peak_ref$get_mt_range()
    peak_smp_range     <- peak_smp$get_mt_range()
    peak_smp_range_adj <- .self$map_to_ref(peak_smp_range)

    annot_name <-
      as.character(.self$ref$annotlist$annotlist_dfrm[ imetabid,
                                                       "Annotation Name" ])
    if(!is.na(annot_name) && length(annot_name)){
      title <- sprintf("[ m/z: %.4f ] %s: %s", ephe_ref$mz, imetabid, annot_name)
    } else {
      title <- sprintf("[ m/z: %.4f ] %s", ephe_info_ref$mz, imetabid)
    }
    
    if(is.null(xlim)){     
      peak_pair_range <-
        c(min(c(peak_ref_range, peak_smp_range_adj)),
          max(c(peak_ref_range, peak_smp_range_adj)))
      xlim <-
        extra_range(peak_pair_range[1],
                    peak_pair_range[2],
                    ex_rate = extra_rate_mt,
                    conv_int = F)
    }
    
    if(is.null(ylim)){
      intsty_extra <-
        max(peak_ref$get_intensity_top(),
            peak_smp$get_intensity_top()) * (1+extra_rate_intsty)
      ylim <- c(0, intsty_extra)

    }
    
    
    ephe_ref$plot_res_find_peak_simple(
      col = col_ref,
      xlim = xlim, ylim = ylim,
      xlab = "Reference migration time (MT)",
      ylab = "Intensity",
      main = title,
      ann = F)    
    
    par(new=T) 
    
    mts_adj <- .self$map_to_ref(ephe_smp$get_mts())
    
    ephe_smp$plot_res_find_peak_simple(
      col = col_smp,
      mts = mts_adj,
      xlim = xlim, ylim = ylim,
      xlab = "Reference migration time (MT)",
      ylab = "Intensity",
      main = title)
    par(new=F) 
    
    legend("topleft",
           legend = c(.self$ref$samplenam, .self$smp$samplenam),
           col    = c(col_ref, col_smp),
           lty    = 1)
    
    return(mts_adj)
    
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
            "MetabolomeGeneral", "AnnotationList",
            "C_114_annotlist_160809-2_RSC1.csv")
  
  tmp_annotlist1 <- AnnotList(example_annotlist_file1)
  
  mtadjustpair <- RefSampPairSingle()
  mtadjustpair$add_smm_pair(tmp_ref1, tmp_smm3) # tmp_smm1
  mtadjustpair$gen_Reijenga()
  print(mtadjustpair$map_to_ref(1:10))
  tmp_match_pk <- mtadjustpair$match_peak_simple("G011")
  print(mtadjustpair$annotate_landmarks())
  mtadjustpair$plot_peak_in_ephe("107")
  mtadjustpair$plot_Reijenga_adjust()
  # mtadjustpair$params$annotlistpair$params$reijenga_mtmat
  
}


