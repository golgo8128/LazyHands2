
# For unit test, rsunit_test_FuncParam_simple <- T and source it.

FuncParam_simple1 <-
  setRefClass("FuncParam_simple1",
              fields = list(
                func   = "function",
                params = "list"
              ))

FuncParam_simple1$methods(initialize = function(ifunc = NULL,
                                                iparams = list()){
  
  if(!is.null(ifunc)){
    .self$func   <- ifunc
    .self$params <- iparams
  }

})

FuncParam_simple1$methods(calc = function(val_list){
  
  return(do.call(.self$func, c(val_list, .self$params)))
  
})


if(exists("rsunit_test_FuncParam_simple") && rsunit_test_FuncParam_simple){
  
  reijenga_calc_params <-
    function(s_t1, s_t2, r_t1, r_t2){
      
      .alpha <- (1/s_t1 - 1/s_t2) / (1/r_t1 - 1/r_t2)
      .gamma <- (1/s_t1 + 1/s_t2)*1/.alpha - (1/r_t1 + 1/r_t2)
      
      return(c(alpha = .alpha, gamma = .gamma))
      
    }
  
  
  reijenga_map_to_ref <-
    function(s_t, ialpha, igamma){
      
      return(1 / (1/(ialpha*s_t) - igamma/2))
      
    }
  
  tmp_s_t1 <- 7
  tmp_s_t2 <- 20
  tmp_r_t1 <- 6
  tmp_r_t2 <- 15
  
  tmp_alpha_gamma <- reijenga_calc_params(tmp_s_t1, tmp_s_t2,
                                          tmp_r_t1, tmp_r_t2)
  tmp_rei <- FuncParam_simple1(reijenga_map_to_ref,
                               list(ialpha = tmp_alpha_gamma[ "alpha" ],
                                    igamma = tmp_alpha_gamma[ "gamma" ]))
  
  tmp_s_ts <- seq(0, 30, 0.1)
  tmp_r_ts <- reijenga_map_to_ref(tmp_s_ts,
                                  tmp_alpha_gamma[ "alpha" ],
                                  tmp_alpha_gamma[ "gamma" ])
  
  tmp_r_ts2 <- tmp_rei$calc(list(s_t = tmp_s_ts))
  
  
  plot(tmp_s_ts, tmp_r_ts,
       xlim = c(0, max(tmp_s_ts)),
       ylim = c(0, max(tmp_r_ts)),
       cex = 0.3,
       col = "gray",
       axes = F, ann = F)
  par(new = T)
  plot(c(tmp_s_t1, tmp_s_t2),
       c(tmp_r_t1, tmp_r_t2),
       xlim = c(0, max(tmp_s_ts)),
       ylim = c(0, max(tmp_r_ts)),
       col = "red", pch = 19)
  par(new = F)
  
  
}