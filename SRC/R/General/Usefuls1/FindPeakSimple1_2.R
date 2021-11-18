
source.RS("Usefuls1/consec_hits1.R")
# source.RS("Usefuls1/count_max_val_updates1.R")
source.RS("DataStruct1/merge_lists1_1.R")

# For unit test, rsunit_test_FindPeakSimple <- T and source this.

find_peak_valley <- function(ivec, inc_or_sustain = TRUE){
  
  vec_diff_nei <- diff(ivec)
  if(inc_or_sustain){
    inc_bool <- vec_diff_nei >= 0
  } else {
    inc_bool <- vec_diff_nei > 0
  }
  peak_valley_poss <- head(cumsum(rle(inc_bool)$lengths) + 1, -1)
  peak_type_bool   <- diff(rle(inc_bool)$values) < 0
  
  return(list(
    peak_valley_poss = peak_valley_poss, # Peak and valley
    peak_type_bool   = peak_type_bool    # T: peak, F: valley.
                                         # Same length as above
              ))
  
}



FindPeakSimple <-
  setRefClass("FindPeakSimple",
              fields = list(
                ivec                = "numeric",
                zscore_peak_thres   = "numeric",
                zscore_signal_thres = "numeric",
                split_peak_drop_rate_thres     = "numeric",
                split_peak_rerise_rate_thres   = "numeric",
                # split_peak_top_update_ct_thres = "numeric",
                split_peak_rerise_factor_thres = "numeric",
                res                 = "list",
                verbose_level       = "numeric"
              ))

# FindPeakSimpleSingleRes <-
#   setRefClass("FindPeakSimpleSingleRes",
#               fields = list(
#                 findpeaksimple = "FindPeakSimple"  
#               ))


FindPeakSimple$methods(initialize =
  function(ivec,
           izscore_peak_thres, 
           izscore_signal_thres = 1.645,
           imean = NULL, isd = NULL,
           split_peak_drop_rate_thres     = 0.5,
           split_peak_rerise_rate_thres   = 0.5,
           # split_peak_top_update_ct_thres = 5,
           split_peak_rerise_factor_thres = 5
           ){
    
    .self$verbose_level <- 0
    
    .self$zscore_peak_thres              <- izscore_peak_thres
    .self$zscore_signal_thres            <- izscore_signal_thres
    .self$split_peak_drop_rate_thres     <- split_peak_drop_rate_thres
    .self$split_peak_rerise_rate_thres   <- split_peak_rerise_rate_thres
    # .self$split_peak_top_update_ct_thres <- split_peak_top_update_ct_thres
    .self$split_peak_rerise_factor_thres <- split_peak_rerise_factor_thres
    
    if(any(is.na(ivec)) || any(is.nan(ivec))){
      stop("[ ERROR ] NA or NaN found in the vector intended for peak detection.")
    }
    
    .self$ivec <- ivec
    
    if(is.null(imean) || is.null(isd)){
      imean = mean(ivec)
      isd   = sd(ivec)
    }
    
    .self$res$zscore_vec <- (ivec - imean) / isd
    # Note that z-score is distributed towards both sides whereas most of
    # intensities are distributed one-side.
    
    .self$res$peak_valley <- find_peak_valley(ivec)
    # $peak_valley_poss : Peak and valley
    # $peak_type_bool   : peak_type_bool # T: peak, F: valley.
    # The lengths of the above two vectors are the same.
    
    sig_vec <- .self$res$zscore_vec > izscore_signal_thres
    peak_poss <- NULL
    
    if(sum(sig_vec)){
      
      sig_poss <- consec_true_positions(sig_vec)
      
      
      for(i in 1:nrow(sig_poss)){
        start_pos <- as.vector(sig_poss[i, 1])
        end_pos   <- as.vector(sig_poss[i, 2])
        zscore_segm <- .self$res$zscore_vec[ start_pos : end_pos ]
        if(max(zscore_segm) > izscore_peak_thres){
          peak_poss <-
            rbind(peak_poss,
                  .self$divide_peak(start_pos, end_pos))
        }
      }
      
    }
    
    .self$res$peak_poss <- peak_poss
    .self$peak_poss_add_top_pos()

  })


FindPeakSimple$methods(get_peak_poss = 
  function(){

    return(.self$res$peak_poss)
    
  })


FindPeakSimple$methods(peak_poss_add_top_pos = 
  function(){
    
    peak_poss   <- .self$res$peak_poss
    
    top_poss    <- NULL
    top_zscores <- NULL
    
    for(i in 1:nrow(peak_poss)){
      start_pos   <- as.vector(peak_poss[i, 1])
      end_pos     <- as.vector(peak_poss[i, 2])
      zscore_segm <- .self$res$zscore_vec[ start_pos : end_pos ]
      top_poss    <- c(top_poss,
                       as.vector(which.max(zscore_segm) + start_pos - 1))
      top_zscores <- c(top_zscores, max(zscore_segm))
    }
    
    peak_poss <- cbind(peak_poss, top_poss, top_zscores)
    colnames(peak_poss) <-
      c("start", "end", "top", "zscore")
    
    .self$res$peak_poss <- peak_poss   
    
  })


FindPeakSimple$methods(divide_peak =
  function(peak_left_limit, peak_right_limit){
    
    split_poss <-
      c(peak_left_limit,
        .self$get_split_poss(peak_left_limit,
                             peak_right_limit,
                             cur_peak_top_pos = NULL),
        peak_right_limit)

    # split_poss will be peak dividing positions
    # ex. c(10, 15, 18, 20)
    # Then, 10 - 15, 15 - 18, 18 - 20 will be returned.
    return(cbind(head(split_poss, -1),
                 tail(split_poss, -1)))
    
  })



FindPeakSimple$methods(get_split_poss =
  function(peak_left_limit, peak_right_limit,
           cur_peak_top_pos = NULL){
    

    if(is.null(cur_peak_top_pos)){
      cur_peak_top_pos <-
        which.max(.self$ivec[peak_left_limit:peak_right_limit]) + peak_left_limit - 1
    }
    
    if(.self$verbose_level > 1){
      cat(sprintf("Running into %d - %d (%d)\n",
                  peak_left_limit, peak_right_limit, cur_peak_top_pos))
    }
    
    left_split_pos <-
      .self$check_peak_split(
        peak_left_limit, peak_right_limit,
        right_mode = FALSE,
        cur_peak_top_pos = cur_peak_top_pos)
    right_split_pos <-
      .self$check_peak_split(
        peak_left_limit, peak_right_limit,
        right_mode = TRUE,
        cur_peak_top_pos = cur_peak_top_pos)
    
    if(.self$verbose_level > 1){
      cat("Split result left:\n")
      print(left_split_pos)
      cat("Split result right:\n")
      print(right_split_pos)
    }
    
    if(!is.null(left_split_pos)){
      left_split_poss <-
        c(get_split_poss(peak_left_limit, left_split_pos),
          left_split_pos)
      middle_peak_left_limit <- left_split_pos
    } else {
      left_split_poss <- NULL
      middle_peak_left_limit <- peak_left_limit
    }
    
    if(!is.null(right_split_pos)){
      right_split_poss <-
        c(right_split_pos,
          get_split_poss(right_split_pos, peak_right_limit))
      middle_peak_right_limit <- right_split_pos
    } else {
      right_split_poss <- NULL
      middle_peak_right_limit <- peak_right_limit
    }
    
    if(peak_left_limit == middle_peak_left_limit &&
       peak_right_limit == middle_peak_right_limit){
      middle_split_poss <- NULL
    } else {
      middle_split_poss <-
        get_split_poss(middle_peak_left_limit, middle_peak_right_limit,
                       cur_peak_top_pos)
    }
    
    if(.self$verbose_level > 1){
      cat(sprintf("Getting out of %d - %d (%d)\n",
                  peak_left_limit, peak_right_limit, cur_peak_top_pos))
      cat("All split result left:\n")
      print(left_split_poss)
      cat("All split result middle:\n")
      print(middle_split_poss)
      cat("All split result right:\n")
      print(right_split_poss)
    }
    
    return(c(left_split_poss, middle_split_poss, right_split_poss))
    
  })


FindPeakSimple$methods(check_peak_split =
  function(peak_left_limit, peak_right_limit,
           right_mode,
           cur_peak_top_pos = NULL){
  
  vals_vec <- .self$ivec # Should this be .self$res$zscore_vec ?
      
  pv <- .self$res$peak_valley

  if(is.null(cur_peak_top_pos)){
    cur_peak_top_pos <-
      which.max(vals_vec[peak_left_limit:peak_right_limit]) + peak_left_limit - 1
  }
  
  # Caution: Peak may be truncated with the following procedure.
  if(right_mode){
  
    scan_peak_valley_pos <-
      pv$peak_valley_poss[ cur_peak_top_pos < pv$peak_valley_poss &
                             pv$peak_valley_poss <= peak_right_limit ]
    scan_peak_type_bool  <-
      pv$peak_type_bool[ cur_peak_top_pos < pv$peak_valley_poss &
                             pv$peak_valley_poss <= peak_right_limit ]
  } else {
    
    scan_peak_valley_pos <-
      rev(pv$peak_valley_poss[ peak_left_limit <= pv$peak_valley_poss &
                                pv$peak_valley_poss < cur_peak_top_pos ])
      # Reversed.
    scan_peak_type_bool  <-
      rev(pv$peak_type_bool[ peak_left_limit <= pv$peak_valley_poss &
                                pv$peak_valley_poss < cur_peak_top_pos ])
      # Reversed.
  }
  
  while(length(scan_peak_valley_pos) && scan_peak_type_bool[1] == T){
    # Trim end terminal until last element is valley.
    scan_peak_valley_pos <- tail(scan_peak_valley_pos, -1)
    scan_peak_type_bool  <- tail(scan_peak_type_bool,  -1)
  }
  # scan_peak_type_bool[1] == F (valley) expected. i.e. F, T, F, T, F, T, ...
  
  scan_valley_poss <- scan_peak_valley_pos[ !scan_peak_type_bool ]
  scan_peak_poss   <- scan_peak_valley_pos[ scan_peak_type_bool ]
  # scan_valley_pos[1] < scan_peak_pos[1] is expected for right_mode = T
  
  
  
  # cat("Scan valley positions:\n")
  # print(scan_valley_poss)
  # cat("Scan peak positions:\n")
  # print(scan_peak_poss)
  
  if(length(scan_valley_poss) == 0 || length(scan_peak_poss) == 0){
    return(NULL)
  }

  cur_top_height <- vals_vec[ cur_peak_top_pos ]
  
  split_pos <- NULL
  max_peak_ratio <- 0
  
  if(.self$verbose_level > 0){
    cat(sprintf("[ Split scanning region %d - %d ] right mode: %s ",
                peak_left_limit, peak_right_limit,
                as.character(right_mode)))
    cat(sprintf("Top position: %d\n", cur_peak_top_pos))  
  }
    
  for(i in 1:length(scan_valley_poss)){
    
    scan_valley_pos <- scan_valley_poss[i]
    valley_height   <- vals_vec[ scan_valley_pos ]
    
    if(length(scan_peak_poss) >= i){
      for(j in i:length(scan_peak_poss)){
        
        scan_peak_pos    <- scan_peak_poss[j]
        next_peak_height <- vals_vec[ scan_peak_pos ]
        
        drop_rate     <- (cur_top_height - valley_height) / cur_top_height
        rerise_rate   <- (next_peak_height - valley_height) / (cur_top_height - valley_height)
        rerise_factor <- next_peak_height / valley_height
        # valley_height must be sufficiently high (higher than signal threshold)
        
        # top_update_ct <-
        #    count_max_val_updates(vals_vec[ scan_valley_pos : scan_peak_pos ])
        
        peak_ratio <- min(
          drop_rate,
          # (next_peak_height - valley_height) / next_peak_height,
          rerise_rate)
        
        if(.self$verbose_level > 0){
          cat(sprintf("Valley pos: %d  Next peak pos: %d  ",
                      scan_valley_pos, scan_peak_pos))
          cat(sprintf("drop_rate: %f  rerise rate: %f  rerise_factor: %f  top-update count: %d\n",
                      drop_rate, rerise_rate, rerise_factor, top_update_ct))
        }

        if(peak_ratio > max_peak_ratio &&
          drop_rate >= .self$split_peak_drop_rate_thres && (
          rerise_rate >= .self$split_peak_rerise_rate_thres || 
            rerise_factor >= .self$split_peak_rerise_factor_thres) # &&
            # top_update_ct >= .self$split_peak_top_update_ct_thres
            # count_max_val_updates(vals_vec[ scan_valley_pos : scan_peak_pos ])
            #   >= .self$split_peak_top_update_ct_thres # <-- faster than calculating every time
          ){

          split_pos <- scan_valley_pos
          max_peak_ratio <- peak_ratio
          if(.self$verbose_level > 0){
            cat("!!! Temporal split !!!\n")
          }
          
        }
      }
    }
    
  }  
  
  return(split_pos)
  
})



FindPeakSimple$methods(plot_res_find_peak_simple =
  function(...){
  
    default_varargs <- 
      list(x = .self$ivec,
           # col  = col,
           type = "l",
           # ylim = ylim,
           # xlab = "Migration time (MT)",
           ylab = "Value" # ,
           # main = sprintf("Electropherogram of %f", .self$mz)
           )
    ivarargs_l      <- list(...)
    
    do.call(plot, merge_two_lists(default_varargs,
                                  ivarargs_l))

    for(i in 1:nrow(.self$res$peak_poss)){
      
      points(.self$res$peak_poss[ i, "start" ],
             .self$ivec[ .self$res$peak_poss[ i, "start" ] ],
             col = "red", cex = 2, pch = "<")
      points(.self$res$peak_poss[ i, "end" ],
             .self$ivec[ .self$res$peak_poss[ i, "end" ] ],
             col = "red", cex = 2, pch = ">")
      points(.self$res$peak_poss[ i, "top" ],
             .self$ivec[ .self$res$peak_poss[ i, "top" ] ],
             col = "red", cex = 2, pch = "*")
      
    }
  
})


# Unit test
if(exists("rsunit_test_FindPeakSimple") &&
   rsunit_test_FindPeakSimple){
 
   tmp_vec1 <- c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
                 2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
                 3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
                 4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
                 0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
                 2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
                 3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
                 3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1)
   
   tmp_vec1 <- c(0,0,0,1,2,5,6,19,6,3,5,6,8,6,9,4,6,10,5,2,3,2,1,0,0,0)
   
  
   tmp_fps1 <-
     FindPeakSimple(ivec = tmp_vec1,
                    izscore_peak_thres   = 2.0,
                    izscore_signal_thres = 1.645,
                    imean = 1, isd = 1,
                    split_peak_rerise_factor_thres = 3)
   
   tmp_fps1$plot_res_find_peak_simple()
   
}

