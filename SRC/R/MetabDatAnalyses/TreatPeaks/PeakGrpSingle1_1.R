
# For unit test, rsunit_test_PeakGrpSingle <- T and source it.

PeakGrpSingle <-
  setRefClass("PeakGrpSingle",
    fields = list(
      peakgrp_annot = "character",
      pk_list       = "list"
      )) # "ANY" as generic class name?


PeakGrpSingle$methods(initialize =
    function(){
      
    })

PeakGrpSingle$methods(add_peak =
    function(ipk){
      .self$pk_list <- c(.self$pk_list, ipk)
    })


if(exists("rsunit_test_PeakGrpSingle") &&
   rsunit_test_PeakGrpSingle){

  source.RS("MetabDatAnalyses/TreatPeaks/PeakSingle1_1.R")
  source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_1.R")
  source.RS("MetabDatAnalyses/TreatPeaks/MetabBatchSimple2_1.R")

    
  tmp_batch <- MetabBatchSimple()
  
  tmp_intsty1 <-
    c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
      2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
      3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
      4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
      0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
      2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
      3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
      3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1)
  
  tmp_mt1 <- 1:length(tmp_intsty1) / 2
  tmp_ephe_mat1 <- cbind(tmp_mt1, tmp_intsty1)
  tmp_ephe1 <- EPherogram(tmp_ephe_mat1)
  
  tmp_intsty2 <-
    c(rep(c(0,1,2,1,2,1,0,1,1,1), 70),
      c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
        4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
        0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
        3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1))
  
  tmp_mt2 <- 1:length(tmp_intsty2) / 2
  tmp_ephe_mat2 <- cbind(tmp_mt2, tmp_intsty2)
  tmp_ephe2 <- EPherogram(tmp_ephe_mat2)

  tmp_intsty3 <-
    c(rep(c(0,1,2,1,2,1,0,1,1,1), 70),
      c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
        4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
        0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
        3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1))
  
  tmp_mt3 <- 1:length(tmp_intsty3) / 2.5
  tmp_ephe_mat3 <- cbind(tmp_mt3, tmp_intsty3)
  tmp_ephe3 <- EPherogram(tmp_ephe_mat3)  
  
  tmp_intsty4 <-
    c(rep(c(0,1,2,1,2,1,0,1,1,1), 70),
      c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
        4,5,6,7,8,4,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
        0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
        2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
        3,1,2,3,2,1,2,3,3,4,5,6,7,8,9,8,7,6,5,5,
        3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1))
  
  tmp_mt4 <- 1:length(tmp_intsty4) / 4
  tmp_ephe_mat4 <- cbind(tmp_mt4, tmp_intsty4)
  tmp_ephe4 <- EPherogram(tmp_ephe_mat4)    
  

  tmp_smm1 <- SampleMetabMeasure("Hypothetical sample file 1")
  tmp_smm1$add_ephe(tmp_ephe1, 70.63)
  tmp_smm1$add_ephe(tmp_ephe2, 75.87)
  tmp_batch$add_sample(tmp_smm1)

  tmp_smm2 <- SampleMetabMeasure("Hypothetical sample file 2")
  tmp_smm2$add_ephe(tmp_ephe3, 71.63)
  tmp_smm2$add_ephe(tmp_ephe4, 76.87)
  tmp_batch$add_sample(tmp_smm2)

  tmp_batch$find_bulk_peaks_all_samples()
  
  tmp_pkgrpsing <- PeakGrpSingle()
  tmp_pkgrpsing$add_peak(
    tmp_batch$sample_metab_meas_list[[1]]$ephe_list[[1]]$peak_list[[1]])
  tmp_pkgrpsing$add_peak(
    tmp_batch$sample_metab_meas_list[[2]]$ephe_list[[1]]$peak_list[[1]])

  
      
}
