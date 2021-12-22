
# For unit test, rsunit_test_GaussRoughEstim <- T and source it.

# Consider: 
# (1) Is it appropriate to assume that the error term follows N(0, sigma)
#     when using log-transformed formula?
# (2) Baseline is assumed to be 0? Maybe minimal value should be
#     subtracted from the whole input.

source.RS("Usefuls1/data_range1.R")
source.RS("Usefuls1/surround_nums1.R")


GaussRoughEstim <-
  setRefClass("GaussRoughEstim",
              fields = list(
                idata    = "matrix",
                dfrm     = "data.frame",
                regr_res = "lm",
                grest_frml = "formula",
                grest_func_ln_y      = "function",
                calc_grest_func_ln_y = "function",
                calc_grest_func_y    = "function"
              ))

GaussRoughEstim$methods(initialize
  = function(ix, iy){ # iy > 0

    .self$grest_frml <- ln_y ~ x_sq + x
    .self$grest_func_ln_y <-
        function(ix, ia, ib, ic){
          return(ia*ix**2 + ib*ix + ic)
      }      
    .self$calc_grest_func_ln_y <-
      function(ix){
        return(.self$grest_func_ln_y(
          ix = ix,
          ia = coef(.self$regr_res)["x_sq"],
          ib = coef(.self$regr_res)["x"],
          ic = coef(.self$regr_res)["(Intercept)"]
        ))
      }
    .self$calc_grest_func_y <-
      function(ix){
        ret <- exp(.self$calc_grest_func_ln_y(ix))
        names(ret) <- NULL
        return(ret)
      }
    
    .self$idata <- cbind(iy, ix)
    colnames(.self$idata) <- c("iy", "ix")
    
    .self$dfrm <-
      data.frame(ln_y = log(iy),
                 x_sq = ix**2,
                 x    = ix)
    
})

GaussRoughEstim$methods(regres
    = function(){

      .self$regr_res <-
        lm(.self$grest_frml, data = .self$dfrm)

      test_val <-
        .self$calc_grest_func_ln_y(0)
      if(is.infinite(test_val) || is.na(test_val) || is.nan(test_val)){
        return(NA)
      } else {
        return(.self$regr_res)
      }
      
})
    
GaussRoughEstim$methods(vertex
  = function(){
    
    a <- coef(.self$regr_res)[ "x_sq" ]
    b <- coef(.self$regr_res)[ "x" ]
    c <- coef(.self$regr_res)[ "(Intercept)" ]
       
    ret <- c(
      -b / (2*a),
      exp(-(b**2 - 4 * a * c) / (4 * a))
    )
    names(ret) <- c("x", "y")
    return(ret)
    
})


GaussRoughEstim$methods(regres_surround_simple
    = function(focus_x, npick = 2){

      sur_l <- surround_nums_idx(.self$idata[, "ix"],
                                 focus_x, npick = npick)
      if(length(sur_l$lo_idx) == npick &&
         length(sur_l$hi_idx) == npick){
        sel_data <- 
          .self$idata[ c(sur_l$lo_idx, sur_l$hi_idx), ]
        .self$dfrm <-
          data.frame(ln_y = log(sel_data[, "iy" ]),
                     x_sq = sel_data[, "ix" ]**2,
                     x    = sel_data[, "ix" ])
        return(.self$regres())
      } else {
        return(NA)
      }
        
})


GaussRoughEstim$methods(plot_regres
    = function(npoints_plot_pred = 100,
               zoom_focus_bool = FALSE,
               xlim = NULL, ylim = NULL,
               imark_x = NULL){
               
  if(zoom_focus_bool){
    points_pred_x_range <-
      extra_range(min(.self$dfrm[,"x"]),
                  max(.self$dfrm[,"x"]),
                  conv_int = FALSE)
  } else {
    points_pred_x_range <-
      extra_range(min(.self$idata[,"ix"]),
                  max(.self$idata[,"ix"]),
                  conv_int = FALSE)
  }
    
  points_pred_x <-
    ((0:npoints_plot_pred)/npoints_plot_pred
     * (points_pred_x_range[2] - points_pred_x_range[1])
     + points_pred_x_range[1])
  
  points_pred_y <-
    sapply(points_pred_x, .self$calc_grest_func_y)

  if(zoom_focus_bool){
    points_pred_y_range <-
      extra_range(min(points_pred_y),
                  max(points_pred_y))
  } else {
    points_pred_y_range <-
      extra_range(min(c(points_pred_y),
                       .self$idata[, "iy"]),
                  max(c(points_pred_y),
                        .self$idata[, "iy"]))
  }

  if(is.null(xlim)){
    xlim <- points_pred_x_range
  }
  
  if(is.null(ylim)){
    ylim <- points_pred_y_range
  }
  
  
  plot(.self$idata[, "ix"],
       .self$idata[, "iy"], pch=16, col = "gray",
       xlim = xlim,
       ylim = ylim,
       xlab = "x", ylab = "y")
    
  points(.self$dfrm[["x"]],
         exp(.self$dfrm[["ln_y"]]), pch=16)

  lines(points_pred_x, points_pred_y, lty = 3)
  points(.self$vertex()[1], .self$vertex()[2],
         col = "red", pch = 8, cex = 1.5)
  
  if(!is.null(imark_x)){
    points(imark_x, .self$calc_grest_func_y(imark_x),
           pch = 4, col = "orange", cex = 1.5)
  }
  
  
})

  
# Unit test
if(exists("rsunit_test_GaussRoughEstim") &&
   rsunit_test_GaussRoughEstim){


  x    <- c(1,2,3,4,5,6,7,8,9,10)
  y    <- c(1,1,2,3,9,7,2,1,1,1) # y > 0
  
  x <- c(
    76.0044674286619,
    76.014510740526,
    76.0245547164232,
    76.034599355422,
    76.0446446575224,
    76.0546906236559,
    76.0647372528911,
    76.0747845461592
  ) - 76.0393
  
  y <- c(
    254, 8906, 58515, 105226, 86145, 53538, 32478, 19626
  )
  
  
  grest_tmp <- GaussRoughEstim(ix = x, iy = y)
  grest_tmp$regres()
  grest_tmp$plot_regres()
  
  grest_tmp2 <- GaussRoughEstim(ix = x, iy = y)
  grest_tmp2$regres_surround_simple(0) # 5.5)
  grest_tmp2$plot_regres()
  
  # plot(x,exp(ln_y), pch = 16, ylim = c(0,20))
  # input_x   <- (1:100)/10
  # pred_ln_y <- sapply((1:100)/10, grest_func_ln_y,
  #                     ia = coef(lm_res)["x_sq"],
  #                     ib = coef(lm_res)["x"],
  #                     ic = coef(lm_res)["(Intercept)"])
  # 
  # points(input_x, exp(pred_ln_y))

}
