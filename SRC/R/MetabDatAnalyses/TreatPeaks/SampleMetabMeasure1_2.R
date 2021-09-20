
source.RS("MetabDatAnalyses/TreatPeaks/MetabBatchSimple2_1.R")
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")

# For unit test, rsunit_test_SampleMetabMeasure <- T and source it.

SampleMetabMeasure <-
  setRefClass("SampleMetabMeasure",
    fields = list(
      batch     = "MetabBatchSimple",
      datfilnam = "character",
      samplenam = "character",
      ephe_list = "list",
      ephe_mzs  = "numeric",
      annotlist = "AnnotList",
      h         = "list"
    ))

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

SampleMetabMeasure$methods(find_ephe_mz =
  function(imz, max_diff_mz = 0.1){

    diffs_mz <- .self$ephe_mzs - imz
    idx_min <- which.min(abs(diffs_mz))
    if(abs(diffs_mz[ idx_min ]) <= max_diff_mz){
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
    ephe <- .self$find_ephe_mz(mz, max_diff_mz = 0)
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
            "MetabolomeGeneral", "AnnotationList",
            "C_114_annotlist_160809-2_RSC1.csv")
  
  tmpmhannotlist1 <- AnnotList(tmp_annotlist_file1)  
  tmpispks <- tmp_smm$find_IS_marks(tmpmhannotlist1)
  
  # pks_l <- tmp_smm$get_peaks()
  # sapply(pks_l, function(tmppk){ tmppk$mt_top })
  # sapply(pks_l, function(tmppk){ tmppk$epherogram_obj$mz })
  # sapply(pks_l, function(tmppk){ tmppk$h$zscore })
  
  
}
