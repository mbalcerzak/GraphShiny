
path_file <- paste(getwd(),"/paths.txt",sep="")
for (line in readLines(file(path_file, encoding = "UTF-8"), warn = FALSE)) {

  if (startsWith(line, "RAW")) {
    path_raw <- unlist(strsplit(line, "<-"))[-1]
  } else if (startsWith(line, "PROGRAM")) {
    path <- unlist(strsplit(line, "<-"))[-1]
  }
}
