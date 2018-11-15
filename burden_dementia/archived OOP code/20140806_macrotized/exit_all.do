
********************************************************************************

use $savedir/exit1995_oop.dta, clear

foreach v of varlist MC_HMO hospital_NH_OOP hospice_OOP doctor_OOP RX_OOP home_special_OOP other_OOP non_med_OOP {
	replace `v' = `v' * cpiBASE / cpi1995
}

keep HHID PN year months MC_HMO hospital_NH_OOP hospice_OOP doctor_OOP RX_OOP home_special_OOP other_OOP non_med_OOP

save $savedir/exit1995_all.dta, replace

********************************************************************************

use $savedir/exit1996_oop.dta, clear

foreach v of varlist MC_HMO hospital_NH_OOP hospice_OOP doctor_OOP RX_OOP home_special_OOP other_OOP non_med_OOP {
	replace `v' = `v' * cpiBASE / cpi1996
}

keep HHID PN year months MC_HMO hospital_NH_OOP hospice_OOP doctor_OOP RX_OOP home_special_OOP other_OOP non_med_OOP

save $savedir/exit1996_all.dta, replace

********************************************************************************

use $savedir/exit1998_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_NH_OOP hospice_OOP doctor_OOP RX_OOP home_special_OOP other_OOP non_med_OOP {
	replace `v' = `v' * cpiBASE / cpi1998
}

keep HHID PN year months MC_HMO long_term_care hospital_NH_OOP hospice_OOP doctor_OOP RX_OOP home_special_OOP other_OOP non_med_OOP

save $savedir/exit1998_all.dta, replace

********************************************************************************

use $savedir/exit2000_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_NH_OOP hospice_OOP doctor_OOP RX_OOP home_special_OOP other_OOP non_med_OOP {
	replace `v' = `v' * cpiBASE / cpi2000
}

keep HHID PN year months MC_HMO long_term_care hospital_NH_OOP hospice_OOP doctor_OOP RX_OOP home_special_OOP other_OOP non_med_OOP

save $savedir/exit2000_all.dta, replace

********************************************************************************

use $savedir/exit2002_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP {
	replace `v' = `v' * cpiBASE / cpi2002
}

keep HHID PN year months MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP

save $savedir/exit2002_all.dta, replace

********************************************************************************

use $savedir/exit2004_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP {
	replace `v' = `v' * cpiBASE / cpi2004
}

keep HHID PN year months MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP

save $savedir/exit2004_all.dta, replace

********************************************************************************

use $savedir/exit2006_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP {
	replace `v' = `v' * cpiBASE / cpi2006
}

keep HHID PN year months MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP

save $savedir/exit2006_all.dta, replace

********************************************************************************

use $savedir/exit2008_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP {
	replace `v' = `v' * cpiBASE / cpi2008
}

keep HHID PN year months MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP

save $savedir/exit2008_all.dta, replace

********************************************************************************

use $savedir/exit2010_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP home_modif_OOP {
	replace `v' = `v' * cpiBASE / cpi2010
}

keep HHID PN year months MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP home_modif_OOP

save $savedir/exit2010_all.dta, replace

********************************************************************************

use $savedir/exit2012_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP home_modif_OOP {
	replace `v' = `v' * cpiBASE / cpi2012
}

keep HHID PN year months MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP home_modif_OOP

save $savedir/exit2012_all.dta, replace



********************************************************************************

use $savedir/exit1995_all.dta, clear
append using $savedir/exit1996_all.dta
append using $savedir/exit1998_all.dta
append using $savedir/exit2000_all.dta
append using $savedir/exit2002_all.dta
append using $savedir/exit2004_all.dta
append using $savedir/exit2006_all.dta
append using $savedir/exit2008_all.dta
append using $savedir/exit2010_all.dta
append using $savedir/exit2012_all.dta

egen x = rowtotal( hospital_OOP NH_OOP ),m
replace hospital_NH_OOP = x if missing(hospital_NH_OOP)
drop x

egen x = rowtotal( home_OOP special_OOP ),m
replace home_special_OOP = x if missing(home_special_OOP)
drop x

ren MC_HMO mc_hmo_all
ren long_term_care ltc_all
ren hospital_OOP hospital_all
ren NH_OOP nursing_home_all
ren hospice_OOP hospice_all
ren doctor_OOP doctor_all
ren patient_OOP patient_all
ren dental_OOP dental_all
ren RX_OOP RX_all
ren home_OOP home_all
ren special_OOP special_all
ren non_med_OOP nmed_all
ren other_OOP other_all
ren home_modif_OOP home_modif_all

ren hospital_NH_OOP hospital_NH_all
ren home_special_OOP home_special_all

********************************************************************************

replace mc_hmo_all = min(mc_hmo_all, 400) if mc_hmo_all != .

replace dental_all = min(dental_all, 1000*months) if dental_all != .

replace ltc_all = min(ltc_all, 2000) if ltc_all != .

replace RX_all = min(RX_all, 5000) if RX_all != .
replace doctor_all = min(doctor_all, 5000*months) if doctor_all != .

replace hospice_all = min(hospice_all, 5000*months) if hospice_all != .
replace nmed_all = min(nmed_all, 5000*months) if nmed_all != .
replace home_modif_all = min(home_modif_all, 5000*months) if home_modif_all != .

replace home_all = min(home_all, 15000*months) if home_all != .
replace other_all = min(other_all, 15000*months) if other_all != .
replace hospital_all = min(hospital_all, 15000*months) if hospital_all != .
replace nursing_home_all = min(nursing_home_all, 15000*months) if nursing_home_all != .
replace special_all = min(special_all, 15000*months) if special_all != .
replace patient_all = min(patient_all, 15000*months) if patient_all != .

*used in 1996/2000
replace home_special_all = min(home_special_all, 30000*months) if home_special_all != .
replace hospital_NH_all = min(hospital_NH_all, 30000*months) if hospital_NH_all != .

********************************************************************************

keep HHID PN year months *_all

save $savedir/exit_all.dta, replace

rm $savedir/exit1995_all.dta
rm $savedir/exit1996_all.dta
rm $savedir/exit1998_all.dta
rm $savedir/exit2002_all.dta
rm $savedir/exit2004_all.dta
rm $savedir/exit2006_all.dta
rm $savedir/exit2008_all.dta
rm $savedir/exit2010_all.dta
rm $savedir/exit2012_all.dta

********************************************************************************

use HHID PN year private_medigap_? using $savedir/exit2002_oop.dta, clear
append using $savedir/exit2004_oop.dta ///
				$savedir/exit2006_oop.dta ///
				$savedir/exit2008_oop.dta ///
				$savedir/exit2010_oop.dta ///
				$savedir/exit2012_oop.dta ///
	, keep(HHID PN year private_medigap_?)

reshape long private_medigap@, i(HHID PN year) j(PLAN "_1" "_2" "_3")

drop if private_medigap==.

gen cpi = .
replace cpi = cpiBASE / cpi2012 if year==2012
replace cpi = cpiBASE / cpi2010 if year==2010
replace cpi = cpiBASE / cpi2008 if year==2008
replace cpi = cpiBASE / cpi2006 if year==2006
replace cpi = cpiBASE / cpi2004 if year==2004
replace cpi = cpiBASE / cpi2002 if year==2002

replace private_medigap = private_medigap * cpi
replace private_medigap = min(private_medigap, 2000) if private_medigap != .

merge m:1 HHID PN year using $savedir/exit_use.dta, keepusing(private_medigap_plans) keep(match) nogen

rename private_medigap private_medigap_all

keep private_medigap_all private_medigap_plans

save $savedir/exit_all_private_medigap.dta, replace

use $savedir/exit_all.dta, clear
append using $savedir/exit_all_private_medigap.dta, gen(P)
save $savedir/exit_all.dta, replace

rm $savedir/exit_all_private_medigap.dta
