
dirname_rs <- function(ifullpath){
  
  if(substring(ifullpath, nchar(ifullpath)) == .Platform$file.sep){
    return(substring(ifullpath,1, nchar(ifullpath)-1))    
  } else {
    return(dirname(ifullpath))
  }
  
}

basename_rs <- function(ifullpath){
  
  if(substring(ifullpath, nchar(ifullpath)) == .Platform$file.sep){
    return("")    
  } else {
    return(basename(ifullpath))
  }
  
}

filename_wo_ext <- function(filename){
  
  return(gsub("\\.[^.]*$", "", filename))
  
}

file_ext_rs <- function(filename){
  
  base_filename <- basename_rs(filename)
  filchop <-strsplit(base_filename, "\\.")[[1]]
  if(length(filchop) > 1){
    return(tail(filchop, n=1))
  } else {
    return("")
  }
}

get_fullpath_wo_ext <- function(ifullpath){
  
  dname <- dirname_rs(ifullpath)
  bname <- basename_rs(ifullpath)  
  bname_wo <- filename_wo_ext(bname)
  
  return(paste(dname, bname_wo, sep=.Platform$file.sep))

}

joinpath <- function(...){
# Should consider to use file.path
  
  opath = paste(..., sep=.Platform$file.sep)
  opath <- gsub(paste(.Platform$file.sep, .Platform$file.sep, "+", sep=""), .Platform$file.sep, opath)
  opath <- gsub("/", .Platform$file.sep, opath)
  return(opath)
  
}

get_filepath_info1 <- function(full_path_filename){

  foldername       <- dirname_rs(full_path_filename)
  base_filename    <- basename_rs(full_path_filename)
  bfilename_wo_ext <- filename_wo_ext(base_filename)
  fext             <- file_ext_rs(base_filename)

  return(list(ifilepath     = full_path_filename,
              foldername    = foldername,
              base_filename = base_filename,
              file_ext      = fext,
              base_filename_wo_ext = bfilename_wo_ext,
              ifilepath_wo_ext     = file.path(foldername, bfilename_wo_ext)))

}
