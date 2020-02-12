library("rlist")
library("purrr")
library("stringr")

#TODO check if line is not commented

NotDomain <- c("VAL","MASTER","SDTM","ADAM","ARCHIVE")
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

paths_txt <-  "/paths.txt"  #"paths_example.txt"

# Dataset paths
path_raw_data <- assign_paths("RAW_DATA",paths_txt)
path_sdtm_data <- assign_paths("SDTM_DATA", paths_txt)
path_adam_data <- assign_paths("ADAM_DATA", paths_txt)

# Program paths
path_sdtm_program <- assign_paths("SDTM_PROGRAM", paths_txt)
path_adam_program <- assign_paths("ADAM_PROGRAM", paths_txt)

# ------------------- create the graph input dataset --------------------------------

### 1. Read in all datasets that are in RAW folder

datasets_f <- function(path, pattern){
  
  clean <- function(x){
    x <- paste(pattern,str_replace(x, ".sas7bdat",""), sep="")
    invisible(toupper(x))
  }
  
  datasets_list <- list.files(path, pattern="*.sas7bdat")
  clean_list <- lapply(datasets_list, function(x) clean(x))
  
  invisible(clean_list)
}


### 2. Create a list of all programs in validation folder in SDTM /ADaM folders

program_list_sdtm <- list.files(path_sdtm_program, pattern="*.sas")
program_list_adam <- list.files(path_adam_program, pattern="*.sas")


### 3. Return datasets present in the validation programs

processFile <- function(path, fileName, domain, data_patterns) {
  
  con = file(paste(path, fileName, sep=""))
  
  lines <- toupper(readLines(con, warn = FALSE))
  
  list_matches <- c()
  
  for (line in lines) {
    
    for (pattern in data_patterns) {
      data_ = regmatches(line, gregexpr(pattern, line))
      
      if (!is.na(data_[[1]][1])){
        list_matches <- list.append(list_matches, data_)
      }
    }
  }
  
  final <- unique(unlist(list_matches, use.names = FALSE))
  
  domain_col <- rep(c(domain), times = length(final))
  
  df <- as.data.frame(list(list(final), domain_col))
  colnames(df) <- c("from", "to")
  
  df <- subset(df, as.character(from) != as.character(to))
  
  close(con)
  return(df)
}


### 4. Create a dataframe containing all results
#       - different colours for different levels
#       - must contain two non-empy columns: "source", "target"


create_dataframe <- function(program_list, program_path, pattern){
  
  lista = c()
  df_all <- data.frame(matrix(ncol = 2, nrow = 0))
  colnames(df_all) <- c("from", "to")
  data_patterns <- c("RAW\\.[A-Z0-9]+", "SDTM\\.[A-Z0-9]+", "ADAM\\.[A-Z0-9]+")
  
  for (file in program_list){
    print(strrep("-",25)) 
    print(file)
    
    get_domain <- function(x){
      domain <- unlist(strsplit(x, "_"))
      domain <- regmatches(domain, gregexpr("[A-Za-z0-9]+\\.sas", domain))[-1]
      domain <- gsub(".sas","",domain)
      domain <- toupper(domain[-1])
      
      invisible(domain)
    }
    
    domain <- get_domain(file)
  
    if (any(domain %in% NotDomain)) { }
    else if (length(domain) > 0) {
  
      domain <- paste(pattern, domain, sep="")
      df <- processFile(program_path, file, domain, data_patterns)
  
      print(strrep("-",25))    
      print(df)
      
      df_all <- rbind(df_all, df)
    }
  }
  invisible(df_all)
}

#data_patterns <- c("RAW\\.[A-Z0-9]+", "SDTM\\.[A-Z0-9]+")

sdtm_df <- create_dataframe(program_list_sdtm, path_sdtm_program, "SDTM.")
adam_df <- create_dataframe(program_list_adam, path_adam_program, "ADAM.")

df_all <- rbind(sdtm_df, adam_df)

### 4b. Add groups to have different colours

check_group <- function(x){

  x_split <- unlist(strsplit(x[1][1], "[.]"))
  type <- x_split[1]
 
  if (type %in% c("RAW","SDTM","ADAM")){ return (type)}
}

### 5. Get unique list of names of all datasets found

get_all_names <- function(){
  source_in_list <- as.list(levels(df_all$from))
  target_in_list <- as.list(levels(df_all$to))
  
  every_dataset <- unique(c(source_in_list, target_in_list))
  s <- sort(unlist(every_dataset))
  
  df <- data.frame(matrix(unlist(s), nrow=length(s), byrow=T))
  colnames(df) <- c("id")
  
  invisible(df)
}

unique <- get_all_names()

unique$group <- apply(unique, 1, FUN = function(id) check_group(id))

### 6. Check if all exisitng datasets are used in programs

# list of all datasets present in study folders
raw_list <- datasets_f(path_raw_data, "RAW.")
sdtm_list <- datasets_f(path_sdtm_data, "SDTM.")
adam_list <- datasets_f(path_adam_data, "ADAM.")

# -------------- write the output into a csv file   -------------------------


write.csv(df_all, 'dataframe.csv', row.names=FALSE)

# unique names of all datasets to pu in the drop-down list in Shiny
write.csv(unique, 'unique_names.csv', row.names=FALSE)

# not used datasets 
#write.csv(not_used,'not_used.csv', row.names=FALSE)



# TODO 
# create a second dataframe to be saved for programmer to see (csv)
# SDTM.VS | RAW.VS, RAW.DM, SDTM.DM, ...

# get an inpit dataset with names of programmers on main/QC side
# to connect that info later
