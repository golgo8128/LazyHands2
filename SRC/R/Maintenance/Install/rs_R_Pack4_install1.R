
rs_R_Pack_dir_name <- "rs_R_Pack4"
dot_Rprofile_org   <- file.path("Maintenance", "Startup", "dot_Rprofile10.R")

cur_time_str  <- format(Sys.time(), "%Y%m%d%H%M%S")
cur_wdir      <- getwd()
cur_wdir_sepd <- strsplit(cur_wdir, .Platform$file.sep)[[1]]

if(!(rs_R_Pack_dir_name %in% cur_wdir_sepd)){
  stop(paste("This installation script must be invoked via \"source\" function",
             "after setting the current working directory to the one in",
             rs_R_Pack_dir_name))
}

rs_R_Pack4_dir             <- paste(cur_wdir_sepd[1:max(which(rs_R_Pack_dir_name == cur_wdir_sepd))],
                                    collapse=.Platform$file.sep)
dot_Rprofile_org_path      <- file.path(rs_R_Pack4_dir, dot_Rprofile_org)

dot_Rprofile_cano_path     <- file.path(Sys.getenv("HOME"), ".Rprofile")
dot_Rprofile_cano_bak_path <- paste(dot_Rprofile_cano_path,
                                    "_",
                                    cur_time_str,
                                    ".bak", sep="")

if(file.exists(dot_Rprofile_cano_path)){
  file.copy(dot_Rprofile_cano_path, dot_Rprofile_cano_bak_path)
  cat(sprintf("The existing .Rprofile has been moved to %s.\n", dot_Rprofile_cano_bak_path))
}

fh <- file(dot_Rprofile_org_path, open = "r")
dot_Rprofile_lines <- readLines(fh)
close(fh)

target_line_idx <- which(grepl("^\\s*RS_R_Pack4_ROOT\\s*<<-", dot_Rprofile_lines, perl = T))
dot_Rprofile_lines[ target_line_idx ] <- sprintf("RS_R_Pack4_ROOT <<- \"%s\" # Configured on %s", rs_R_Pack4_dir, cur_time_str)

fw <- file(dot_Rprofile_cano_path, open = "w")
writeLines(dot_Rprofile_lines, fw)
close(fw)

source(dot_Rprofile_cano_path)

cat(sprintf("Configuring %s installation on %s has been completed.\n", rs_R_Pack_dir_name, rs_R_Pack4_dir))
cat(sprintf("However, make sure to install necessary R packages.\n"))
