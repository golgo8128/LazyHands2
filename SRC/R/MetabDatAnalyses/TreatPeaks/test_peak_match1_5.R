
# library(xcms)

source.RS("Usefuls1/pairing_ordered_pat1_2.R")
source.RS("Usefuls1/find_identical_elems_in_list1.R")
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/EPherogram1_3.R")

source.RS("FilePath/rsFilePath1.R")


test_annotlist_file1 <-
  RSFPath("PROG",
          "ProgTestData", "MetabDataSample",
          "annotlist_RSC1_test1_1.csv")

test_annotlist1 <- AnnotList(test_annotlist_file1)

test_ref0 <- SampleMetabMeasure(isamplenam = "Reference 0")
test_ref0$set_annotlist(test_annotlist1)

### Intended for IS1 in sample 1 ###
test_samp1_intsty1 <-
  c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
    2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
    4,3,2,1,3,2,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
    0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
    2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
    3,1,2,3,2,1,2,3,3,4,5,6,7,8,15,8,7,6,5,5,
    3,1,2,3,2,1,2,3,3,4,5,6,3,6,4,6,4,6,5,5,
    3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1)

test_samp1_mt1 <- 1:length(test_samp1_intsty1) * 10
test_samp1_ephe_mat1 <- cbind(test_samp1_mt1, test_samp1_intsty1)
test_samp1_ephe1 <- EPherogram(test_samp1_ephe_mat1 , imz = 200)

### Intended for IS2 in sample 1 ###
test_samp1_intsty2 <-
  c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
    2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
    3,1,2,3,2,1,2,3,3,4,5,6,7,8,15,8,7,6,5,5,
    4,3,2,1,3,2,3,1,1,1,1,2,2,2,2,1,1,1,1,1,
    0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1,
    2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4,
    3,1,2,3,2,1,2,3,3,4,5,6,3,6,4,6,4,6,5,5,
    3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1)

test_samp1_mt2 <- 1:length(test_samp1_intsty2) * 10
test_samp1_ephe_mat2 <- cbind(test_samp1_mt2, test_samp1_intsty2)
test_samp1_ephe2 <- EPherogram(test_samp1_ephe_mat2 , imz = 50)


test_samp1_intsty3 <-
  c(0,0,0,3,2,4,3,1,2,3,2,3,4,3,2,1,2,3,2,1, # 0 - 200
    2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4, # 210 - 400
    6,12,6,3,4,1,3,4,9,4,5,4,3,7,23,8,2,3,4,5, # 410 - 600
    10,5,2,1,3,7,8,5,1,1,1,6,9,5,2,1,1,11,25,12, # 610 - 800
    0,0,0,3,9,8,7,1,2,3,2,8,6,3,2,1,2,3,2,1, # 810 - 1000
    2,3,2,1,2,3,4,3,1,3,1,1,1,1,1,2,1,2,3,4, # 1010 - 1200
    3,1,2,3,2,1,2,3,3,4,5,6,3,6,4,6,4,6,5,5, # 1210 - 1400
    3,2,1,1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1) # 1410 - 1500

test_samp1_mt3 <- 1:length(test_samp1_intsty3) * 10
test_samp1_ephe_mat3 <- cbind(test_samp1_mt3, test_samp1_intsty3)
test_samp1_ephe3 <- EPherogram(test_samp1_ephe_mat3 , imz = 100)

# print(test_samp1_ephe_mat3)
# test_samp1_ephe3$plot_res_find_peak_simple()


test_samp1 <- SampleMetabMeasure(isamplenam = "Sample 1")
test_samp1$add_ephe(test_samp1_ephe1)
test_samp1$add_ephe(test_samp1_ephe2)
test_samp1$add_ephe(test_samp1_ephe3)
# test_samp1$find_bulk_peaks_all_ephe()

test_batch <- MetabBatchSimple(test_ref0$annotlist)
test_batch$add_sample(test_samp1)
test_batch$set_to_ref(test_ref0) # Also generates ref-sample pair(s)
test_batch$find_bulk_peaks_all_samples()
test_batch$find_IS_marks()
test_batch$gen_Reijenga()
test_batch$annotate_landmarks()

test_batch$plot_peak_in_ephe(imz = 100)

# pkgrpp <- PeakGroupsParam(minFraction = 0.75, smooth = "loess")
# test_batch$align_xcms(pkgrpp)


# # # # # Testing candidate_peak_sets method # # # # #

cut_thres_mt_     <- 100
extra_range_rate_ <- 0.2
ppm_              <- 100
mt_adjust_method_ <- "reijenga"
  
test_peak_match_res <-
  test_batch$refsamppairset$refsmp_pairs_l[[1]]$
    match_peaks(icut_thres_mt     = cut_thres_mt_,
                iextra_range_rate = extra_range_rate_,
                ippm              = ppm_,
                imt_adjust_method = mt_adjust_method_)


test_batch$plot_peak_in_ephe(imz = 100)




