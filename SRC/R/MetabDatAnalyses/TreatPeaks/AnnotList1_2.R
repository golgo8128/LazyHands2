
source.RS("FilePath/rsFilePath1.R")
source.RS("String1/regexpr_parenthesis_pick1.R")
source.RS("DataStruct1/merge_lists1_1.R")

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
                    
    source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")
                    
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


AnnotList$methods(get_metabs_similar_mz
  = function(imetab_id = NULL, imz = NULL,
             ippm = 100){
    
  # imetab_id itself may be included.

  if(is.null(imetab_id)){
    if(is.null(imz)){
      stop("In method get_metabs_similar_mz, neither imetab_id nor imz is specified.")
    } else {
      cmz <- imz
    }
  } else {
    cmz <- .self$annotlist_dfrm[ imetab_id, "m/z" ]    
  }
    
  mmetabids <- NULL

  if(is.na(cmz)){
    warning(sprintf("m/z not defined for the metabolite \"%s\".", imetab_id))
  } else {
    mzs <- .self$annotlist_dfrm[ , "m/z" ]
    calc_ppm <- abs((cmz - mzs) / mzs) * 10^6
    
    stated_ppm <- rep(ippm, length(calc_ppm))

    if("ppm" %in% colnames(.self$annotlist_dfrm)){
      dfrm_stated_ppm <- .self$annotlist_dfrm[, "ppm" ] 
      stated_ppm[ !is.na(dfrm_stated_ppm) ] <- dfrm_stated_ppm[ !is.na(dfrm_stated_ppm) ]
    }

    mmetabids <- rownames(.self$annotlist_dfrm)[ 
      (!is.na(calc_ppm)) & calc_ppm <= stated_ppm ]
    
  }
  
  mts          <- .self$annotlist_dfrm[ mmetabids, "MT" ]
  sorted_idx   <- order(mts)
  mts          <- mts[ sorted_idx ]
  ret_metabids <- mmetabids[ sorted_idx ]
  names(mts) <- ret_metabids
  
  return(mts)
  
})
  

AnnotList$methods(get_mz_range_dfrm = function(imfactor = 1){
  
  target_mz <- .self$annotlist_dfrm$`m/z`
  target_mz_low  <-
    target_mz * (1 - .self$annotlist_dfrm$ppm / 10^6 * imfactor)
  target_mz_high <-
    target_mz * (1 + .self$annotlist_dfrm$ppm / 10^6 * imfactor)
  target_mz_range_mat <- cbind(target_mz_low, target_mz_high)
  rownames(target_mz_range_mat) <- rownames(.self$annotlist_dfrm)
    
  return(target_mz_range_mat)
  
})


AnnotList$methods(
  plot_peak_poss_simple =
    function(imetab_id = NULL, imz = NULL, ippm = 100,
             mts = NULL, y_pos = 0, col = "black",
             ...){
      
      if(!is.null(imetab_id)){
        plot_title <- imetab_id
      } else if(!is.null(imz)){
        plot_title <- sprintf("Peak positions in m/z: %f", imz)
      }
      
      mts <-
        .self$get_metabs_similar_mz(imetab_id = imetab_id,
                                    imz = imz, ippm = ippm)
      
      
      if(length(mts) == 0){ return(NA) }

      metab_ids <- names(mts)
      
      y <- rep(y_pos, length(mts))
      
      default_varargs <- 
        list(x = mts,
             y = y, # Intensities?
             col  = col,
             type = "p",
             pch = "*",
             cex = 3,
             xlab = "Migration time (MT)",
             ylab = "",
             main = plot_title)
      ivarargs_l      <- list(...)
      
      do.call(plot, merge_two_lists(default_varargs,
                                    ivarargs_l))
      text(mts, y, metab_ids, pos = 3, col = col)

    })


# Unit test
if(exists("rsunit_test_AnnotList") && rsunit_test_AnnotList){

  example_annotlist_file1 <-
    RSFPath("TRUNK", "cWorks", "Project",
            "MetabolomeGeneral", "CE-MS", "AnnotationList",
            "C_114_annotlist_160809-2_RSC1.csv")
  
  tmp_annotlist1 <- AnnotList(example_annotlist_file1)
  tmp_annotlist2 <- AnnotList(tmp_annotlist1) # MTs and m/z's will be NA.
  tmp_annotlist2$reg_mz("XXX", 12.345)
  tmp_annotlist2$reg_mz("GX1", 76.0393); tmp_annotlist2$reg_mt("GX1", 610) 
  tmp_annotlist2$reg_mz("GX2", 76.0395); tmp_annotlist2$reg_mt("GX2", 600) 
  tmp_annotlist2$reg_mz("GX3", 76.0396); tmp_annotlist2$reg_mt("GX3", 620) 
  
  print(tmp_annotlist2$get_metabs_similar_mz(imz = 76.0395))    
  tmp_annotlist2$plot_peak_poss_simple(imz = 76.0395)
  
  tmp_annotlist3 <- AnnotList()
  tmp_annotlist3$reg_mz("XXX", 12.345)
  
}




