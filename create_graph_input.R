library("rlist")
library("purrr")
library("stringr")

NotDomain <- c("VAL","MASTER","SDTM")
#NotDomain <- c()

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

# ----------------------- make sure paths are correct ------------------------------

# "/paths.txt" is the file where I store paths 
# looks exaclty like the example provided ("paths_example.txt")
paths_txt <-  "/paths.txt"

# Dataset paths
path_raw_data <- assign_paths("RAW_DATA",paths_txt)
path_sdtm_data <- assign_paths("SDTM_DATA", paths_txt)

# Program paths
path_sdtm_program <- assign_paths("SDTM_PROGRAM", paths_txt)
path_adam_program <- assign_paths("ADAM_PROGRAM", paths_txt)

# ------------------- create the graph input dataset --------------------------------

# 1. Read in all datasets that are in RAW folder

datasets_f <- function(path, pattern){
  
  clean <- function(x){
    x <- paste(pattern,str_replace(x, ".sas7bdat",""), sep="")
    invisible(toupper(x))
  }
  
  datasets_list <- list.files(path, pattern="*.sas7bdat")
  clean_list <- lapply(datasets_list, function(x) clean(x))
  
  invisible(clean_list)
}

# not used yet raw - ADD
raw_list <- datasets_f(path_raw, "RAW.")
#sdtm_list <- datasets_f(path_sdtm, "SDTM.")


# 2. Create a list of all programs in validation folder in SDTM /ADaM folders

program_list_sdtm <- list.files(path_sdtm_program, pattern="*.sas")
#program_list_adam <- list.files(path_adam_program, pattern="*.sas")


# 3. Return datasets present in the validation program that are also in point 2.

processFile <- function(path, fileName, domain, data_patterns) {
  
  filepath = paste(path, fileName, sep="")
  print(filepath)
  list_matches <- c()
  con = file(filepath, "r")
  
  lines <- readLines(con, warn = FALSE)
  
  for (line in lines) {
    line = toupper(line)
    
    for (pattern in data_patterns) {
      
      data_ = regmatches(line, gregexpr(pattern, line))
      if (!is.na(data_[[1]][1])){
        list_matches <- list.append(list_matches, data_)
      }
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



# 4. Create a dataframe containing all results
#    - different colours for different levels
#    - must contain two non-empy columns: source, target (for the graph)

data_patterns <- c("RAW\\.[A-Z0-9]+", "SDTM\\.[A-Z0-9]+")

lista = c()

df_all <- data.frame(matrix(ncol = 2, nrow = 0))
colnames(df_all) <- c("target","source")

for (file in program_list_sdtm){
  #print(file)
  domain <- unlist(strsplit(file, "_"))
  domain <- regmatches(domain, gregexpr("[A-Za-z]+\\.sas", domain))[-1]
  domain <- gsub(".sas","",domain)
  domain <- toupper(domain[-1])
  
  
  if (any(domain %in% NotDomain)) { }
  else if (length(domain) > 0) {
    
    print(" --------------------------------------- ")
    domain <- paste("SDTM.",domain, sep="")
    df <- processFile(path_sdtm_program, file, domain, data_patterns)
    print(df)
    
    df_all <- rbind(df_all, df)
  }
}


# -------------- write the output into a csv file   -------------------------


#write.csv(df_all,'dataframe.csv')

# TODO 
# add a table with unique values
# create a second dataframe to be saved for programmer to see (csv)
# SDTM.VS | RAW.VS, RAW.DM, SDTM.DM, ...

# get an inpit dataset with names of programmers on main/QC side
# to connect that info later

# are there any unused datasets?