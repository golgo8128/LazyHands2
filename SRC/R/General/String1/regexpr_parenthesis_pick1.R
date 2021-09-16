
# For unit test, rsunit_test_regexpr_parenthesis_pick <- T and source this.

# Single string only.
regexpr_parenthesis_pick <- function(iregexpr, istr){

   matchres = regexpr(iregexpr, istr, perl = T)

   match_poss = attr(matchres, "capture.start")
   match_lens = attr(matchres, "capture.len")

   if(length(match_poss) == 0 || match_poss[1] <= 0){
      return(NULL)
   }

   match_poss_end = match_poss + match_lens - 1

   return(apply(rbind(match_poss, match_poss_end), 2,
                function(irange_tmp, istr_tmp){ 
                   substr(istr_tmp, irange_tmp[1], irange_tmp[2])
                }, istr))

}

# Unit test
if(exists("rsunit_test_regexpr_parenthesis_pick") && rsunit_test_regexpr_parenthesis_pick){
 
   print(regexpr_parenthesis_pick("ABC(\\d+)DEF", "ABC123DEF"))   
   print(regexpr_parenthesis_pick("ABC(\\d+)DEF", "ABC123DEFABC456DEF"))   
      print(regexpr_parenthesis_pick("ABC(\\d+)DEF(\\d+)GHI", "ABC111DEF234GHI"))

   }