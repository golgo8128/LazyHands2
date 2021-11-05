
library(RColorBrewer)

source.RS("MetabDatAnalyses/TreatPeaks/AnnotListPair1_1.R")
source.RS("MetabDatAnalyses/TreatPeaks/MetabBatchSimple2_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/RefSampPairSingle1_1.R")


source.RS("Usefuls1/data_range1.R")

# For unit test, rsunit_test_RefSampPairSet <- T and source it.

RefSampPairSet <-
  setRefClass("RefSampPairSet",
              fields = list(
                batch          = "MetabBatchSimple",
                ref            = "SampleMetabMeasure",
                smp_l          = "list",
                refsmp_pairs_l = "list" # ,
                # adjust_mt_pairs_l = "list"
              ))

RefSampPairSet$methods(initialize =
  function(ibatch = NULL){

    if(!is.null(ibatch)){
      .self$batch <- ibatch
    }
        
  })

RefSampPairSet$methods(
  add_ref = function(iref){
    
    .self$ref <- iref
    
  })


RefSampPairSet$methods(
  add_smp = function(ismp){
  
  .self$smp_l <- c(.self$smp_l, ismp) # list(ismp)
  
  mtadjustpair <- RefSampPairSingle()
  mtadjustpair$add_smm_pair(.self$ref, ismp)
  
  .self$refsmp_pairs_l <-
    c(.self$refsmp_pairs_l, mtadjustpair)
      
})


RefSampPairSet$methods(
  gen_Reijenga = function(imark_pair = NULL){
    
    for(refsamppair in .self$refsmp_pairs_l){
      
      refsamppair$gen_Reijenga(imark_pair)
      
    }
      
  })

RefSampPairSet$methods(
  smm_unalign_to_ref_unalign_mt = function(isample, imt){
    
    sample_num_in_pairs <-
      which(sapply(.self$refsmp_pairs_l,
                   function(tmppair){ identical(tmppair$smp, isample) }))
    ref_smm_pair <-
      .self$refsmp_pairs_l[[ sample_num_in_pairs ]]
    
    ref_mt <- ref_smm_pair$smm_unalign_to_ref_unalign_mt(imt)
    
    return(ref_mt)
    
  })

RefSampPairSet$methods(
  ref_unalign_to_smm_unalign_mt = function(isample, imt){
    
    sample_num_in_pairs <-
      which(sapply(.self$refsmp_pairs_l,
                   function(tmppair){ identical(tmppair$smp, isample) }))
    ref_smm_pair <-
      .self$refsmp_pairs_l[[ sample_num_in_pairs ]]
    
    smm_mt <- ref_smm_pair$ref_unalign_to_smm_unalign_mt(imt)
    
    return(smm_mt)
    
  })



RefSampPairSet$methods(plot_peak_in_ephe =
  function(imetabid,
           extra_rate_mt     = 3.0,
           extra_rate_intsty = 0.2,
           col_ref  = "gray",
           cols_smp = brewer.pal(7, "Set2"),
           xlim = NULL, ylim = NULL){
                              
    ephe_info_ref <-
      .self$ref$get_ephe_info_from_metabid(imetabid)
    ephe_ref <- ephe_info_ref$ephe
    peak_ref <- ephe_info_ref$pk
    peak_ref_range <- peak_ref$get_mt_range()

    annot_name <-
      as.character(.self$ref$annotlist$annotlist_dfrm[ imetabid,
                                                       "Annotation Name" ])

    if(!is.na(annot_name) && length(annot_name)){
      title <- sprintf("[ m/z: %.4f ] %s: %s", ephe_ref$mz, imetabid, annot_name)
    } else {
      title <- sprintf("[ m/z: %.4f ] %s", ephe_info_ref$mz, imetabid)
    }    
          
    peak_ranges_messed <- peak_ref_range
    peak_intsty_tops   <- peak_ref$get_intensity_top()
    
    for(i in 1:length(.self$smp_l)){
      smp  <- .self$smp_l[[ i ]] # .self$refsmp_pairs_l[[ i ]]$smp 
      pair <- .self$refsmp_pairs_l[[ i ]]
      
      ephe_info_smp <-
        smp$get_ephe_info_from_metabid(imetabid)
      ephe_smp <- ephe_info_smp$ephe
      peak_smp <- ephe_info_smp$pk
      
      peak_smp_range     <- peak_smp$get_mt_range()
      peak_smp_range_adj <- pair$map_to_ref(peak_smp_range)
      peak_ranges_messed <-
        c(peak_ranges_messed, peak_smp_range_adj)
      peak_intsty_tops   <- c(peak_intsty_tops,
                              peak_smp$get_intensity_top())
    }
    
    if(is.null(xlim)){     
      peak_pair_range <-
        c(min(peak_ranges_messed),
          max(peak_ranges_messed))
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
      ann = T)    
    
    cols_smp <- 
      rep(cols_smp,
          ceiling(length(.self$smp_l) / length(cols_smp)))[ 1:length(.self$smp_l) ]
    
    for(i in 1:length(.self$smp_l)){
      smp  <- .self$smp_l[[ i ]]
      pair <- .self$refsmp_pairs_l[[ i ]]
      ephe_info_smp <-
        smp$get_ephe_info_from_metabid(imetabid)
      ephe_smp <- ephe_info_smp$ephe
    
      par(new=T)
      
      ephe_smp$plot_res_find_peak_simple(
        col = cols_smp[ i ],
        mts = pair$map_to_ref(ephe_smp$get_mts()),
        xlim = xlim, ylim = ylim,
        xlab = "Reference migration time (MT)",
        ylab = "Intensity",
        main = title,
        ann = F)
      
    }
      
    par(new=F) 
    
    legend("topleft",
           legend = c(.self$ref$samplenam,
                      sapply(.self$smp_l,
                             function(tmpsmp){ tmpsmp$samplenam })),
           col    = c(col_ref, cols_smp),
           lty    = 1)
    
                              
  })


RefSampPairSet$methods(calc_adjust_mt_pairs =
  function(){

  adjust_mt_pairs_squashed <-
    cbind(rtime(.self$batch$xcms_XCMSnExp), rtime(.self$batch$xcms_XCMSnExp_aligned))
  
  adjust_mt_pairs_ref <- 
    adjust_mt_pairs_squashed[
      fromFile(.self$batch$xcms_XCMSnExp_aligned) == 1, ]
    
  for(ismm_num in 1:length(.self$refsmp_pairs_l)){
    adjust_mt_pairs_smm <-
      adjust_mt_pairs_squashed[
        fromFile(.self$batch$xcms_XCMSnExp_aligned) == ismm_num  + 1, ]
    
    .self$refsmp_pairs_l[[ ismm_num ]]$adjust_mt_pair_ref <-
      adjust_mt_pairs_ref
    .self$refsmp_pairs_l[[ ismm_num ]]$adjust_mt_pair_smm <-
      adjust_mt_pairs_smm
    
  }
      
  # .self$adjust_mt_pairs_l <-
  #   lapply(1:length(fileNames(.self$batch$xcms_MSnbase)),
  #          function(tmpsamplenum){
  #            adjust_mt_pairs_squashed[
  #              fromFile(.self$batch$xcms_XCMSnExp_aligned) == tmpsamplenum, ]
  #          })
  
  })
  

if(exists("rsunit_test_RefSampPairSet") &&
   rsunit_test_RefSampPairSet){
  
  source.RS("FilePath/rsFilePath1.R")
  source.RS("MetabDatAnalyses/TreatPeaks/testdata1_2.R", reload = T)
  
  example_annotlist_file1 <-
    RSFPath("TRUNK", "cWorks", "Project", "MetabolomeGeneral",
            "CE-MS", "STDs", "Cation",
            "RefSTD_C114_annotlist20200303.csv")
  
  tmp_annotlist1 <- AnnotList(example_annotlist_file1)
  
  tmppairset <- RefSampPairSet()
  tmppairset$add_ref(tmp_ref1)
  tmppairset$add_smp(tmp_smm1)
  tmppairset$add_smp(tmp_smm3)
  tmppairset$gen_Reijenga()
  
  # print(tmppairset$map_to_ref(1:10))
  # tmp_match_pk <- tmppairset$match_peak_simple("G011")
  # print(tmppairset$annotate_landmarks())
  tmppairset$plot_peak_in_ephe("107")
  
}


