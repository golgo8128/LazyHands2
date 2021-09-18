
# For unit test, rsunit_merge_lists <- T and source this.

merge_two_lists <- function(ilist1, ilist2){

  olist <- ilist1
  for(ckey in names(ilist2)){
    olist[[ ckey ]] <- ilist2[[ ckey ]]
  }
  
  return(olist)
  
}  


# Unit test
if(exists("rsunit_merge_lists") && rsunit_merge_lists){
  
  print(merge_two_lists(list(a = 10, b = 20),
                        list(a = 30, b = 40, c = 10)))
  
}
