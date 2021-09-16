
source.RS("Usefuls1/find_peak_simple1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_2.R")

# For unit test, rsunit_test_EPherogram <- T and source it.

EPherogram <-
  setRefClass("EPherogram",
              fields = list(
                epherogram = "matrix",
                mz         = "numeric",
                sampmmeasr = "SampleMetabMeasure",
                peak_list  = "list",
                h          = "list" # ex. zscore
              ))

EPherogram$methods(initialize =
  function(iepherogram = matrix(),
           imz = as.numeric(NA)){

    .self$epherogram = iepherogram
    .self$mz         = imz
    
  })


EPherogram$methods(show =
  function(){
    
    cat(sprintf("##### Electropherogram - m/z: %f #####\n", .self$mz))
    cat(sprintf("MT range: %f - %f\n",
                .self$epherogram[1, 1], .self$epherogram[nrow(.self$epherogram), 1]))
    cat(sprintf("Peaks:\n"))
    print(.self$peak_list)
    cat("\n")
    
  })


EPherogram$methods(set_ephe =
  function(iepherogram){
    .self$epherogram = iepherogram   
  })

EPherogram$methods(set_mz =
  function(imz){
    .self$mz = imz   
  })


EPherogram$methods(get_mts =
  function(){
    return(.self$epherogram[,1])
  })

EPherogram$methods(get_intstis =
  function(){
    return(.self$epherogram[,2])
})

EPherogram$methods(get_mt_range =
  function(){
    
    mts <- .self$get_mts()
    return(c(mts[1], tail(mts, n=1)))
    
  })

EPherogram$methods(find_bulk_peaks = 
  function(ictrl_range_mt = c(2,5)*60,
           ipeak_width_range = c(1, 120), # Can be Inf
           izscore_peak_thres = 3,
           izscore_signal_thres = 1.645,
           split_peak_ratio_thres = 0.5){

    source.RS("MetabDatAnalyses/TreatPeaks/PeakSingle1_1.R", reload = F)
    
    imt     <- .self$get_mts()
    iintsty <- .self$get_intstis()
    
    ctrl_bool <- ictrl_range_mt[1] <= imt & imt <= ictrl_range_mt[2]
    ctrl_mean <- mean(iintsty[ ctrl_bool ])
    ctrl_sd   <- sd(iintsty[ ctrl_bool ])
    
    ctrl_range_ok <- TRUE
    
    if(is.na(ctrl_sd) || ctrl_sd == 0){
      # iintsty_for_ctrl <- iintsty[ 0 < iintsty &
      #                                iintsty <= quantile(iintsty[ iintsty > 0 ],
      #                                                    probs = 0.25) ]
      ctrl_mean <- 0 # mean(iintsty_for_ctrl)
      ctrl_sd   <- 1 # sd(iintsty_for_ctrl)
      ctrl_range_ok <- FALSE
    }
    
    if(!is.na(ctrl_sd) && ctrl_sd > 0){
      pk_info <- 
        find_peak_simple(
          iintsty,
          izscore_peak_thres, 
          izscore_signal_thres = izscore_signal_thres,
          imean = ctrl_mean, isd = ctrl_sd,
          split_peak_ratio_thres = split_peak_ratio_thres)
      
      for(pk_pos in pk_info$peak_poss_l){
        mt_start <- imt[ pk_pos$start_pos ]
        mt_end   <- imt[ pk_pos$end_pos ]
        mt_diff  <- mt_end - mt_start
        if(ipeak_width_range[1] <= mt_diff && mt_diff < ipeak_width_range[2]){
          pk_single <- PeakSingle(.self, pk_pos$start_pos, pk_pos$end_pos)
          pk_single$h$zscore  <- pk_pos$top_zscore
          .self$peak_list <-
            c(.self$peak_list, pk_single)
        }
      }
    }

    .self$h$ctrl_range_ok <- ctrl_range_ok
          
  })


EPherogram$methods(get_peaks =
  function(imt_range = NULL){

        pks <- list()
        for(pk in .self$peak_list){
          
          if((is.null(imt_range)) ||
            (imt_range[1] <= pk$mt_top && pk$mt_top < imt_range[2])){
            pks <- c(pks, pk)
          }
          
        }
        
        return(pks)
  })

EPherogram$methods(get_peak_from_metabid =
  function(imetabid){
    
    for(pk in .self$peak_list){
      if(length(pk$peak_annot_id) &&
         pk$peak_annot_id == imetabid){
        return(pk)
      }
    }
    
    return(NULL)
                         
  })

EPherogram$methods(get_peak_mt_mat =
  function(imt_range = NULL){
   
    if(length(.self$peak_list)){
      omat <-
        t(sapply(.self$peak_list,
                 function(tmpl){ c(tmpl$mt_start, tmpl$mt_end,
                                   tmpl$mt_top, tmpl$h$zscore)}))
      
      colnames(omat) <- c("MT start", "MT end", "MT top", "z-score")

      if(!is.null(imt_range)){
        omat <- omat[ imt_range[1] <= omat[,"MT top"]
                      & omat[,"MT top"] < imt_range[2], ,
                      drop=F ]
      }
    } else {
      
      omat <- matrix(NA, ncol = 4, nrow = 0)
      colnames(omat) <- c("MT start", "MT end", "MT top", "z-score")
      
    }
      
    return(omat)
    
  })


EPherogram$methods(get_peak_mt_dfrm =
  function(imt_range = NULL){
                       
    if(length(.self$peak_list)){
      omat <-
        t(sapply(.self$peak_list,
                 function(tmpl){ c(tmpl$mt_start, tmpl$mt_end,
                                   tmpl$mt_top, tmpl$h$zscore)}))
      ometabids <-
        sapply(.self$peak_list,
               function(tmpl){ tmpl$peak_annot_id })
      
      odfrm <- data.frame(omat, annot_id = ometabids)
      
      colnames(odfrm) <-
        c("MT start", "MT end", "MT top", "z-score", "Annotation ID")
      
      if(!is.null(imt_range)){
        odfrm <- odfrm[ imt_range[1] <= odfrm[,"MT top"]
                      & odfrm[,"MT top"] < imt_range[2], ,
                      drop=F ]
      }
    } else {
      
      omat <- matrix(NA, ncol = 5, nrow = 0)
      colnames(omat) <-
        c("MT start", "MT end", "MT top", "z-score",
          "Annotation ID")
      odfrm <- as.data.frame(omat)
      odfrm$`Annotation ID` <- as.factor(odfrm$`Annotation ID`)
      
    }
    
    return(odfrm)
                       
  })



                       
EPherogram$methods(get_peak_mt_mat_highest_intsty =
  function(imt_range = NULL){

    mat <- .self$get_peak_mt_mat(imt_range)
    if(nrow(mat)){
      return(mat[which.max(mat[, "z-score"]),])
    } else{
      omat <- rep(NA, ncol(mat))
      names(omat) <- colnames(mat)
      return(omat)
    }
        
  })


EPherogram$methods(get_peak_mt_mat_nearest_mt =
  function(itarget_mt, imt_range = NULL){
                       
    mat <- .self$get_peak_mt_mat(imt_range)
    if(nrow(mat)){
      mt_diff <- mat[, "MT top"] - itarget_mt
      return(mat[which.min(abs(mt_diff)), ])
    } else{
      omat <- rep(NA, ncol(mat))
      names(omat) <- colnames(mat)
      return(omat)
    }
    
  })


EPherogram$methods(plot_res_find_peak_simple =
  function(mts = NULL, col = "red", ...){
    
    if(is.null(mts)){
      mts <- .self$get_mts()
    }
    
    ity <- .self$get_intstis()
                       
    plot(mts, ity, col = col, type = "l", ...)
    
    for(pkobj in .self$peak_list){
      
      # points(mts[ pkobj$p_start ],
      #        ity[ pkobj$p_start ], col = "red", cex = 2, pch = "<")
      # points(mts[ pkobj$p_end ],
      #        ity[ pkobj$p_end ], col = "red", cex = 2, pch = ">")
      
      lines(mts[ pkobj$p_start : pkobj$p_end ],
            ity[ pkobj$p_start : pkobj$p_end ], lwd = 3, col = col)
      
      points(mts[ pkobj$p_top ],
             ity[ pkobj$p_top ], col = col, cex = 2, pch = "*")
      
      if(length(pkobj$peak_annot_id)){
        text(mts[ pkobj$p_top ], ity[ pkobj$p_top ],
             pkobj$peak_annot_id, pos = 3, col = col)
      }
      
    }
    
    
  })

EPherogram$methods(get_peak_highest_score =
                     function(imt_range = NULL,
                              scorenam = "zscore"){

    pks <- .self$get_peaks(imt_range)
    if(length(pks) > 0){
      scores <-
        sapply(pks, function(tmppk){ tmppk$h[[ scorenam ]] } )
      return(pks[[ which.max(scores) ]])
    } else {
      return(NULL)
    }
    
  })


if(exists("rsunit_test_EPherogram") &&
   rsunit_test_EPherogram){
  
  tmp_intsty <-
    c(rep(c(0,1,2,1,2,1,0,1,1,1), 70),
      c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
        4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
        0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,12,8,7,6,5,5,
        3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1))
  
  tmp_mt <- 1:length(tmp_intsty) / 2
  
  tmp_ephe_mat <- cbind(tmp_mt, tmp_intsty)
  
  tmp_ephe <- EPherogram(tmp_ephe_mat)
  tmp_ephe$set_mz(110.3)
  tmp_ephe$find_bulk_peaks(izscore_peak_thres = 3,
                           ipeak_width_range = c(3, 120))
  print(tmp_ephe$get_peak_mt_mat())
  print(tmp_ephe$get_peak_mt_mat_highest_intsty())
  tmp_ephe$plot_res_find_peak_simple()

  
}



