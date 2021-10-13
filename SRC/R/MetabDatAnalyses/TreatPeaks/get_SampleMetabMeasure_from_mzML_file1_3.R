
library(xcms)
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/MetabBatchSimple2_1.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/Epherogram1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/RefSampPairSet1_1.R")


annotlist_file_ <-
  RSFPath("TRUNK", "cWorks", "Project",
          "MetabolomeGeneral", "CE-MS", "AnnotationList",
          "C_114_annotlist_160809-2_RSC1.csv")
          # "C_114_annotlist_160809-2.csv")
 
mzML_files_ <- c(RSFPath("TMP", "C_114STD_1_partial.mzML"))

batch_ <- MetabBatchSimple()
batch_$import_from_mzml_files(mzML_files_, annotlist_file_)

smm_ <- batch_$sample_metab_meas_list[[1]]
smm_$find_bulk_peaks_all_ephe()
smm_$find_IS_marks(batch_$ref_annotlist)

ref1_ <- SampleMetabMeasure(isamplenam = "Reference 1")
ref1_$set_annotlist(batch_$ref_annotlist)

pairset_ <- RefSampPairSet(ref1_)
pairset_$add_smp(smm_)
pairset_$gen_Reijenga()
annotated_landmarks_ <- pairset_$refsmp_pairs_l[[1]]$annotate_landmarks()
# batch_$ref_annotlist$marks$landmarks

# G011 m/z:76.0393 MT:736.2670 (F1.S1102 736.2670, spectrum 1102)
