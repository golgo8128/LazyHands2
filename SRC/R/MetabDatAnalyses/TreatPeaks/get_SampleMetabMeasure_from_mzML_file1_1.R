
library(xcms)
source.RS("MetabDatAnalyses/TreatPeaks/AnnotList1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/MetabBatchSimple2_1.R")
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_2.R")
source.RS("MetabDatAnalyses/TreatPeaks/Epherogram1_2.R")


iannotlist_file <-
  RSFPath("TRUNK", "cWorks", "Project",
          "MetabolomeGeneral", "CE-MS", "AnnotationList",
          "C_114_annotlist_160809-2.csv")

imzML_files <- c(RSFPath("TMP", "C_114STD_1_partial.mzML"))

annotlist <- AnnotList(iannotlist_file)
target_mz_range_mat <- annotlist$get_mz_range_dfrm()


xcms_rawdat_obj <-
  readMSData(imzML_files, mode = "onDisk")
chromats_extracted <-
  chromatogram(xcms_rawdat_obj, mz = target_mz_range_mat)

batch <- MetabBatchSimple()

for(sample_idx in 1:ncol(chromats_extracted)){
  
  smm <-
    SampleMetabMeasure(idatfilnam = fileNames(xcms_rawdat_obj)[ sample_idx ],
                       isamplenam = basename(fileNames(xcms_rawdat_obj)[ sample_idx ]))
  
  for(chromat_idx in 1:nrow(chromats_extracted)){
    chromat <- chromats_extracted[ chromat_idx, sample_idx ]
   
    ephe <- EPherogram(cbind(rtime(chromat), intensity(chromat)))
    ephe$set_mz(annotlist$annotlist_dfrm[ chromat_idx, "m/z" ])
    smm$add_ephe(ephe) 
  }
  
  batch$add_sample(smm)
  
}



