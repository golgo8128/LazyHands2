

# For unit test, rsunit_test_split_by_distance <- T and source this.

split_by_distance <- function(ivec_sorted, icut_thres){
  
  cut_bool <- c(diff(ivec_sorted) >= icut_thres, TRUE)
  fragm_ends   <- which(cut_bool)
  fragm_starts <- c(0, head(fragm_ends, -1)) + 1
  fragm_poss <- cbind(fragm_starts, fragm_ends)
  
  return(lapply(1:nrow(fragm_poss),
                function(i_){ 
                  ivec_sorted[ fragm_poss[i_, 1] : fragm_poss[i_, 2] ]}))
  
}

# Unit test
if(exists("rsunit_test_split_by_distance")
   && rsunit_test_split_by_distance){


  tmp_vec <-
    c(11,12,13,15,21,
      22,33,37,49,74)
  names(tmp_vec) <-
    strsplit("ABCDEFGHIJ", "")[[1]]
  tmp_cut_thres <- 5
    
  
  print(split_by_distance(
    tmp_vec,
    tmp_cut_thres
  ))
  
  
}

