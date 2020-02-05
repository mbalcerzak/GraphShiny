library("rlist")
library("purrr")
library("stringr")

NotDomain <- c("RAW","SDTM","VAL")

# -------------------- read in the .txt file with paths --------------------------
assign_paths <- function(phrase, fileName){

  path_file <- paste(getwd(), fileName, sep="")
  con <- file(path_file, encoding = "UTF-8")
  
  for (line in readLines(con, warn = FALSE)) {
    if (startsWith(line, phrase)) {
      path <- unlist(strsplit(line, "<-"))[-1]
      close(con)
      return(path)
    }
  }
}

# "/paths.txt" is the file where I store paths 
# looks exaclty like the example provided ("paths_example.txt")

path_raw <- assign_paths("RAW", "/paths.txt")
path <- assign_paths("PROGRAM", "/paths.txt")

# ----------------------------------------------------------------------------------

file_list <- list.files(path, pattern="*.sas")
raw_list <- list.files(path_raw, pattern="*.sas7bdat")

raw_list <- lapply(raw_list, function(x) toupper(paste("RAW.",str_replace(x, ".sas7bdat",""), sep="")))

processFile <- function(path, fileName, domain) {
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

  domain_col <- rep(c(domain), times = length(final))
  
  df <- as.data.frame(list(list(final), domain_col))
  colnames(df) <- c("target","source")
  
  df <- subset(df, as.character(target) != as.character(source))
  
  return(df)
}

lista = c()

df_all <- data.frame(matrix(ncol = 2, nrow = 0))
colnames(df_all) <- c("target","source")

for (file in file_list){
  
  domain <- unlist(strsplit(file, "_"))
  domain <- regmatches(domain, gregexpr("[A-Za-z]+\\.sas", domain))[-1]
  domain <- gsub(".sas","",domain)
  domain <- toupper(domain[-1])
  
  if (any(domain %in% NotDomain)) { }
  else if (length(domain) > 0) {
    print(" --------------------------------------- ")
    domain <- paste("SDTM.",domain,sep="")
    df <- processFile(path, file, domain)
    print(df)
    df_all <- rbind(df_all, df)
  }
}

write.csv(df_all,'dataframe.csv')