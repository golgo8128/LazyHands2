# https://sites.google.com/view/xcmstutosimple1/entry

library(xcms)
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/MetabBatchSimple2_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/EPherogram1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/RefSampPairSet1_3.R")
source.RS("FilePath/rsFilePath1.R")

working_folder <-
  RSFPath("PROJ", "XCMS",
          "CEMS_Wine20190121", "CEMS_Wine20190123_cation_targeted_centroided_C114_1_DrY1")

setwd(working_folder)


ref_peak_range_info_file_ <-
           "RefSTD_C114_20200303_MH_peakinfo1_1.tsv"

annotlist_file_ <-
          "RefSTD_C114_annotlist20200303.csv"

sample_mzML_files_ <-
  c("RefSTD_C114.mzML",
    "C_114STD_1.mzML",
    "C_114STD_2.mzML")


annotlist_ <- AnnotList(annotlist_file_ )

batch_ <- MetabBatchSimple(annotlist_)
batch_$import_from_mzml_files(sample_mzML_files_)

ref1_ <- batch_$sample_metab_meas_list[[1]]
ref1_$import_peak_range_info(
  ref_peak_range_info_file_)
batch_$set_to_ref(ref1_)
batch_$find_bulk_peaks_all_ephe()
batch_$find_IS_marks()
batch_$gen_Reijenga()
batch_$annotate_landmarks()

pkgrpp <- PeakGroupsParam(minFraction = 0.75, smooth = "loess")
batch_$align_xcms(pkgrpp)

plot(rtime(batch_$xcms_XCMSnExp), rtime(batch_$xcms_XCMSnExp_aligned),
     pch = 16, cex = 0.25, col = fromFile(batch_$xcms_XCMSnExp_aligned))
legend("topleft",
       legend = sub("\\.[^.]+$", "", basename(fileNames(batch_$xcms_MSnbase))),
       lty = "solid", col = 1:length(fileNames(batch_$xcms_MSnbase)))

plotAdjustedRtime(batch_$xcms_XCMSnExp_aligned,
                  col = 1:length(fileNames(batch_$xcms_MSnbase)),
                  peakGroupsPch = 1)

# batch_$plot_peak_in_ephe(imetabid = "G011")

isample_mt <- 1000
isample    <- batch_$sample_metab_meas_list[[2]] # "200uM.mzML"

ref_mt <- batch_$refsamppairset$smm_unalign_to_ref_unalign_mt(isample, isample_mt)
print(ref_mt)
print(batch_$refsamppairset$ref_unalign_to_smm_unalign_mt(isample, ref_mt))

print(t(t(batch_$get_annotated_peaks_val_mat()) / batch_$get_annotated_peaks_val_mat()[ "107",]))
# max(t(t(batch_$get_annotated_peaks_val_mat()) / batch_$get_annotated_peaks_val_mat()[ "107",]), na.rm = T)

batch_$plot_peak_in_ephe(imz = 132.101564195421, xlim = c(750, 900), align_mode = "loess")

area_titr <-
  batch_$get_annotated_peaks_val_mat()[ ,
                                       colnames(batch_$get_annotated_peaks_val_mat()) != "STD112" ]

conc <- as.numeric(gsub("uM", "", colnames(area_titr)))

