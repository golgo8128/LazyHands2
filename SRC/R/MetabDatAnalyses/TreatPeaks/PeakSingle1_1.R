
source.RS("MetabDatAnalyses/TreatPeaks/Epherogram1_2.R")

# For unit test, rsunit_test_PeakSingle <- T and source it.

# Loops with EPherogram ... printing the object will result in stack exhaustion

PeakSingle <-
  setRefClass("PeakSingle",
              fields = list(
                epherogram_obj = "EPherogram",
                p_start        = "numeric",
                p_end          = "numeric",
                p_top          = "numeric",
                mt_start       = "numeric",
                mt_end         = "numeric",
                mt_top         = "numeric",
                peak_annot_id  = "character",
                h              = "list"
                   # score, baseline intensity,
                   #    surrounding baseline region,
                   #    internal_std_flag, etc.
              ))

PeakSingle$methods(initialize =
  function(iepherogram_obj = NULL,
           istart_pos      = NA,
           iend_pos        = NA){
    
    if(!is.null(iepherogram_obj)){
      .self$epherogram_obj <- iepherogram_obj
    }                   
    
    .self$p_start <- istart_pos
    .self$p_end   <- iend_pos
    
    if(!is.null(iepherogram_obj) && !is.na(istart_pos) && !is.na(iend_pos)){
      .self$mt_start <- iepherogram_obj$get_mts()[ istart_pos ]
      .self$mt_end   <- iepherogram_obj$get_mts()[ iend_pos ]
      .self$p_top    <- .self$get_p_top()
      .self$mt_top   <- .self$get_top_mt()
    }
    
    .self$peak_annot_id <- "" # Better than character(0) for sprintf function.
    
})

PeakSingle$methods(get_intensity_top =
  function(){
                       
    intsty <- .self$epherogram_obj$get_intstis()
    return(max(intsty[ .self$p_start : .self$p_end ]))
                       
  })


PeakSingle$methods(get_p_top =
  function(){
                       
    intsty <- .self$epherogram_obj$get_intstis()
    return(which.max(intsty[ .self$p_start : .self$p_end ]) + .self$p_start - 1)

  })



PeakSingle$methods(get_top_mt =
  function(){
    
    max_pos <- .self$get_p_top()
    return(.self$epherogram_obj$get_mts()[ max_pos ])

  })

PeakSingle$methods(get_mt_range =
  function(){

    return(c(.self$mt_start, .self$mt_end))
    
})

PeakSingle$methods(plot_peak_single =
  function(...){
                       
    mts <- .self$epherogram_obj$get_mts()
    ity <- .self$epherogram_obj$get_intstis()
                       
    plot(mts, ity, type = "l", ...)
                       
    points(mts[ .self$p_start ],
           ity[ .self$p_start ], col = "red", cex = 2, pch = "<")
    points(mts[ .self$p_end ],
           ity[ .self$p_end ], col = "red", cex = 2, pch = ">")
    points(mts[ .self$p_top ],
           ity[ .self$p_top ], col = "red", cex = 2, pch = "*")
                         
  })

PeakSingle$methods(show =
                     function(){
  
  l_main <- list(
    peak_annot_id  = .self$peak_annot_id,
    p_start  = .self$p_start,
    p_end    = .self$p_end,
    p_top    = .self$p_top,
    mt_start = .self$mt_start,
    mt_end   = .self$mt_end,
    mt_top   = .self$mt_top,
    h              = .self$h
    )
  
  # print(l_main)
  
  cat(sprintf("### Peak annotation ID: %s ###\n", .self$peak_annot_id))
  cat(sprintf("m/z of electropherogram: %f\n",
              .self$epherogram_obj$mz))
  cat(sprintf("Peak MT range (top): %f - %f (%f)\n",
              .self$mt_start, .self$mt_end, .self$mt_top))
  cat(sprintf("Peak index range (top): %d - %d (%d)\n",
              .self$p_start, .self$p_end, .self$p_top))
  # cat("\n")
  
})

if(exists("rsunit_test_PeakSingle") &&
   rsunit_test_PeakSingle){
  
  
  tmp_intsty <-
    c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
      2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
      3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
      4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
      0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
      2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
      3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
      3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1)
  
  tmp_mt <- 1:length(tmp_intsty) / 2
  
  tmp_ephe_mat <- cbind(tmp_mt, tmp_intsty)
  
  tmp_ephe <- EPherogram(tmp_ephe_mat)
  tmp_ephe$find_bulk_peaks(izscore_peak_thres = 3,
                           ipeak_width_range = c(3, 120))
  print(tmp_ephe$get_peak_mt_mat())
  print(tmp_ephe$get_peak_mt_mat_highest_intsty())
  tmp_ephe$plot_res_find_peak_simple()
  
  peak_sing <- PeakSingle(tmp_ephe, 50, 100)
  
}

