
********************************************************************************

use $savedir/core1994_oop.dta, clear

foreach v of varlist hospital_NH_doctor_OOP RX_OOP {
	replace `v' = `v' * cpiBASE / cpi1994
}

keep HHID PN months year hospital_NH_doctor_OOP RX_OOP

save $savedir/core1994_all.dta, replace

********************************************************************************

use $savedir/core1995_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_NH_OOP doctor_patient_dental_OOP RX_OOP home_special_OOP {
	replace `v' = `v' * cpiBASE / cpi1995
}

keep HHID PN months year MC_HMO long_term_care hospital_NH_OOP doctor_patient_dental_OOP RX_OOP home_special_OOP

save $savedir/core1995_all.dta, replace

********************************************************************************

use $savedir/core1996_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_NH_OOP doctor_patient_dental_OOP RX_OOP home_special_OOP {
	replace `v' = `v' * cpiBASE / cpi1996
}

keep HHID PN months year MC_HMO long_term_care hospital_NH_OOP doctor_patient_dental_OOP RX_OOP home_special_OOP

save $savedir/core1996_all.dta, replace

********************************************************************************

use $savedir/core1998_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_NH_OOP doctor_patient_dental_OOP RX_OOP home_special_OOP {
	replace `v' = `v' * cpiBASE / cpi1998
}

keep HHID PN months year long_term_care hospital_NH_OOP doctor_patient_dental_OOP RX_OOP home_special_OOP

save $savedir/core1998_all.dta, replace

********************************************************************************

use $savedir/core2000_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_NH_OOP doctor_patient_dental_OOP RX_OOP home_special_OOP {
	replace `v' = `v' * cpiBASE / cpi2000
}

keep HHID PN months year long_term_care hospital_NH_OOP doctor_patient_dental_OOP RX_OOP home_special_OOP

save $savedir/core2000_all.dta, replace

********************************************************************************

use $savedir/core2002_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP {
	replace `v' = `v' * cpiBASE / cpi2002
}

keep HHID PN months year MC_HMO long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP

save $savedir/core2002_all.dta, replace

********************************************************************************

use $savedir/core2004_oop.dta, clear

foreach v of varlist MC_HMO long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP {
	replace `v' = `v' * cpiBASE / cpi2004
}

keep HHID PN months year MC_HMO long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP

save $savedir/core2004_all.dta, replace

********************************************************************************

use $savedir/core2006_oop.dta, clear

foreach v of varlist MC_HMO MC_D long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP {
	replace `v' = `v' * cpiBASE / cpi2006
}

keep HHID PN months year MC_HMO MC_D long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP

save $savedir/core2006_all.dta, replace

********************************************************************************

use $savedir/core2008_oop.dta, clear

foreach v of varlist MC_HMO MC_D long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP {
	replace `v' = `v' * cpiBASE / cpi2008
}

keep HHID PN months year MC_HMO MC_D long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP

save $savedir/core2008_all.dta, replace

********************************************************************************

use $savedir/core2010_oop.dta, clear

foreach v of varlist MC_HMO MC_D long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP {
	replace `v' = `v' * cpiBASE / cpi2010
}

keep HHID PN months year MC_HMO MC_D long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP

save $savedir/core2010_all.dta, replace


********************************************************************************

use $savedir/core2012_oop.dta, clear

foreach v of varlist MC_HMO MC_D long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP {
	replace `v' = `v' * cpiBASE / cpi2012
}

keep HHID PN months year MC_HMO MC_D long_term_care hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP

save $savedir/core2012_all.dta, replace



********************************************************************************

use $savedir/core1994_all.dta, clear

append using $savedir/core1995_all.dta
append using $savedir/core1996_all.dta
append using $savedir/core1998_all.dta
append using $savedir/core2000_all.dta
append using $savedir/core2002_all.dta
append using $savedir/core2004_all.dta
append using $savedir/core2006_all.dta
append using $savedir/core2008_all.dta
append using $savedir/core2010_all.dta
append using $savedir/core2012_all.dta

//used for 1995-1998

egen x = rowtotal( hospital_OOP NH_OOP ),m
replace hospital_NH_OOP = x if missing(hospital_NH_OOP)
drop x

egen x = rowtotal( doctor_OOP patient_OOP dental_OOP ),m
replace doctor_patient_dental_OOP = x if missing(doctor_patient_dental_OOP)
drop x

egen x = rowtotal( home_OOP special_OOP ),m
replace home_special_OOP = x if missing(home_special_OOP)
drop x

//used for 1994

egen x = rowtotal( hospital_OOP NH_OOP doctor_OOP),m
replace hospital_NH_doctor_OOP = x if missing(hospital_NH_doctor_OOP)

ren MC_HMO mc_hmo_all
ren MC_D mc_d_all
ren long_term_care ltc_all
ren hospital_OOP hospital_all
ren NH_OOP nursing_home_all
ren doctor_OOP doctor_all
ren patient_OOP patient_all
ren dental_OOP dental_all
ren RX_OOP RX_all
ren home_OOP home_all
ren special_OOP special_all
ren other_OOP other_all

ren hospital_NH_OOP hospital_NH_all
ren doctor_patient_dental_OOP doctor_patient_dental_all
ren home_special_OOP home_special_all
ren hospital_NH_doctor_OOP hospital_NH_doctor_all

********************************************************************************
//rrd: these are all redunddant from _oop program
replace mc_hmo_all = min(mc_hmo_all, 400) if mc_hmo_all != .
replace mc_d_all = min(mc_d_all, 100) if mc_d_all != .

replace dental_all = min(dental_all, 1000*months) if dental_all != .

replace ltc_all = min(ltc_all, 2000) if ltc_all != .

replace RX_all = min(RX_all, 5000) if RX_all != .
replace doctor_all = min(doctor_all, 5000*months) if doctor_all != .

replace home_all = min(home_all, 15000*months) if home_all != .
replace special_all = min(special_all, 15000*months) if special_all != .
replace other_all = min(other_all, 15000*months) if other_all != .
replace hospital_all = min(hospital_all, 15000*months) if hospital_all != .
replace nursing_home_all = min(nursing_home_all, 15000*months) if nursing_home_all != .
replace patient_all = min(patient_all, 15000*months) if patient_all != .

replace home_special_all = min(home_special_all, 30000*months) if home_special_all != .
replace hospital_NH_all = min(hospital_NH_all, 30000*months) if hospital_NH_all != .
replace doctor_patient_dental_all = min(doctor_patient_dental_all, 21000*months) if doctor_patient_dental_all != .
//replace hospital_NH_doctor_all = min(hospital_NH_doctor_all, 35000*months) if hospital_NH_doctor_all != .

********************************************************************************

keep HHID PN year *_all

save $savedir/core_all.dta, replace

rm $savedir/core1994_all.dta
rm $savedir/core1995_all.dta
rm $savedir/core1996_all.dta
rm $savedir/core1998_all.dta
rm $savedir/core2002_all.dta
rm $savedir/core2004_all.dta
rm $savedir/core2006_all.dta
rm $savedir/core2008_all.dta
rm $savedir/core2010_all.dta
rm $savedir/core2012_all.dta

********************************************************************************

use HHID PN year private_medigap_? using $savedir/core2002_oop.dta, clear
append using $savedir/core2004_oop.dta ///
				$savedir/core2006_oop.dta ///
				$savedir/core2008_oop.dta ///
				$savedir/core2010_oop.dta ///
				$savedir/core2012_oop.dta ///
	, keep(HHID PN year private_medigap_?)

reshape long private_medigap@, i(HHID PN year) j(PLAN "_1" "_2" "_3")		//rrd: ignoring early private medigaps!!!

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

merge m:1 HHID PN year using $savedir/core_use.dta, keepusing(private_medigap_plans) keep(match) nogen		//rrd: should make counter manually for early waves

rename private_medigap private_medigap_all

keep private_medigap_all private_medigap_plans

save $savedir/core_all_private_medigap.dta, replace

use $savedir/core_all.dta, clear
append using $savedir/core_all_private_medigap.dta, gen(P)				//rrd: will have data set non uniqu by id now since medigap set is long and appended (really want merge with unique id)
save $savedir/core_all.dta, replace										//rrd: obs with P only have vars for "private_medigap_all private_medigap_plans"

rm $savedir/core_all_private_medigap.dta
