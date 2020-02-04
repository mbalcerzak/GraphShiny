library("rlist")
library("purrr")
library("stringr")
#library("dplyr")

NotDomain <- c("SDTM", "VAL", "WORK")

path_raw <- 'X:/SASDATA/Entimice_Contingency/root/cdar/d518/d5180c00009/ar/bdr2/raw/dev/data/data_area'
path <- 'X:/SASDATA/Entimice_Contingency/root/cdar/d518/d5180c00009/ar/bdr2/sdtm/work_val/program/'


path_file <- paste(getwd(),"/paths.txt",sep="")
for (line in readLines(file(path_file), warn = FALSE)) {
  print(line)
}


file_list <- list.files(path, pattern="*.sas")
raw_list <- list.files(path_raw, pattern="*.sas7bdat")

raw_list <- lapply(raw_list, function(x) toupper(paste("RAW.",str_replace(x, ".sas7bdat",""), sep="")))

processFile <- function(path, fileName) {
  filepath = paste(path, fileName, sep="")
  
  list_matches <- c()
  con = file(filepath, "r")
  
  lines <- readLines(con, warn = FALSE)
  
  for (line in lines) {
    line = toupper(line)
    
    r = regmatches(line, gregexpr("RAW\\.[A-Z0-9]+", line))
    if (!is.na(r[[1]][1])){
      list_matches <- list.append(list_matches, r)
    }
    
    s = regmatches(line, gregexpr("SDTM\\.[A-Z0-9]+", line))
    if (!is.na(s[[1]][1])){
      list_matches <- list.append(list_matches, s)
    }
    
  }
  
  final <- unique(unlist(list_matches, use.names = FALSE))
  close(con)
  return(final)
}

lista = c()

for (file in file_list){
  
  domain <- unlist(strsplit(file, "_"))
  domain <- regmatches(domain, gregexpr("[A-Za-z]+\\.sas", domain))[-1]
  domain <- gsub(".sas","",domain)
  domain <- toupper(domain[-1])
  
  if (any(domain %in% NotDomain)) { }
  else if (length(domain) > 0) {
    print(" --------------------------------------- ")
    print(paste("SDTM.",domain,sep=""))
    print(processFile(path, file))
  }
}

