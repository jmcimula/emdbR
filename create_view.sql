/*Creating a view from the main table*/
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
