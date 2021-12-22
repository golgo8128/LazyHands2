
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
  function(imetabid = "",
           imz = NULL, imax_diff_mz = NULL, ippm = 100,
           extra_rate_mt     = NULL,
           extra_rate_intsty = 0.2,
           col_ref  = "gray",
           cols_smp = brewer.pal(7, "Set2"),
           xlim = NULL, ylim = NULL,
           align_mode = "reijenga"){

    if(imetabid != ""){
      annot_name <-
        as.character(.self$ref$annotlist$annotlist_dfrm[ imetabid,
                                                         "Annotation Name" ])
      mz <- .self$ref$annotlist$annotlist_dfrm[ imetabid, "m/z" ] # Can be NA
      if(is.null(extra_rate_mt)){ extra_rate_mt = 3.0 }
    } else {
      annot_name <- ""
      mz <- imz
      if(is.null(extra_rate_mt)){ extra_rate_mt = 0.0 }
    }
      
    if(align_mode == "reijenga"){
      xlab <- "Reference migration time (MT)"
    } else if(align_mode == "loess"){
      xlab <- "Reference migration time (MT)"
    } else {
      xlab <- "Migration time (MT)"
    }
    
    if(imetabid != ""){
      ephe_info_ref <-
        .self$ref$get_ephe_info_from_metabid(imetabid)
      ephe_ref <- ephe_info_ref$ephe # Could be NULL
      peak_ref <- ephe_info_ref$pk   # Could be NULL
      if(is.null(peak_ref)){
        peak_ref_range <- NULL
        peak_ref_top   <- NULL
        plot_title     <- ""
      } else {
        peak_ref_range <- peak_ref$get_mt_range()
        peak_ref_top   <- peak_ref$get_intensity_top()
        
        if(!is.na(annot_name) && length(annot_name)){
          plot_title <- sprintf("[ m/z: %.4f ] %s: %s",
                                ephe_ref$mz, imetabid, annot_name)
        } else {
          plot_title <- sprintf("[ m/z: %.4f ] %s",
                                ephe_ref$mz, imetabid)
        } 
      }
    } else {
      ephe_ref <-
        .self$ref$find_ephe_mz(imz, imax_diff_mz, ippm)
      if(!is.null(ephe_ref)){
        peak_ref_range <- ephe_ref$get_mt_range()
        peak_ref_top   <- max(ephe_ref$get_intstis()) 
        plot_title     <- sprintf("[ m/z: %.4f ] ~%.4f", ephe_ref$mz, mz)
      } else {
        peak_ref_range <- NULL
        peak_ref_top   <- NULL
        plot_title     <- ""
      }
    }

    peak_ranges_messed <- peak_ref_range
    peak_intsty_tops   <- peak_ref_top

    for(i in 1:length(.self$smp_l)){
      smp  <- .self$smp_l[[ i ]] # .self$refsmp_pairs_l[[ i ]]$smp 
      pair <- .self$refsmp_pairs_l[[ i ]]
      
      if(imetabid != ""){
        ephe_info_smp <-
          smp$get_ephe_info_from_metabid(imetabid)
        ephe_smp <- ephe_info_smp$ephe
        peak_smp <- ephe_info_smp$pk
        if(is.null(peak_smp)){
          peak_smp_range     <- NULL
          peak_smp_top       <- NULL
          peak_smp_range_adj <- NULL
        } else {
          peak_smp_range     <- peak_smp$get_mt_range()
          peak_smp_top       <- peak_smp$get_intensity_top()
          
          if(plot_title == ""){
            if(!is.na(annot_name) && length(annot_name)){
              plot_title <- sprintf("[ m/z: %.4f ] %s: %s",
                                    ephe_smp$mz, imetabid, annot_name)
            } else {
              plot_title <- sprintf("[ m/z: %.4f ] %s",
                                    ephe_smp$mz, imetabid)
            }
          }
          
        }
        
      } else {
        ephe_smp <- 
          smp$find_ephe_mz(imz, imax_diff_mz, ippm)
        if(!is.null(ephe_smp)){
          peak_smp_range <- ephe_smp$get_mt_range()
          peak_smp_top   <- max(ephe_smp$get_intstis())
          
          if(plot_title == ""){
            plot_title <- sprintf("[ m/z: %.4f ] ~%.4f",
                                  ephe_smp$mz, mz)
          }
          
        } else {
          peak_smp_range     <- NULL
          peak_smp_top       <- NULL
          peak_smp_range_adj <- NULL
        }
        
        
      }
          
      if(!is.null(peak_smp_range)){
          
        if(align_mode == "reijenga"){
          peak_smp_range_adj <- pair$map_to_ref(peak_smp_range)
        } else if(align_mode == "loess"){
          peak_smp_range_adj <-
            pair$smm_unalign_to_ref_unalign_mts(peak_smp_range)
        } else {
          peak_smp_range_adj <- peak_smp_range
        }
        
      }

      peak_ranges_messed <-
        c(peak_ranges_messed, peak_smp_range_adj)
      peak_intsty_tops   <- c(peak_intsty_tops,
                              peak_smp_top)
      
    }
    
    if(length(peak_ranges_messed) == 0){ return }
  
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
        max(peak_intsty_tops) * (1+extra_rate_intsty)
      ylim <- c(0, intsty_extra)
      
    }

    if(is.null(ephe_ref) && !is.na(mz)){
      ephe_ref <- .self$ref$find_ephe_mz(mz)
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
    }
    
    cols_smp <- 
      rep(cols_smp,
          ceiling(length(.self$smp_l) / length(cols_smp)))[ 1:length(.self$smp_l) ]
    
    for(i in 1:length(.self$smp_l)){
      smp  <- .self$smp_l[[ i ]]
      pair <- .self$refsmp_pairs_l[[ i ]]
      ephe_smp <- NULL
      if(imetabid != ""){
        ephe_info_smp <-
          smp$get_ephe_info_from_metabid(imetabid)
        ephe_smp <- ephe_info_smp$ephe
      }
      if(is.null(ephe_smp) && !is.na(mz)){
        ephe_smp <- smp$find_ephe_mz(mz)
      }
      
      if(!is.null(ephe_smp)){
        
        if(plot_exist){ par(new=T) }
        

        if(align_mode == "reijenga"){
          mts <- pair$map_to_ref(ephe_smp$get_mts())
        } else if(align_mode == "loess"){
          mts <-
            pair$smm_unalign_to_ref_unalign_mts(ephe_smp$get_mts())
        } else {
          mts <- ephe_smp$get_mts()
        }        
        
        ephe_smp$plot_res_find_peak_simple(
          col = cols_smp[ i ],
          mts = mts,
          xlim = xlim, ylim = ylim,
          xlab = xlab,
          ylab = "Intensity",
          main = plot_title,
          ann = F)
        plot_exist <- TRUE
      }
      
    }
      
    par(new=F) 
    
    legend("topleft",
           legend = c(.self$ref$samplenam,
                      sapply(.self$smp_l,
                             function(tmpsmp){ tmpsmp$samplenam })),
           col    = c(col_ref, cols_smp),
           lty    = 1)
    
                              
  })


RefSampPairSet$methods(calc_adjust_mt_pairs_xcms =
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
  tmppairset$plot_peak_in_ephe("P003")
  tmppairset$plot_peak_in_ephe(imz = 182.05)
    
}


