
# For unit test, rsunit_test_consec_hits <- T and source this.

consec_true_positions <- function(ivec){
  # Note that ivec may contain NAs.
  
  consec_res <- rle(ivec)
  poss_end   <- cumsum(consec_res$lengths)
  poss_start <- c(1, head(poss_end, -1)+1)
  
  true_bools <- (!is.na(consec_res$values)) & consec_res$values

  return(cbind(poss_start, poss_end)[ true_bools, , drop=F])
  # return(cbind(poss_start, poss_end)[ consec_res$values, , drop=F])
  
}



# Unit test
if(exists("rsunit_test_consec_hits") && rsunit_test_consec_hits){

  vec_ <- c(F, F, F, T, T, T, T, T, F, F, F, T, T, T, F, T, F, F, F, T, T, F, F, F, F)

  print(consec_true_positions(vec_))
  
}
