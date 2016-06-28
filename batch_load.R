setwd("~/R/emdbR/data/")

#downloading data from JAEA

url <- c("http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010004/10500010004_", "http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010003/10500010003_", "http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010002/10500010002_","http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010001/10500010001_", "http://emdb.jaea.go.jp/emdb/assets/site_data/en/csv_utf8/10500010000/10500010000_")

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

   }#End-for

#unlink the temporary directory
unlink(temp)

}#End-for

library(DBI)
library(RMySQL)

#Connection with mySQL
mcon = dbConnect(MySQL(), user = 'root', password='',dbname = 'dbtest', host = 'localhost') 

#truncate table
trc <- "truncate table tbl_dose"
dbGetQuery(mcon, trc)

#loading data into the table
file_list <- list.files("~/R/emdbR/data/")
for (file in file_list){

	query <- paste("LOAD DATA LOCAL INFILE '",file,"' INTO TABLE tbl_dose FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES (date, prefecture, city, measurement, latitude, longitude, distance_fukushima, avg_airdose_rate, nb_airdose_rate)", sep = "")

    dbGetQuery(mcon, query)

}#End-for

#Drop the view of the summary
dbGetQuery(mcon, "drop view tbl_dose_ex")

#Create the view with the summary of the data
crt_view <- "
            create view tbl_dose_ex as
			select substr(date,1,4) date,
			       prefecture,
				   city, 
				   measurement,
				   latitude,
				   longitude,
				   distance_fukushima distance_from_fukushima,
				   count(*) obs,
				   sum(avg_airdose_rate) avg_airdose_rate,
				   sum(nb_airdose_rate) nb_airdose_rate
            from tbl_dose
			group  by substr(date,1,4), 
      			      prefecture,
					  city,
					  measurement,
					  latitude,
					  longitude,
					  distance_fukushima
		"
dbGetQuery(mcon, crt_view)


rs = dbSendQuery(mcon, "select * from tbl_dose_ex where date in ('2011')")
data = fetch(rs, n = -1)


data %>%
    group_by(date, prefecture) %>%
    summarise(dose = sum(avg_airdose_rate))
	


#disconnect
dbDisconnect(dbListConnections(MySQL())[[1]])
