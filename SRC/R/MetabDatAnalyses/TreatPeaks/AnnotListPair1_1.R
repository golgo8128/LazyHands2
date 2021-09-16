
# For unit test, rsunit_test_AnnotListPair <- T and source it.

source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/Reijenga1_1.R")

AnnotListPair <-
  setRefClass("AnnotListPair",
              fields = list(
                antl1 = "AnnotList",
                antl2 = "AnnotList",
                params = "list",
                h = "list"
              ))

AnnotListPair$methods(initialize =
  function(iantl1 = NULL, iantl2 = NULL){
    
    if(!is.null(iantl1)){
      .self$antl1 = iantl1
    }
    if(!is.null(iantl2)){
      .self$antl2 = iantl2
    }
    
  })

AnnotListPair$methods(
  get_common_ISs = function(){
  
    common_ISs <-
      intersect(.self$antl1$marks$IS_marks,
                .self$antl2$marks$IS_marks)
    
    dfrm1 <-
      .self$antl1$annotlist_dfrm[ common_ISs, ]
    dfrm1 <- dfrm1[ order(dfrm1["MT"]), ]
    
    return(rownames(dfrm1))
    
  })

AnnotListPair$methods(
  get_MT_pairs = function(imetab_ids){
    
    rmat <-
      cbind(.self$antl1$annotlist_dfrm[ imetab_ids, "MT"],
            .self$antl2$annotlist_dfrm[ imetab_ids, "MT"])
    rownames(rmat) <- imetab_ids

    return(rmat)
    
  })

AnnotListPair$methods(
  gen_Reijenga = function(imetab_id1, imetab_id2){

    mtmat <- .self$get_MT_pairs(c(imetab_id1, imetab_id2))
    mtmat <- mtmat[ order(mtmat[,1]), ]
    .self$params$reijenga_mtmat <- mtmat
    
    rownames(mtmat) <- NULL
  
    alpha_gamma <-
      reijenga_calc_params(mtmat[1,2], mtmat[2,2],
                           mtmat[1,1], mtmat[2,1])
  
    .self$params$reijenga_to_ref <-
      FuncParam_simple1(reijenga_map_to_ref,
                        list(ialpha = alpha_gamma[[ "alpha" ]],
                             igamma = alpha_gamma[[ "gamma" ]]))

    .self$params$reijenga_from_ref <-
      FuncParam_simple1(reijenga_map_from_ref,
                        list(ialpha = alpha_gamma[[ "alpha" ]],
                             igamma = alpha_gamma[[ "gamma" ]]))
    
    
  })


AnnotListPair$methods(
  map_to_ref_Reijenga = function(imts){

    return(.self$params$reijenga_to_ref$calc(list(s_t = imts)))
    
  })

AnnotListPair$methods(
  map_from_ref_Reijenga = function(imts){
    
    return(.self$params$reijenga_from_ref$calc(list(r_t = imts)))
    
  })


#     dfrm1 <-
#       .self$antl1$annotlist_dfrm[ common_ISs, ]
#     dfrm2 <-
#       .self$antl2$annotlist_dfrm[ common_ISs, ]
#     
#     dfrm1 <- dfrm1[ order(dfrm1["MT"]), ]
#     dfrm2 <- dfrm2[ rownames(dfrm1), ]
#     
#     return(list(dfrm1, dfrm2))
#       
# })




if(exists("rsunit_test_AnnotListPair") &&
   rsunit_test_AnnotListPair){
  
  source.RS("FilePath/rsFilePath1.R")
  
  example_annotlist_file1 <-
    RSFPath("TRUNK", "cWorks", "Project",
            "MetabolomeGeneral", "AnnotationList",
            "C_114_annotlist_160809-2_RSC1.csv")
  
  tmp_annotlist1 <- AnnotList(example_annotlist_file1)
  tmp_annotlist2 <- AnnotList(tmp_annotlist1)
  tmp_annotlist2$reg_mt("108", 5.4)
  tmp_annotlist2$reg_mt("107", 15.4)
  tmp_annotpair <- AnnotListPair(tmp_annotlist1,
                                 tmp_annotlist2)
  print(tmp_annotpair$get_MT_pairs(c("107", "108")))
  tmp_annotpair$gen_Reijenga("107","108")
  print(tmp_annotpair$map_to_ref_Reijenga(c(1:10, 15.4, 5.4)))
  print(tmp_annotpair$map_from_ref_Reijenga(c(1:10, 14.52, 6.04)))  
  
}


