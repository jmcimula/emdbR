setwd("~/R/emdbR/data/")

#downloading data from JAEA

url <- c("http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010004/10500010004_", "http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010003/10500010003_")
#,"http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010002/10500010002_","http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010001/10500010001_", "http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010000/10500010000_")

for ( j in 1 : length(url)){

#open a temporary directory to store data
temp <- tempdir()

#Loop from 1 to 47 because Japan has 47 prefectures
for (i in 1 : 47){

   if  (i < 10) { i <- paste("0", i, sep = "")}else{i <- paste("", i, sep = "")}  
   
   link <- paste (url[j], i, ".csv.zip", sep = "")
   
   file <- basename(link)
   
   #download the zip file and store in the "file" object 
   download.file(link, file)
   
   #unzip the file and store in the temp folder
   unzip(file)
   
   #delete the zip file
   unlink(file)
}

#unlink the temporary directory
unlink(temp)

}


#data loading
rm(dataset)

file_list <- list.files("~/R/emdbR/data/")

for (file in file_list){
  
  # if the merged dataset doesn't exist, create it
  if (!exists("dataset")){

        dataset <- read.csv(file)

  }
   
  # if the merged dataset does exist, append to it
  if (exists("dataset")){
  
    temp_dataset <-read.csv(file)
	
	#print(file)
    
	dataset <-rbind(dataset, temp_dataset)
    
	rm(temp_dataset)
  
  }
 
}