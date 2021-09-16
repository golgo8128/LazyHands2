
# For unit test, rsunit_test_data_range <- T and source this.

extra_range <- function(val_min, val_max, ex_rate = 0.1, conv_int = TRUE){

   extra_r <- (val_max - val_min) * ex_rate
   if(conv_int){ 
      return(c(floor(val_min - extra_r), ceiling(val_max + extra_r)))
   }
   else {
      return(c(val_min - extra_r, val_max + extra_r))
   }
}

specify_range <- function(ivec_raw, lower_rate = 0.0, upper_rate = 1.0){
  
  # if(is.na(upper_rate)){
  #   upper_rate <- lower_rate
  # }
  
  ivec <- ivec_raw[!is.na(ivec_raw)]
  
  imin   <- min(ivec)
  imax   <- max(ivec)
  irange <- imax - imin
  
  
  spec_range <- list(lower = imin + irange*lower_rate,
                     upper = imin + irange*upper_rate)
  
  return(spec_range)
  
} 

# Unit test
if(exists("rsunit_test_data_range") && rsunit_test_data_range){
  
  print(specify_range(c(10,11,12,15,20),0.1,0.7))
  
}