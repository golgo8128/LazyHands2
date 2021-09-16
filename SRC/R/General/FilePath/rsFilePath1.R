
# For unit test, rsunit_test_RSFPath <- T and source this.

RS_ENV_DIR_FORMAT <- "RS_%s_DIR"

RSFPath <- function(rs_envar, ...){
  
  return(file.path(Sys.getenv(sprintf(RS_ENV_DIR_FORMAT, rs_envar)), ...))
  
}

# Unit test
if(exists("rsunit_test_RSFPath") && rsunit_test_RSFPath){

  print(RSFPath("TRUNK", "cWorks", "Project", "Nephrology"))
  
}
