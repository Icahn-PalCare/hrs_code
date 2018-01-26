********************************************************************************
** add_months
** consolidates core_months and exit_months
********************************************************************************

foreach type of global data_types {
	if "`type'"=="core"{
		local prev_wave_let_list	
	}
	else if "`type'"=="exit"{
		local prev_wave_let_list	${ex_prior_wave_list}
	}
	local counter = 5
	if "`type'"=="exit" local counter=4
	foreach year of global `type'_year_list{
		
		local counter = `counter'+1
		use "${savedir}/`type'`year'", clear
		
		if "`type'"=="core"{
			local wave_let : word `counter' of ${core_wave_let_list}
			
			gen curr_iw_date = `wave_let'IWYEAR + ( (`wave_let'IWMONTH - 1) / 12 )
					
			if `year'==1992 {
				gen prev_iw_date = curr_iw_date - 1		
				gen months = 12		
			}
			else if `year'==1993 {
				gen prev_iw_date = AIWYEAR + ( (AIWMONTH - 1) / 12 )

				gen months = round( 12 * (curr_iw_date - prev_iw_date) )	
				replace months = 12 if missing(months)						//rrd: spending questions in this wave refer to the last 12 months

				replace prev_iw_date = curr_iw_date - 1 if missing(prev_iw_date) & BIWYEAR==FIRSTIW & !missing(BIWYEAR,FIRSTIW)
				replace prev_iw_date = curr_iw_date - (months/12) if missing(prev_iw_date)		//rrd: sloppy, if mi(pre_iwdate) then months is 12, drop prior line

			}
			else {
				gen prev_iw_date = .
				foreach prev of local prev_wave_let_list {
					replace prev_iw_date = `prev'IWYEAR + ( (`prev'IWMONTH - 1) / 12 ) if prev_iw_date == .
				}
																																																																																										
				gen months = round( 12 * (curr_iw_date - prev_iw_date) )
				replace months = 24 if missing(months) & `wave_let'IWYEAR==FIRSTIW & !missing(`wave_let'IWYEAR,FIRSTIW)
				replace months = 24 if missing(months)

				replace prev_iw_date = curr_iw_date - 2 if missing(prev_iw_date) & `wave_let'IWYEAR==FIRSTIW & !missing(`wave_let'IWYEAR,FIRSTIW)
				replace prev_iw_date = curr_iw_date - (months/12) if missing(prev_iw_date)
			}
		}
		
		else if "`type'"=="exit"{
			local wave_let : word `counter' of ${ex_co_wave_let_list}
			local death_mo : word `counter' of ${death_mo_list}
			local death_yr : word `counter' of ${death_yr_list}
			
			gen death_month = `death_mo' if !inlist(`death_mo',98,99)
			gen death_year  = `death_yr' if !inlist(`death_yr',9997, 9998 , 9999)
					
			gen curr_iw_date = death_year + ( (death_month - 1) / 12 )

			gen prev_iw_date = .
			foreach prev of local prev_wave_let_list {
				replace prev_iw_date = `prev'IWYEAR + ( (`prev'IWMONTH - 1) / 12 ) if prev_iw_date == .
			}
			
			gen months = round( 12 * (curr_iw_date - prev_iw_date) )
			replace months = 24 if missing(months) & FIRSTIW == death_year
			replace months = 1 if months==0
			replace months = 15 if missing(months) | months < 0

			replace prev_iw_date = curr_iw_date - 2 if missing(prev_iw_date) & death_year==FIRSTIW & !missing(death_year,FIRSTIW)
			replace prev_iw_date = curr_iw_date - (12 * months) if missing(prev_iw_date)
			
		}

		
		keep HHID PN year months *_iw_date

		save "${savedir}/`type'`year'_months", replace
		
		local prev_wave_let_list	`wave_let' `prev_wave_let_list' 
	}
}
