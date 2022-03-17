
# For unit test, rsunit_pairing_ordered_pat <- T and source this.

PairingOrderedPat <- setRefClass("PairingOrderedPat",
  fields = list(
    num_nodes1    = "numeric",
    num_nodes2    = "numeric",
    nums1         = "numeric",
    nums2         = "numeric",
    cur_num_conns = "numeric"
  ))

PairingOrderedPat$methods(
  initialize = function(n1, n2){
    
    .self$num_nodes1    <- n1
    .self$num_nodes2    <- n2
    .self$cur_num_conns <- -1
    
  })


PairingOrderedPat$methods(
  init_num = function(inum_conns = NA){
    
    if(!is.na(inum_conns)){
      .self$cur_num_conns <- inum_conns
    }
    
    num_conns <- .self$cur_num_conns
    
    if(num_conns == 0
       || num_conns > .self$num_nodes1
       || num_conns > .self$num_nodes2){
      .self$nums1 <- numeric(0)
      .self$nums2 <- numeric(0)
    } else {
      .self$nums1 <- 1:num_conns
      .self$nums2 <- 1:num_conns
    }
    
  })

PairingOrderedPat$methods(
  reset_num = function(iwhich, cur_p){
    if(cur_p == 1){ return(1) }
    else if(iwhich == 1){
      return(.self$nums1[ cur_p - 1] + 1)
    }
    else if(iwhich == 2){
      return(.self$nums2[ cur_p - 1] + 1)
    }
  })

PairingOrderedPat$methods(
  within_limit = function(iwhich, cur_p, next_num){
    
    if(iwhich == 1){
      if(next_num + length(.self$nums1) - cur_p <=
          .self$num_nodes1){
        return(TRUE)
      } else {
        return(FALSE)
      }
    } else if(iwhich == 2){
      if(next_num + length(.self$nums2) - cur_p <=
         .self$num_nodes2){
        return(TRUE)
      } else {
        return(FALSE)
      }      
    }
  })


PairingOrderedPat$methods(
  next_pat_fixed_num_conns = function(){

    cur_p <- length(.self$nums1) # Or length(.self$nums2)
    while(1 <= cur_p && cur_p <= length(.self$nums1)){
      num1 <- .self$nums1[ cur_p ]
      num2 <- .self$nums2[ cur_p ]
      
      if(is.na(num1) || is.na(num2)){
        next_num1 <- .self$reset_num(1, cur_p)
        next_num2 <- .self$reset_num(2, cur_p)
        next_p <- cur_p + 1
      } else {
          next_num1 <- num1 + 1
          if(.self$within_limit(1, cur_p, next_num1)){
            next_num2 <- num2
            next_p <- cur_p + 1
          } else {
            next_num2 <- num2 + 1
            if(.self$within_limit(2, cur_p, next_num2)){
              next_p <- cur_p + 1
              next_num1 <- .self$reset_num(1, cur_p)
            } else {
              next_num1 <- NA
              next_num2 <- NA
              next_p <- cur_p - 1
            }
        }
      
      }
      
      .self$nums1[ cur_p ] <- next_num1
      .self$nums2[ cur_p ] <- next_num2
      cur_p <- next_p
      # print(c(cur_p, length(.self$nums1)))
    }
    
    if(cur_p < 1){
      gonethrough_flag <- TRUE
    } else {
      gonethrough_flag <- FALSE
    }
    
    return(list(
      gonethrough_flag = gonethrough_flag,
      nums1 = .self$nums1,
      nums2 = .self$nums2))
      
  })
  
PairingOrderedPat$methods(
  next_pat = function(){

    allpatout_flag = FALSE
    if(.self$cur_num_conns < 0){
      .self$init_num(0)
    } else if(.self$cur_num_conns == 0){
      .self$init_num(1)
    } else {
      next_res <-
          .self$next_pat_fixed_num_conns()
      if(next_res$gonethrough_flag){
        if(.self$cur_num_conns ==
           min(.self$num_nodes1, .self$num_nodes2)){
          allpatout_flag = TRUE
        } else {
          .self$init_num(.self$cur_num_conns + 1)
        }
      } 
      
    }
    
    return(list(
      allpatout_flag = allpatout_flag,
      nums1 = .self$nums1,
      nums2 = .self$nums2))
    
  })


PairingOrderedPat$methods(
  cur_pat = function(){

    return(list(
      nums1 = .self$nums1,
      nums2 = .self$nums2))
    
  })


PairingOrderedPat$methods(
  end_cur_conn = function(end_p){

    remain_num_nodes <- .self$cur_num_conns - end_p
    if(remain_num_nodes){
    
      .self$nums1 <-
        c(.self$nums1[ 1: end_p ],
          (.self$num_nodes1 - remain_num_nodes + 1):.self$num_nodes1)
      .self$nums2 <-
        c(.self$nums2[ 1: end_p ],
          (.self$num_nodes2 - remain_num_nodes + 1):.self$num_nodes2)
      
    }
    
  })
    

# Unit test
if(exists("rsunit_pairing_ordered_pat")
   && rsunit_pairing_ordered_pat){

  tmppairop <- PairingOrderedPat(10, 12)
  # tmppairop$cur_num_conns <- 5
  # tmppairop$init_num()
  print(tmppairop$next_pat())
  
}

# clear.RS(); rsunit_pairing_ordered_pat <- T; source("~/rs_Progs/rs_R/rs_R_Pack4/General/Usefuls1/pairing_ordered_pat1.R")



