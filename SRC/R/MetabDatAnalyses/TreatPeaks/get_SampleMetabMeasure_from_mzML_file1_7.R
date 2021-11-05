# https://sites.google.com/view/xcmstutosimple1/entry

library(xcms)
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/MetabBatchSimple2_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/Epherogram1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/RefSampPairSet1_2.R")
source.RS("FilePath/rsFilePath1.R")


ref_peak_range_info_file_ <-
  RSFPath("TRUNK", "cWorks", "Project",
          "MetabolomeGeneral", "CE-MS",
          "STDs", "Cation",
          "RefSTD_C114_20200303_MH_peakinfo1_1.tsv")

annotlist_file_ <-
  RSFPath("TRUNK", "cWorks", "Project", "MetabolomeGeneral",
          "CE-MS", "STDs", "Cation",
          "RefSTD_C114_annotlist20200303.csv")

sample_mzML_files_ <-
  RSFPath("TRUNK", "cWorks", "Project", "MetabolomeGeneral",
          "CE-MS", "STDs", "Cation",
          c("RefSTD_C114_20200303_MHcentroided1_1.mzML",
            "STD112.mzML", "200uM.mzML", "100uM.mzML"))

annotlist_ <- AnnotList(annotlist_file_ )

batch_ <- MetabBatchSimple(annotlist_)
batch_$import_from_mzml_files(sample_mzML_files_)

ref1_ <- batch_$sample_metab_meas_list[[1]]
ref1_$import_peak_range_info(
  ref_peak_range_info_file_)
batch_$set_to_ref(ref1_)
batch_$find_bulk_peaks_all_ephe()
batch_$find_IS_marks()

pairset_ <- batch_$gen_refsamppairset()
pairset_$gen_Reijenga()
annotated_landmarks1_ <- pairset_$refsmp_pairs_l[[1]]$annotate_landmarks()
annotated_landmarks2_ <- pairset_$refsmp_pairs_l[[2]]$annotate_landmarks()
annotated_landmarks3_ <- pairset_$refsmp_pairs_l[[3]]$annotate_landmarks()
# annotated_landmarks4_ <- pairset_$refsmp_pairs_l[[4]]$annotate_landmarks()
# batch_$ref_annotlist$marks$landmarks

# pairset_$refsmp_pairs_l[[1]]$ref$ephe_mzs
# pairset_$refsmp_pairs_l[[1]]$smp$ephe_mzs

# pairset_$refsmp_pairs_l[[1]]$ref$get_ephe_info_from_metabid("G011")
# pairset_$plot_peak_in_ephe("G011")

# G011 m/z:76.0393 MT:736.2670 (F1.S1102 736.2670, spectrum 1102)

batch_$set_xcms_peakgrp_info()
pkgrpp <- PeakGroupsParam(minFraction = 0.75, smooth = "loess")
batch_$align_xcms(pkgrpp)

# data_pkhook_aligned <- adjustRtime(batch_$xcms_XCMSnExp, pkgrpp)


plot(rtime(batch_$xcms_XCMSnExp), rtime(batch_$xcms_XCMSnExp_aligned),
     pch = 16, cex = 0.25, col = fromFile(batch_$xcms_XCMSnExp_aligned))
legend("topleft",
       legend = sub("\\.[^.]+$", "", basename(fileNames(batch_$xcms_MSnbase))),
       lty = "solid", col = 1:length(fileNames(batch_$xcms_MSnbase)))

plotAdjustedRtime(batch_$xcms_XCMSnExp_aligned,
                  col = 1:length(fileNames(batch_$xcms_MSnbase)),
                  peakGroupsPch = 1)

pairset_$calc_adjust_mt_pairs()


isample_mt <- 1000
isample    <- batch_$sample_metab_meas_list[[2]] # "200uM.mzML"

ref_mt <- pairset_$smm_unalign_to_ref_unalign_mt(isample, isample_mt)
print(ref_mt)
print(pairset_$ref_unalign_to_smm_unalign_mt(isample, ref_mt))




