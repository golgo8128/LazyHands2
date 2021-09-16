
# For unit test, rsunit_test_MetabBatchSimple <- T and source it.

source.RS("MetabDatAnalyses/TreatPeaks/PeakGrps1_1.R")

MetabBatchSimple <-
  setRefClass("MetabBatchSimple",
    fields = list(
        sample_metab_meas_list = "list",
        peak_grps              = "PeakGrps"
        
      )) # "ANY" as generic class name?


MetabBatchSimple$methods(initialize =
    function(){
      
    })

MetabBatchSimple$methods(add_sample =
    function(isample_metab_meas){
      isample_metab_meas$set_batch(.self)
      .self$sample_metab_meas_list <-
        c(.self$sample_metab_meas_list, isample_metab_meas)
    })

MetabBatchSimple$methods(find_bulk_peaks_all_samples =
  function(...){

    for(msample in .self$sample_metab_meas_list){
     
      msample$find_bulk_peaks_all_ephe(...)
       
    }
    
  })


if(exists("rsunit_test_MetabBatchSimple") &&
   rsunit_test_MetabBatchSimple){

  source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_1.R")
  
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
  
  tmp_smm1 <- SampleMetabMeasure("Hypothetical sample file 1")
  tmp_smm1$add_ephe(tmp_ephe1, 70.63)
  tmp_smm1$add_ephe(tmp_ephe2, 75.87)
  tmp_batch$add_sample(tmp_smm1)

  tmp_smm2 <- SampleMetabMeasure("Hypothetical sample file 2")
  tmp_smm2$add_ephe(tmp_ephe1, 71.63)
  # ??? Adding the electropherogram that appears in sample 1 as well
  tmp_smm2$add_ephe(tmp_ephe2, 76.87)
  tmp_batch$add_sample(tmp_smm2)

  
    
    
}
