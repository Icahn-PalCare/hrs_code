local trk_keep_vars 	HHID PN BIRTHMO BIRTHYR *IWMONTH *IWYEAR FIRSTIW 

**************************************************************************************
** RAND HRS
use hhid pn r*mstat h*itot using "${randdir}/rndhrs_${rand_version}", clear
rename *, l
rename hhid HHID
rename pn PN

save "${savedir}/rndhrs${rand_version}vars", replace

**************************************************************************************

foreach type of global data_types{
	//note--12/1/17 changed counter to 5 from zero so that we'd start with 1998 for core & 2002 for exit
	local counter = 5
	if "`type'"=="exit" local counter=6
	foreach year of global `type'_year_list{
		di "`year'"
		local counter = `counter'+1
		di "`counter'"
		local wave_num : word `counter' of ${`type'_wave_num_list}
		local wave_let : word `counter' of ${`type'_wave_let_list}
		local hh_file : word `counter' of ${`type'_hh_file_list}
		local merge_m1 : word `counter' of ${`type'_merge1m_list}
		forvalues m=1/5{
			local merge_11_`m' : word `counter' of ${`type'_merge11_`m'_list}
		}
		
		di "${loaddir}/`hh_file'"
		use "${loaddir}/`hh_file'", clear
		rename *,u

		if "`merge_m1'"!=".na"{
			merge 1:m HHID `wave_let'SUBHH using "${loaddir}/`merge_m1'", nogen
		}
		forvalues m=1/5{
			if "`merge_11_`m''"!=".na"{
				merge 1:1 HHID PN using "${loaddir}/`merge_11_`m''", nogen
			}
		}
		merge 1:1 HHID PN using "${loaddir}/${tracker_name}", keep(match master) keepusing(`trk_keep_vars') nogenerate
		
		if "`type'"=="core"{
			merge 1:1 HHID PN using "${savedir}/rndhrs${rand_version}vars" , keep(match master) nogenerate /*keepusing(r`wave_num'mstat h`wave_num'itot)*/	//used in bracket imputations
		}
		
		else if "`type'"=="exit"{
			if `year' >= 2008 {
				merge 1:1 HHID PN using "${savedir}/rndhrs${rand_version}vars" , keep(match master) nogenerate /*keepusing(r`prior_wave_num'mstat h`prior_wave_num'itot)*/	//used in bracket imputations
			}
			if `year'==1995 {
				drop if HHID=="201390" & PN=="020"
			}
			if `year'==2002 {
				gen index = HHID + PN
				drop if (index == "011863010" | index == "203802010")
				drop index
			}
			local prior_wave_num `wave_num'
		}
		
		sort HHID PN
		gen year = `year'
		save "${savedir}/`type'`year'", replace
	}
}


**************************************************************************************
rm "${savedir}/rndhrs${rand_version}vars.dta"
