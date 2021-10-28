# https://sites.google.com/view/xcmstutosimple1/entry

library(xcms)
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/MetabBatchSimple2_1.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/Epherogram1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/RefSampPairSet1_1.R")
source.RS("FilePath/rsFilePath1.R")


# ref_mzML_file_ <-
#   RSFPath("TRUNK", "cWorks", "Project",
#           "MetabolomeGeneral", "CE-MS",
#           "STDs", "Cation",
#           "RefSTD_C114_20200303_MHcentroided1_1.mzML")

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

batch_ <- MetabBatchSimple()
batch_$import_from_mzml_files(sample_mzML_files_,
                              annotlist_)

ref1_ <- batch_$sample_metab_meas_list[[1]]
ref1_$set_annotlist(annotlist_) # ISs will be set here.
ref1_$import_peak_range_info(
  ref_peak_range_info_file_)
# ref1_$find_IS_marks(batch_$ref_annotlist)

smm2_ <- batch_$sample_metab_meas_list[[2]]
smm2_$find_bulk_peaks_all_ephe()
smm2_$find_IS_marks(batch_$ref_annotlist)

smm3_ <- batch_$sample_metab_meas_list[[3]]
smm3_$find_bulk_peaks_all_ephe()
smm3_$find_IS_marks(batch_$ref_annotlist)

smm4_ <- batch_$sample_metab_meas_list[[4]]
smm4_$find_bulk_peaks_all_ephe()
smm4_$find_IS_marks(batch_$ref_annotlist)

pairset_ <- RefSampPairSet(ref1_)
# pairset_$add_smp(ref1_)
pairset_$add_smp(smm2_)
pairset_$add_smp(smm3_)
pairset_$add_smp(smm4_)
pairset_$gen_Reijenga()
# annotated_landmarks1_ <- pairset_$refsmp_pairs_l[[1]]$annotate_landmarks()
annotated_landmarks2_ <- pairset_$refsmp_pairs_l[[2]]$annotate_landmarks()
annotated_landmarks3_ <- pairset_$refsmp_pairs_l[[3]]$annotate_landmarks()
annotated_landmarks4_ <- pairset_$refsmp_pairs_l[[4]]$annotate_landmarks()
# batch_$ref_annotlist$marks$landmarks

# pairset_$refsmp_pairs_l[[1]]$ref$ephe_mzs
# pairset_$refsmp_pairs_l[[1]]$smp$ephe_mzs

# pairset_$refsmp_pairs_l[[1]]$ref$get_ephe_info_from_metabid("G011")
# pairset_$plot_peak_in_ephe("G011")

# G011 m/z:76.0393 MT:736.2670 (F1.S1102 736.2670, spectrum 1102)

batch_$set_xcms_peakgrp_info()
pkgrpp <- PeakGroupsParam(minFraction = 0.75, smooth = "loess")
data_pkhook_aligned <- adjustRtime(batch_$xcms_XCMSnExp, pkgrpp)


plot(rtime(batch_$xcms_XCMSnExp), rtime(data_pkhook_aligned),
     pch = 16, cex = 0.25, col = fromFile(data_pkhook_aligned))
legend("topleft",
       legend = sub("\\.[^.]+$", "", basename(fileNames(batch_$xcms_MSnbase))),
       lty = "solid", col = 1:length(fileNames(batch_$xcms_MSnbase)))

plotAdjustedRtime(data_pkhook_aligned, col = 1:length(fileNames(batch_$xcms_MSnbase)), peakGroupsPch = 1)


adjust_mt_pairs_squashed <-
  cbind(rtime(batch_$xcms_XCMSnExp), rtime(data_pkhook_aligned))

adjust_mt_pairs_l <-
  lapply(1:length(fileNames(batch_$xcms_MSnbase)),
         function(tmpsamplenum){
           adjust_mt_pairs_squashed[ fromFile(data_pkhook_aligned) == tmpsamplenum, ]
         })


