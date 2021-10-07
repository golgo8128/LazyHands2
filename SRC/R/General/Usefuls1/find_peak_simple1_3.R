
source.RS("Usefuls1/consec_hits1.R")

# For unit test, rsunit_test_find_peak_simple <- T and source this.

find_peak_simple <- function(ivec,
                             izscore_peak_thres, 
                             izscore_signal_thres = 1.645,
                             imean = NULL, isd = NULL,
                             split_peak_ratio_thres = 0.5){
    
  if(any(is.na(ivec)) || any(is.nan(ivec))){
      stop("[ ERROR ] NA or NaN found in the vector intended for peak detection.")
  }
  
  if(is.null(imean) || is.null(isd)){
    imean = mean(ivec)
    isd   = sd(ivec)
  }
  
  zscore_vec <- (ivec - imean) / isd
  # Note that z-score is distributed towards both sides whereas most of
  # intensities are distributed one-side.

  no_peak <-
    list(peak_poss_l = list(),
         zscores     = zscore_vec,
         vec         = ivec)
  
  sig_vec <- zscore_vec > izscore_signal_thres
  if(sum(sig_vec) == 0){
    return(no_peak)
  }
  
  sig_poss <- consec_true_positions(sig_vec)

  peak_poss <- NULL
  for(i in 1:nrow(sig_poss)){
    start_pos <- as.vector(sig_poss[i, 1])
    end_pos   <- as.vector(sig_poss[i, 2])
    zscore_segm <- zscore_vec[ start_pos : end_pos ]
    if(max(zscore_segm) > izscore_peak_thres){
      peak_poss <-
        rbind(peak_poss,
              divide_peak(zscore_vec, # Instead of ivec
                          start_pos, end_pos,
                          split_peak_ratio_thres = split_peak_ratio_thres))
    }
  }
  
  if(is.null(peak_poss)){
    return(no_peak)
  }
  
  ct <- 1
  peak_poss_l <- list()
  for(i in 1:nrow(peak_poss)){
      start_pos <- as.vector(peak_poss[i, 1])
      end_pos   <- as.vector(peak_poss[i, 2])
      zscore_segm <- zscore_vec[ start_pos : end_pos ]
      peak_poss_l[[ ct ]] <- 
        list(start_pos = start_pos,
             end_pos   = end_pos,
             top_pos   = as.vector(which.max(zscore_segm) + start_pos - 1),
             top_zscore = max(zscore_segm))
      ct <- ct + 1
  }
    
  return(list(peak_poss_l = peak_poss_l,
              zscores  = zscore_vec,
              vec      = ivec))
  
}


plot_res_find_peak_simple <- function(ires){

  plot(ires$vec, type = "l")
  
  for(each_peak_l in ires$peak_poss_l){
    
    points(each_peak_l$start_pos,
           ires$vec[ each_peak_l$start_pos ], col = "red", cex = 2, pch = "<")
    points(each_peak_l$end_pos,
           ires$vec[ each_peak_l$end_pos ], col = "red", cex = 2, pch = ">")
    points(each_peak_l$top_pos,
           ires$vec[ each_peak_l$top_pos ], col = "red", cex = 2, pch = "*")

  }
  
}

find_peak_valley <- function(ivec, inc_or_sustain = TRUE){
  
  vec_diff_nei <- diff(ivec)
  if(inc_or_sustain){
    inc_bool <- vec_diff_nei >= 0
  } else {
    inc_bool <- vec_diff_nei > 0
  }
  peak_valley_poss <- head(cumsum(rle(inc_bool)$lengths) + 1, -1)
  peak_type_bool   <- diff(rle(inc_bool)$values) < 0
  
  return(list(peak_valley_poss = peak_valley_poss,
              peak_type_bool   = peak_type_bool))
  
}

check_peak_split <-
    function(ivec,
             peak_left_limit, peak_right_limit,
             right_mode,
             cur_peak_top_pos = NULL,
             split_peak_ratio_thres = 0.5){
  
  pv <- find_peak_valley(ivec)

  if(is.null(cur_peak_top_pos)){
    cur_peak_top_pos <- which.max(ivec[peak_left_limit:peak_right_limit]) + peak_left_limit - 1
  }
  
  # Caution: Peak may be truncated with the following procedure.
  if(right_mode){
  
    scan_peak_valley_pos <- pv$peak_valley_poss[ cur_peak_top_pos < pv$peak_valley_poss &
                                                   pv$peak_valley_poss <= peak_right_limit ]
    scan_peak_type_bool  <- pv$peak_type_bool[ cur_peak_top_pos < pv$peak_valley_poss &
                                                 pv$peak_valley_poss <= peak_right_limit ]
  } else {
    
    scan_peak_valley_pos <-
      rev(pv$peak_valley_poss[ peak_left_limit <= pv$peak_valley_poss &
                                pv$peak_valley_poss < cur_peak_top_pos ])
    scan_peak_type_bool  <-
      rev(pv$peak_type_bool[ peak_left_limit <= pv$peak_valley_poss &
                                pv$peak_valley_poss < cur_peak_top_pos ])
  }
  
  while(length(scan_peak_valley_pos) && scan_peak_type_bool[1] == T){
    scan_peak_valley_pos <- tail(scan_peak_valley_pos, -1)
    scan_peak_type_bool  <- tail(scan_peak_type_bool,  -1)
  }
  # scan_peak_type_bool[1] == F expected.
  
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

  cur_top_height <- ivec[ cur_peak_top_pos ]
  
  split_pos <- NULL
  max_peak_ratio <- 0
  for(i in 1:length(scan_valley_poss)){
    
    valley_height  <- ivec[ scan_valley_poss[i] ]
    
    if(length(scan_peak_poss) >= i){
      for(j in i:length(scan_peak_poss)){
        
        next_peak_height <- ivec[ scan_peak_poss[j] ]
        peak_ratio <- min(
          (cur_top_height - valley_height) / cur_top_height,
          # (next_peak_height - valley_height) / next_peak_height,
          (next_peak_height - valley_height) / (cur_top_height - valley_height)
          )
        
        # cat(sprintf("### Valley pos: %d  Peak pos: %d  Peak ratio: %f  Max peak ratio: %f  Split peak ratio thres.: %f  Right-mode: %s\n",
        #             scan_valley_poss[i], scan_peak_poss[j], peak_ratio, max_peak_ratio, split_peak_ratio_thres, as.character(right_mode)))
        # print(c((cur_top_height - valley_height) / cur_top_height,
        #         (next_peak_height - valley_height) / (cur_top_height - valley_height)))
        
        if(peak_ratio >= split_peak_ratio_thres && peak_ratio > max_peak_ratio){
          split_pos <- scan_valley_poss[i]
          max_peak_ratio <- peak_ratio
        }
      }
    }
  }  
  
  return(split_pos)
  
}

get_split_poss <-
  function(ivec,
           peak_left_limit, peak_right_limit,
           cur_peak_top_pos = NULL,
           split_peak_ratio_thres = 0.5){

    debug_bool <- FALSE # peak_left_limit == 1 && peak_right_limit == 60
        
    if(is.null(cur_peak_top_pos)){
      cur_peak_top_pos <- which.max(ivec[peak_left_limit:peak_right_limit]) + peak_left_limit - 1
    }

    if(debug_bool){
      cat(sprintf("Running into %d - %d (%d)\n", peak_left_limit, peak_right_limit, cur_peak_top_pos))
    }
            
    left_split_pos <-
      check_peak_split(ivec,
                       peak_left_limit, peak_right_limit,
                       right_mode = FALSE,
                       cur_peak_top_pos = cur_peak_top_pos,
                       split_peak_ratio_thres = split_peak_ratio_thres)
    right_split_pos <-
      check_peak_split(ivec,
                       peak_left_limit, peak_right_limit,
                       right_mode = TRUE,
                       cur_peak_top_pos = cur_peak_top_pos,
                       split_peak_ratio_thres = split_peak_ratio_thres)
    
    if(debug_bool){
      cat("Split result left:\n")
      print(left_split_pos)
      cat("Split result right:\n")
      print(right_split_pos)
    }
    
    if(!is.null(left_split_pos)){
      left_split_poss <-
        c(get_split_poss(ivec, peak_left_limit, left_split_pos,
                         split_peak_ratio_thres = split_peak_ratio_thres), left_split_pos)
      middle_peak_left_limit <- left_split_pos
    } else {
      left_split_poss <- NULL
      middle_peak_left_limit <- peak_left_limit
    }
    
    if(!is.null(right_split_pos)){
      right_split_poss <-
        c(right_split_pos, get_split_poss(ivec, right_split_pos, peak_right_limit,
                                          split_peak_ratio_thres = split_peak_ratio_thres))
      middle_peak_right_limit <- right_split_pos
    } else {
      right_split_poss <- NULL
      middle_peak_right_limit <- peak_right_limit
    }
    
    if(peak_left_limit == middle_peak_left_limit &&
       peak_right_limit == middle_peak_right_limit){
      middle_split_poss <- NULL
    } else {
      middle_split_poss <- get_split_poss(ivec, middle_peak_left_limit, middle_peak_right_limit,
                                          cur_peak_top_pos, split_peak_ratio_thres)
    }
    
    if(debug_bool){
      cat(sprintf("Getting out of %d - %d (%d)\n", peak_left_limit, peak_right_limit, cur_peak_top_pos))
      cat("All split result left:\n")
      print(left_split_poss)
      cat("All split result middle:\n")
      print(middle_split_poss)
      cat("All split result right:\n")
      print(right_split_poss)
    }
      
    return(c(left_split_poss, middle_split_poss, right_split_poss))
    
  }


divide_peak <-
  function(ivec,
           peak_left_limit, peak_right_limit,
           cur_peak_top_pos = NULL,
           split_peak_ratio_thres = 0.5){

    split_poss <-
      c(peak_left_limit,
        get_split_poss(ivec,
                       peak_left_limit, peak_right_limit,
                       cur_peak_top_pos,
                       split_peak_ratio_thres),
        peak_right_limit)
    

    # split_poss will be peak dividing positions
    # ex. c(10, 15, 18, 20)
    # Then, 10 - 15, 15:18, 18:20 will be returned.
    return(cbind(head(split_poss, -1),
                 tail(split_poss, -1)))
    
  }
    
    
# Unit test
if(exists("rsunit_test_find_peak_simple") &&
   rsunit_test_find_peak_simple){
 
   tmp_vec1 <- c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
                 2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
                 3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
                 4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
                 0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
                 2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
                 3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
                 3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1)
  
   tmp_res1 <- find_peak_simple(ivec = tmp_vec1,
                                izscore_peak_thres   = 2.0,
                                izscore_signal_thres = 1.645,
                                imean = 1, isd = 1,
                                split_peak_ratio_thres = 0.5)
   
   plot_res_find_peak_simple(tmp_res1)
   
   tmp_vec2 <- c(1,2,3,3,4,3,2,1,3,4,
                 6,4,2,4,5,5,3,4,6,8,
                 3,2,4,5,4,3,4,5,6,9,
                 4,5,1,2,2,3,4,3,2,3,
                 4,5,3,2,3,4,3,4,5,7,
                 2,2,3,4,5,6,4,3,3,4)
    
   # tmp_left_split <-
   #   check_peak_split(tmp_vec2,
   #                    peak_left_limit = 1, peak_right_limit = 34,
   #                    right_mode = FALSE, cur_peak_top_pos = 24)
    
   # tmp_right_split <-
   #   check_peak_split(tmp_vec2,
   #                    peak_left_limit = 1, peak_right_limit = 34,
   #                    right_mode = TRUE, cur_peak_top_pos = 6)
   # 
   # print(tmp_left_split)
   # print(tmp_right_split)
   # plot(tmp_vec2, type = "l")
   #       
   # 
   # tmp_divided <-
   #   divide_peak(tmp_vec2,
   #               peak_left_limit = 1,
   #               peak_right_limit = length(tmp_vec2),
   #               cur_peak_top_pos = NULL,
   #               split_peak_ratio_thres = 0.2)
   # print(tmp_divided)
   
   # print(check_peak_split(tmp_vec2, 13, 17, TRUE, split_peak_ratio_thres = 0.2))
   
}

