get_current_season<-function(){
  ifelse(as.numeric(strftime(Sys.Date(), "%m"))<3, as.numeric(strftime(Sys.Date(), "%Y"))-1, as.numeric(strftime(Sys.Date(), "%Y")))
}

