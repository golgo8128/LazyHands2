
# For unit test, rsunit_test_find_identical_elems_in_list <- T and source this.

check_identical_elems_in_list <-
  function(iobj, ilist){
    
    if(length(ilist)){
      ovec <- 
        sapply(ilist, function(tmpelem){
          identical(tmpelem, iobj)
        })
    } else {  
      ovec <- NULL
    }
    
    return(ovec)
      
  }

check_identical_elems_in_list_over_objs <-
  function(iobjs, ilist){
    
    # if(length(ilist)){
      ovec <-
        sapply(iobjs,
               function(tmpobj){
                 any(check_identical_elems_in_list(tmpobj, ilist))
               }
              )
    # } else {
    #  ovec <- NULL
    # }
      
    return(ovec)    
    
  }


# Unit test
if(exists("rsunit_test_find_identical_elems_in_list") &&
   rsunit_test_find_identical_elems_in_list){

  Klass <-
    setRefClass("Klass",
                fields = list(
                  attr = "numeric"
                ))
  Klass$methods(initialize =
                       function(iattr){
                         .self$attr = iattr
                       })
  
  obj1_ = Klass(1)
  obj2_ = Klass(1)
  obj3_ = Klass(1)  
  obj4_ = Klass(2)    
  obj5_ = Klass(2)  
  obj6_ = Klass(3) 
  obj7_ = Klass(3) 
  obj8_ = Klass(3) 
          
  print(check_identical_elems_in_list_over_objs(
    list(obj2_, obj3_, obj5_, obj7_),
    list(obj1_, obj2_, obj3_, obj6_, obj8_)
  ))    
    
}

