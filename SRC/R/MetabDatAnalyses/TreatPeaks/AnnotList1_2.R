
source.RS("FilePath/rsFilePath1.R")
source.RS("String1/regexpr_parenthesis_pick1.R")

# For unit test, rsunit_test_AnnotList <- T and source this.

COLNAMES_MHAnnotList <- c("IS", "ID", "Annotation Name",
                          "m/z", "MT", "ppm", "dmt", "S/N", "valley",
                          "num", "base")


read_MH_annot_list <-
  function(ifile){
    
    annotlist_dfrm <-
      read.table(ifile, sep = ",",
                 header = F, row.names = NULL)
    
    colnames(annotlist_dfrm)[1:length(COLNAMES_MHAnnotList)] <- COLNAMES_MHAnnotList
    rownames(annotlist_dfrm) <- annotlist_dfrm$ID # Make sure that there is no overlap of IDs.
    
    annotlist_dfrm[ "MT" ]  <- annotlist_dfrm[ "MT" ] * 60
    annotlist_dfrm[ "dmt" ] <- annotlist_dfrm[ "dmt" ] * 60
    
    return(annotlist_dfrm)
    
  }

parse_1st_rscommand <- function(icell_str){
  
  parse_res <- regexpr_parenthesis_pick("\\s*RSC\\s*\\|\\s*(.*\\S)\\s*$", icell_str)
  if(!is.null(parse_res)){
    return(strsplit(parse_res, "\\s*;\\s*")[[1]])
  }
  else {
    return(NULL)
  }
  
}


parse_rscommand = function(iannotlist_dfrm){
  
  ret_marks <- list()
  
  if(ncol(iannotlist_dfrm) > length(COLNAMES_MHAnnotList)){
    for(i in 1:nrow(iannotlist_dfrm)){
      metab_id <- as.vector(iannotlist_dfrm[i, "ID"])
      for(j in (length(COLNAMES_MHAnnotList)+1):ncol(iannotlist_dfrm)){
        ccell_val <- as.vector(iannotlist_dfrm[i, j])
        # print(ccell_val)
        if(is.character(ccell_val)){
          parse_1st <- parse_1st_rscommand(ccell_val)
          if(!is.null(parse_1st)){
            for(ccom in parse_1st){
              
              if(ccom == "add_to_Reijenga_mark"){
                ret_marks$IS_marks <-
                  c(ret_marks$IS_marks, metab_id)
              } else if(ccom == "add_to_landmark"){
                ret_marks$landmarks <-
                  c(ret_marks$landmarks, metab_id)
              }
              
              else{
                stop(paste("Illegal RS Command:", ccom))
              }
              
            }
          }
        }
      }
    }
  }  
  
  return(ret_marks)
  
}



AnnotList <-
  setRefClass("AnnotList",
              fields = list(
                # annotlist_file = "character",
                annotlist_dfrm = "data.frame",
                marks          = "list",
                sampmetabmeasr = "ANY" #
                # Intended for "SampleMetabMeasure", but problem
                # of reciprocal sourcing.
              ))


AnnotList$methods(set_samplemetabmeasure
  = function(isamplemetabmeasure){
                    
    source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_2.R")
                    
    if(is(isamplemetabmeasure, "SampleMetabMeasure")){
      .self$sampmetabmeasr <- isamplemetabmeasure
    } else {
      stop("AnnotList: Expected data type was SampleMetabMeasure")
    }
    
})


AnnotList$methods(initialize = function(iannotlist = ""){
  
  if(is.character(iannotlist) && iannotlist == ""){
    .self$annotlist_dfrm <- data.frame()
  }
  else if(is.character(iannotlist) && iannotlist != ""){
  
    # .self$annotlist_file <- iannotlist_file
    .self$annotlist_dfrm <- read_MH_annot_list(iannotlist)
    .self$marks <- parse_rscommand(.self$annotlist_dfrm)

  }
  else if(is(iannotlist, AnnotList)){
   
    .self$annotlist_dfrm <- iannotlist$annotlist_dfrm
    .self$annotlist_dfrm[ "m/z" ] <- NA
    .self$annotlist_dfrm[ "MT" ] <- NA
    .self$marks <- iannotlist$marks
    
  }
    
})

AnnotList$methods(reg_mt = function(imetab_id, imt){
  
    .self$annotlist_dfrm[ imetab_id, "MT" ] <- imt
  
  })

AnnotList$methods(reg_mz = function(imetab_id, imz){
  
    .self$annotlist_dfrm[ imetab_id, "m/z" ] <- imz
  
})

AnnotList$methods(reg_IS = function(imetab_id){
  
  if(!(imetab_id %in% .self$marks$IS_marks)){
    .self$marks$IS_marks <- c(.self$marks$IS_marks, imetab_id)
  }
  
})


AnnotList$methods(get_mz = function(imetab_id){
  
  mz  <- .self$annotlist_dfrm[ imetab_id, "m/z" ]
  
  return(mz)
  
})


AnnotList$methods(get_mt = function(imetab_id){
  
  mt  <- .self$annotlist_dfrm[ imetab_id, "MT" ]

  return(mt)
  
})


AnnotList$methods(get_mt_range = function(imetab_id){
  
  mt  <- .self$annotlist_dfrm[ imetab_id, "MT" ]
  rng <- .self$annotlist_dfrm[ imetab_id, "dmt" ]
  
  return(c(mt - rng, mt + rng))
  
})

# Unit test
if(exists("rsunit_test_AnnotList") && rsunit_test_AnnotList){

  example_annotlist_file1 <-
    RSFPath("TRUNK", "cWorks", "Project",
            "MetabolomeGeneral", "AnnotationList",
            "C_114_annotlist_160809-2_RSC1.csv")
  
  tmp_annotlist1 <- AnnotList(example_annotlist_file1)
  tmp_annotlist2 <- AnnotList(tmp_annotlist1)
  tmp_annotlist2$reg_mz("XXX", 12.345)
 
  tmp_annotlist3 <- AnnotList()
  tmp_annotlist3$reg_mz("XXX", 12.345)
}




