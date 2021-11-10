# R startup script
# Name this file ".Rprofile" and place it under ~/
# If you invoke rm(list = ls()), you have to rerun this script.
#
# On Windows, escapes are necessary if using "\" separator, i.e. "C:\\Docu\\File.doc"

RS_R_Pack4_ROOT <<-
  normalizePath(file.path(Sys.getenv("RS_PROG_DIR"), "rs_R", "rs_R_Pack4"),
                winslash = "/")
  # file.path(Sys.getenv("RS_PROG_DIR"), "rs_R", "rs_R_Pack4")
  #"/Users/rsaito/UNIX/rs_Progs/rs_R/rs_R_Pack4"

RS_R_Pack4_DIR <<- c("./",
                     RS_R_Pack4_ROOT,
                     paste(RS_R_Pack4_ROOT, "General", sep="/"))

RS_R_Pack4_VAR <<- list(source.RS_loaded_files = NULL,
                        cnf.RS_loaded          = list())

RS_R_Pack4_Used_OBJ_NAMES <<- c("RS_R_Pack4_Used_OBJ_NAMES",
                                "clear.RS", "ls.RS",
                                "RS_R_Pack4_ROOT", "RS_R_Pack4_DIR", "RS_R_Pack4_VAR",
                                "source.RS", "readcnf.RS", "RS_R_Pack4_Startup_Message")

clear.RS <- function(){
  
  cur_objs       <- ls(envir=globalenv())
  to_remove_objs <- cur_objs[!(cur_objs %in% RS_R_Pack4_Used_OBJ_NAMES)]
  cat("Removing the following object(s):\n")
  print(to_remove_objs)
  rm(list=to_remove_objs, envir=globalenv())
  
  RS_R_Pack4_VAR <<- list(source.RS_loaded_files = NULL,
                          cnf.RS_loaded          = list())
  
}

ls.RS <- function(){
  
  cur_objs       <- ls(envir=globalenv())
  objs <- cur_objs[!(cur_objs %in% RS_R_Pack4_Used_OBJ_NAMES)]
  return(objs)  
  
}

source.RS <- function(source_file_name, reload = FALSE, ...){
# If reload = F, be careful of conflict of source file name.
# Also keep in mind that source function in source_file_name will not be called.
  
# sys.frame(1)$ofile useful?
  
   # source_file_name <-  gsub("/", .Platform$file.sep, source_file_name)
   loaded = FALSE

   if(!is.null(sys.frame(1)$ofile)){
     start_exec_scr_file <- normalizePath(sys.frame(1)$ofile, winslash = "/")
     if(!(start_exec_scr_file %in% RS_R_Pack4_VAR$source.RS_loaded_files)){
       RS_R_Pack4_VAR$source.RS_loaded_files <<-
         append(RS_R_Pack4_VAR$source.RS_loaded_files, start_exec_scr_file)
     }
   }
   
   for(path in RS_R_Pack4_DIR){
     
     fpath <- file.path(path, source_file_name)

     if(!file.exists(fpath)){ next }
     
     fpath <- normalizePath(fpath, winslash = "/")

     if(fpath %in% RS_R_Pack4_VAR$source.RS_loaded_files && !reload){
         loaded = TRUE
         # cat(sprintf("Source file \"%s\" already loaded.\n", source_file_name))
         break # Other option of paths will not be checked.
     }
       
     RS_R_Pack4_VAR$source.RS_loaded_files <<-
        append(RS_R_Pack4_VAR$source.RS_loaded_files, fpath) # Reciprocal sourcing OK here?
     # print(RS_R_Pack4_VAR$source.RS_loaded_files)
     # cat(sprintf("Loading \"%s\" ...\n", fpath))
     source(fpath, ...)
     # RS_R_Pack4_VAR$source.RS_loaded_files <<-
     #    append(RS_R_Pack4_VAR$source.RS_loaded_files, source_file_name)   
     loaded = TRUE
     break
     
   }

   if(!loaded){
     stop("Source file ", dQuote(source_file_name), " not found.")
   }
   
}

readcnf.RS <- function(cnf_base_filename){
  # This must be base file name.
  
  if(cnf_base_filename %in% names(RS_R_Pack4_VAR$cnf.RS_loaded)){
      # cat(sprintf("Configuration file \"%s\" already loaded.\n", cnf_base_filename))
      return(RS_R_Pack4_VAR$cnf.RS_loaded[[cnf_base_filename]])
  }
  
  
  ##### For configuration file parsing (Begin) ######
  # Be careful about variable name conflict. Do not use too many variable names at readcnf.RS function level.
  
  rsConfig_remove_comment <- function(iline, whole_line_comment_check_only = F){
    
    oline <- sub("^\\s*#.*", "", iline, perl=T)   # Whole line
    
    if(!whole_line_comment_check_only){
      oline <- sub("\\s+#.*$", "", oline, perl=T) # Line tail
    }
    
    return(oline)
    
  }
  
  rsConfig_replace_by_envar <- function(istr){
    
    mres <- T
    ostr <- istr
    
    check_str        <- "rsConfig_replace_by_envar_hit: "
    repl_pos_locator <- " !!rsConfig_replace_here!! " 
    
    mres = check_str
    
    while(length(grep(check_str, mres))){
      mres = sub("^[^\\$]*\\$\\{([^\\}]+)\\}.*$",
                 paste(check_str, "\\1", sep=""),
                 ostr, perl=T)
      if(length(grep(check_str, mres))){
        envar = sub(check_str, "", mres)
        ostr = sub("\\$\\{([^\\}]+)\\}",
                   repl_pos_locator,
                   ostr, perl=T)
        ostr = sub(repl_pos_locator, Sys.getenv(envar), ostr, fixed = T)
      }
    }
    
    return(ostr)
    
  }
  
  
  rsConfig_parse_envar_assignment <- function(iline){ 
    
    split_str <- " rsConfig_parse_envar_assignment_split_str "
    
    mtest_squo <- grep("^\\s*(\\S+)\\s*=\\s*'([^'\\t]*)'\\s*", iline, perl=T) 
    
    if(length(mtest_squo)){
      mres_squo      <- sub("^\\s*(\\S+)\\s*=\\s*'([^'\\t]*)'.*",
                            paste("\\1", "\\2", sep=split_str),
                            iline, perl=T)
      mres_rest_squo <- sub("^\\s*(\\S+)\\s*=\\s*'([^'\\t]*)'\\s*",
                            "",
                            iline, perl=T)
      assign_squo <- strsplit(mres_squo, split=split_str, fixed = T)[[1]]
      return(c(assign_squo[1], assign_squo[2], mres_rest_squo))
      
    }
    
    
    mtest_dquo <- grep("^\\s*(\\S+)\\s*=\\s*\"([^\"\\t]*)\"\\s*", iline, perl=T)
    
    if(length(mtest_dquo)){
      mres_dquo      <- sub("^\\s*(\\S+)\\s*=\\s*\"([^\"\\t]*)\".*",
                            paste("\\1", "\\2", sep=split_str),
                            iline, perl=T)
      mres_rest_dquo <- sub("^\\s*(\\S+)\\s*=\\s*\"([^\"\\t]*)\"\\s*",
                            "",
                            iline, perl=T)
      assign_dquo <- strsplit(mres_dquo, split=split_str, fixed = T)[[1]]
      return(c(assign_dquo[1], rsConfig_replace_by_envar(assign_dquo[2]), mres_rest_dquo))
    }
    
    mtest <- grep("^\\s*(\\S+)\\s*=\\s*(\\S*)\\s*", iline, perl=T)
    
    if(length(mtest)){
      mres <- sub("^\\s*(\\S+)\\s*=\\s*(\\S*).*",
                  paste("\\1", "\\2", sep=split_str),
                  iline, perl=T)
      mres_rest <- sub("^\\s*(\\S+)\\s*=\\s*(\\S*)\\s*",
                       "",
                       iline, perl=T)
      assign_nquo <- strsplit(mres, split=split_str, fixed = T)[[1]]
      return(c(assign_nquo[1], rsConfig_replace_by_envar(assign_nquo[2]), mres_rest))  
    }
    
    return(NULL)
    
  }
  
  
  rsConfig_parse_config <- function(iline){
    
    split_str <- " rsConfig_parse_config_split_str "  
    
    mtest_squo <- grep("^\\s*(\\S+)\\s+'([^'\\t]*)'\\s*", iline, perl=T)
    
    if(length(mtest_squo)){
      mres_squo <- sub("^\\s*(\\S+)\\s+'([^'\\t]*)'.*",
                       paste("\\1", "\\2", sep=split_str),
                       iline, perl=T)
      mres_rest_squo <- sub("^\\s*(\\S+)\\s+'([^'\\t]*)'\\s*",
                            "",
                            iline, perl=T)
      assign_squo <- strsplit(mres_squo, split=split_str, fixed = T)[[1]]
      return(c(assign_squo[1], assign_squo[2], mres_rest_squo))
    }
    
    mtest_dquo <- grep("^\\s*(\\S+)\\s+\"([^\\t\"]*)\"\\s*", iline, perl=T)
    
    if(length(mtest_dquo)){
      mres_dquo <- sub("^\\s*(\\S+)\\s+\"([^\\t\"]*)\".*",
                       paste("\\1", "\\2", sep=split_str),
                       iline, perl=T)
      mres_rest_dquo <- sub("^\\s*(\\S+)\\s+\"([^\\t\"]*)\"\\s*",
                            "", iline, perl=T)
      assign_dquo <- strsplit(mres_dquo, split=split_str, fixed=T)[[1]]
      return(c(assign_dquo[1], rsConfig_replace_by_envar(assign_dquo[2]), mres_rest_dquo))
    }
    
    mtest <- grep("^\\s*(\\S+)\\s+(\\S*)\\s*", iline, perl=T)
    
    if(length(mtest)){
      mres <- sub("^\\s*(\\S+)\\s+(\\S*).*",
                  paste("\\1", "\\2", sep=split_str),
                  iline, perl=T)
      mres_rest <- sub("^\\s*(\\S+)\\s+(\\S*)\\s*",
                       "", iline, perl=T)
      assign_nquo <- strsplit(mres, split=split_str, fixed=T)[[1]]
      return(c(assign_nquo[1], rsConfig_replace_by_envar(assign_nquo[2]), mres_rest))    
      
    }
    
    return(NULL)
    
  }
  
  rsConfig_read_cnf_file <- function(config_file){
    
    ret = list()
    
    fh <- file(config_file, open="r")
    ilines <- readLines(fh)
    close(fh)
    
    for(iline_raw in ilines){
      iline <- rsConfig_remove_comment(iline_raw, whole_line_comment_check_only = T)
      prs_envar  <- rsConfig_parse_envar_assignment(iline)
      prs_config <- rsConfig_parse_config(iline)
      
      if(!is.null(prs_envar)){
        eval(parse(text = sprintf("Sys.setenv(%s = %s)", prs_envar[1], prs_envar[2])))    
        iline_left <- prs_envar[3]
      } else if(!is.null(prs_config)){
        ret[[ prs_config[1] ]] <- prs_config[2]
        iline_left <- prs_config[3]
      } else {
        iline_left = iline
      }
      
      if(rsConfig_remove_comment(iline_left) != ""){
        stop(sprintf("rsConfig file parsing error (%s) ... : %s",
                     config_file, rsConfig_remove_comment(iline_left)))
      }
      
    }
    
    return(ret)
    
  }  

  
  ##### For configuration file parsing (End) ######  

  
  
  rsCNF_info <- 
     rsConfig_read_cnf_file(file.path(Sys.getenv("RS_CONFIG_DIR"), cnf_base_filename))
   
  RS_R_Pack4_VAR$cnf.RS_loaded[[ cnf_base_filename ]] <<- rsCNF_info
   
  return(rsCNF_info)

}

RS_R_Pack4_Startup_Message <- function(){

   cat("#########################################\n")
   cat("##### Welcome to rs_R_Pack4 system! #####\n")
   cat("#########################################\n")
   cat("- Operation initiated : 2012-06-19\n")
   cat("- Last modification   : 2021-08-09\n\n")

}

RS_R_Pack4_Startup_Message()


