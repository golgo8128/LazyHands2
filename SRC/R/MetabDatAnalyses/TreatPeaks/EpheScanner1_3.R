
source.RS("MetabDatAnalyses/TreatPeaks/SampleMetabMeasure1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/EPherogram1_3.R")
source.RS("MetabDatAnalyses/TreatPeaks/RefSampPairSingle1_2.R")

source.RS("Usefuls1/consec_hits1.R")
source.RS("Usefuls1/find_identical_elems_in_list1.R")

EPheScanner <-
  setRefClass("EPheScanner",
              fields = list(
                refsamppair = "ANY", # Intended for RefSampPairSingle,
                # ref         = "SampleMetabMeasure",
                smp_ephe    = "EPherogram",
                
                metab_id    = "character",
                mz          = "numeric",
                ppm         = "numeric",

                segms_info  = "list",
                # segms_info[[ i ]]
                #   $segm_split_annot_metabids
                #   $segm_split_annot_mt_range
                #   $peak_dist_split[[ j ]]
                #      $metabids_mts_subsegms

                h           = "list"
              ))

EPheScanner$methods(
  show_segms =
    function(iextra_range_rate = 0.2,
             imt_adjust_method = "reijenga"){

    cat("***** EPheScanner Segment Information *****\n")     
    for(i in 1:length(.self$segms_info)){
      
      cat(sprintf("*** Segment %d - Ref. Range %s\n",
                  i,
                  paste(.self$segms_info[[ i ]]$segm_split_annot_mt_range,
                        collapse = " - ")))
      
      cat(sprintf("Rerefence metabolites: %s\n",
                  paste(.self$segms_info[[ i ]]$segm_split_annot_metabids,
                        collapse = ", ")))
  
      for(j in 1:length(.self$segms_info[[ i ]]$peak_dist_split)){
        
        cat(sprintf("* Subsegment %d-%d\n", i, j))
        print(.self$segms_info[[ i ]]$peak_dist_split[[ j ]]$metabids_mts_subsegms)
        
        smp_target_range <-
          .self$det_smp_target_range(i, j,
                                     iextra_range_rate,
                                     imt_adjust_method)
        cat(sprintf("[ Sample ] Target range: %s\n",
                    paste(smp_target_range, collapse = " - ")))
             
        if(length(.self$smp_ephe$peak_list)){
          smp_target_peaks <-
            .self$det_smp_target_peaks(i, j,
                                       iextra_range_rate,
                                       imt_adjust_method)
          for(k in 1:length(smp_target_peaks)){
            cat(sprintf("[ Sample ] Peak %d - MT: %f  Annot. ID: %s\n",
                        k,
                        smp_target_peaks[[ k ]]$mt_top,
                        smp_target_peaks[[ k ]]$peak_annot_id))            
          }
        }
        
      }

      cat("\n")
            
    }
    
    cat("\n")
    
  })

EPheScanner$methods(
  initialize =
    function(irefsamppair,
             imetab_id = NULL,
             imz = NULL, ippm = 100){
      
      .self$refsamppair <- irefsamppair

      if(!is.null(imetab_id)){
        imz <-
          .self$refsamppair$ref$annotlist$annotlist_dfrm[ imetab_id, "m/z" ]
        .self$metab_id <- imetab_id
      }
      
      smp_ephe_obj <-
        .self$refsamppair$smp$find_ephe_mz(imz = imz, ippm = ippm)
      
      if(!is.null(smp_ephe_obj)){
        .self$smp_ephe <- smp_ephe_obj
      }   
      
      
    })

EPheScanner$methods(
  segm_split_by_annot_peaks =
    function(icut_thres_mt, imz, ippm = 100){

      ref_metabids_mts <-
        .self$refsamppair$ref$annotlist$get_metabs_similar_mz(
          imetab_id = NULL, imz = imz, ippm = ippm)
      
      already_annot_pk_bools <- 
        names(ref_metabids_mts) %in%
          rownames(.self$smp_ephe$sampmmeasr$annotlist$annotlist_dfrm)
      
      mt_left_limits <-
        c(0, ref_metabids_mts[ already_annot_pk_bools ])
      
      mt_right_limits <-
        c(ref_metabids_mts[ already_annot_pk_bools ], Inf)
      
      lmark_flanking_poss_mat <-
        consec_true_positions(!already_annot_pk_bools)
      
      if(nrow(lmark_flanking_poss_mat)){
      
        metabids_lmark_flanks <-
          lapply(1:nrow(lmark_flanking_poss_mat),
                 function(i_){
                   names(ref_metabids_mts)[
                     lmark_flanking_poss_mat[ i_, 1 ] :
                       lmark_flanking_poss_mat[ i_, 2 ]
                   ]})
        
        for(i in 1:length(metabids_lmark_flanks)){
          
          ref_metabids_sub <-
            metabids_lmark_flanks[[ i ]]
          ref_metabids_mts_sub <-
            ref_metabids_mts[ ref_metabids_sub ]
          
          ref_metabids_mts_subsub_l <-
            split_by_distance(ref_metabids_mts_sub, icut_thres_mt)
          ref_metabids_mts_subsub_l2 <- list()
          for(j in 1:length(ref_metabids_mts_subsub_l)){
            ref_metabids_mts_subsub_l2[[ j ]] <-
              list(metabids_mts_subsegms = ref_metabids_mts_subsub_l[[ j ]])
          }
          
          .self$segms_info[[ i ]] <-
            list(segm_split_annot_metabids = metabids_lmark_flanks[[ i ]],
                 segm_split_annot_mt_range = c(mt_left_limits[i],
                                               mt_right_limits[i]),
                 peak_dist_split           = ref_metabids_mts_subsub_l2
                 )
  
        }
      }
      
  })


EPheScanner$methods(
  det_smp_target_range =
    function(isegm_i, isubsegm_j,
             iextra_range_rate = 0.2,
             imt_adjust_method = "reijenga"){

      mt_left_limit  <-
        .self$segms_info[[ isegm_i ]]$segm_split_annot_mt_range[1]
      mt_right_limit <-
        .self$segms_info[[ isegm_i ]]$segm_split_annot_mt_range[2]

      ref_metabids_mts_subsub <-
        .self$segms_info[[ isegm_i ]]$peak_dist_split[[ isubsegm_j ]]$metabids_mts_subsegms

      if(length(ref_metabids_mts_subsub)){
        mt_left_range  <- ref_metabids_mts_subsub[1] * (1-iextra_range_rate)
        mt_right_range <- tail(ref_metabids_mts_subsub, 1) + (1+iextra_range_rate)
        if(mt_left_range < mt_left_limit){
          mt_left_range <- mt_left_limit
        }
        if(mt_right_range > mt_right_limit){
          mt_right_range <- mt_right_limit
        }
        
        if(imt_adjust_method == "reijenga"){    
          mt_left_range_on_sample <-
            .self$refsamppair$map_from_ref(mt_left_range)
          mt_right_range_on_sample <-
            .self$refsamppair$map_from_ref(mt_right_range) 
          
        } else if(imt_adjust_method == "loess"){
          mt_left_range_on_sample <-
            .self$refsamppair$ref_unalign_to_smm_unalign_mt(mt_left_range)
          mt_right_range_on_sample <-
            .self$refsamppair$ref_unalign_to_smm_unalign_mt(mt_right_range)
          
        } else {
          mt_left_range_on_sample  <- mt_left_range
          mt_right_range_on_sample <- mt_right_range
        }      
      
      }
      
      return(c(mt_left_range_on_sample,
               mt_right_range_on_sample))
      
  })


EPheScanner$methods(
  det_smp_target_peaks =
    function(isegm_i, isubsegm_j,
             iextra_range_rate = 0.2,
             imt_adjust_method = "reijenga"){

      mt_range <-
        .self$det_smp_target_range(
          isegm_i, isubsegm_j,
          iextra_range_rate,
          imt_adjust_method)
        
      target_peaks <-
        .self$smp_ephe$get_peaks(
          imt_range = mt_range)
      
      return(target_peaks)
      
  })


EPheScanner$methods(
  search_conn_patt_segm =
    function(isegm_i, isegm_j){
      
      ref_metabids_mts_subsub <-
        .self$segms_info[[ isegm_i ]]$
          peak_dist_split[[ isegm_j ]]$metabids_mts_subsegms
      
      target_peaks <-
        .self$det_smp_target_peaks(isegm_i, isegm_j)
      
      target_peaks_annot_bools <-
        sapply(target_peaks,
               function(tmppk){
                 if(tmppk$peak_annot_id != ""){ TRUE } else { FALSE }})
      # target_peaks_looked_bools <-
      #   check_identical_elems_in_list_over_objs(
      #     target_peaks, looked_peaks
      #   )
      
      target_peaks <-
        target_peaks[ (!target_peaks_annot_bools) ]
      #    & (!target_peaks_looked_bools) ]
      
      
      max_score <- -Inf
      optimal_ref_sel <- NULL
      optimal_smp_sel <- NULL
      
      if(length(target_peaks)){
        
        cat(sprintf("* Peak matching for subsegment %d-%d\n",
                    isegm_i, isegm_j))
        cat("Reference metabolites:\n")
        print(ref_metabids_mts_subsub)
        cat("[ Sample ] Target peaks\n")
        
        for(k in 1:length(target_peaks)){
          cat(sprintf("[ Sample ] Peak %d - MT: %f  Annot. ID: %s\n",
                      k,
                      target_peaks[[ k ]]$mt_top,
                      target_peaks[[ k ]]$peak_annot_id))            
        }
        
        
        pairing_pat <-
          PairingOrderedPat(length(ref_metabids_mts_subsub),
                            length(target_peaks))
        
        cpat <- pairing_pat$next_pat()
        while(!cpat$allpatout_flag){
          # print(cpat)
          
          score <-
            .self$eval_peak_matching(ref_metabids_mts_subsub,
                                     target_peaks,
                                     cpat$nums1, cpat$nums2)
          if(score > max_score){
            max_score <- score
            optimal_ref_sel <- cpat$nums1
            optimal_smp_sel <- cpat$nums2
          }
          
          cpat <- pairing_pat$next_pat()
          
        }
        
        # looked_peaks <- c(looked_peaks, target_peaks)
        
      }

      return(list(
        max_score = max_score,
        matched_ref_metabids_mts = ref_metabids_mts_subsub[ optimal_ref_sel ],
        matched_smp_peaks        = target_peaks[ optimal_smp_sel ]
      ))
      
    })


EPheScanner$methods(
  gothrough_all_segms =
    function(){
      
      if(length(.self$segms_info)){
      
        for(i in 1:length(.self$segms_info)){
          for(j in 1:length(.self$segms_info[[i]]$peak_dist_split)){
            
            match_res <- .self$search_conn_patt_segm(i, j)
            cat(sprintf("- Result for subsegment %d-%d\n", i, j))
            cat(sprintf("Score: %f\n", match_res$max_score))
            # print(match_res)
            for(k in 1:length(match_res$matched_ref_metabids_mts)){
              
              ref_metabid <- names(match_res$matched_ref_metabids_mts[k])
              ref_mt      <- match_res$matched_ref_metabids_mts[k]
              smp_pk      <- match_res$matched_smp_peaks[[k]]
              smp_mt      <- smp_pk$mt_top
              
              .self$smp_ephe$sampmmeasr$
                annotate_peak_metabid(ipk = smp_pk,
                                      imetabid = ref_metabid)
              
              cat(sprintf("Ref. %s MT:%f - Sample MT:%f\n",
                          ref_metabid, ref_mt, smp_mt))
              
            }
            cat("--- --- --- --- ---\n\n")
  
          }
        }
      }
      
  })


EPheScanner$methods(
  eval_peak_matching =
    function(segm_ref_metabids_mts,
             segm_smp_peaks_l,
             sel_ref, sel_smp,
             imt_adjust_method = "reijenga"){
      
      if(length(sel_ref)){
        
        sel_ref_metabids_mts <- segm_ref_metabids_mts[ sel_ref ]
        sel_smp_peaks_l      <- segm_smp_peaks_l[ sel_smp ]
        
        # sel_ref_mts <-
        #   .self$refsamppair$ref$annotlist$annotlist_dfrm[sel_ref_metabids, "MT" ]
        
        sel_smp_mts <- sapply(sel_smp_peaks_l, function(tmppk){ tmppk$mt_top })
        
        if(imt_adjust_method == "reijenga"){
          sel_smp_mts <-
            .self$refsamppair$map_to_ref(sel_smp_mts)
        } else if(imt_adjust_method == "loess"){
          sel_smp_mts <-
            .self$refsamppair$smm_unalign_to_ref_unalign_mts(sel_smp_mts)
        }

        umbratio_f  <- function(a_, b_){ min(a_, b_) / max(a_, b_)}
        umbratios_f <- function(av_, bv_){ 
          sapply(1:length(av_),
                 function(i_){ umbratio_f(av_[i_], bv_[i_]) })
        }
        
        score <-
          length(sel_ref) * prod(umbratios_f(sel_ref_metabids_mts, sel_smp_mts))
        
        cat("Peak matching - reference:\n")
        print(sel_ref_metabids_mts)
        cat("Peak matching - sample:\n")
        print(sel_smp_mts)
        cat(sprintf("Score: %f\n", score))

        
      } else {
        
        score <- 0
        cat("No connection\n")
      
      }
      

      return(score)
      
    })



      