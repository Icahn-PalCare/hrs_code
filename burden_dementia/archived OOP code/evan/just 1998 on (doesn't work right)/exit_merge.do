/*
use $savedir/exit1995_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap hospice_OOP doctor_OOP RX_OOP other_OOP non_med_OOP hospital_NH_OOP home_special_OOP
merge 1:1 HHID PN using $savedir/exit1995_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_1995_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit1995_merge.dta, replace

use $savedir/exit1996_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap hospice_OOP doctor_OOP RX_OOP other_OOP non_med_OOP hospital_NH_OOP home_special_OOP
merge 1:1 HHID PN using $savedir/exit1996_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_1996_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit1996_merge.dta, replace

use $savedir/exit1998_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap long_term_care hospice_OOP doctor_OOP RX_OOP other_OOP non_med_OOP hospital_NH_OOP home_special_OOP
merge 1:1 HHID PN using $savedir/exit1998_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_1998_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit1998_merge.dta, replace

use $savedir/exit2000_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap long_term_care hospice_OOP doctor_OOP RX_OOP other_OOP non_med_OOP hospital_NH_OOP home_special_OOP
merge 1:1 HHID PN using $savedir/exit2000_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_2000_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit2000_merge.dta, replace
*/
use $savedir/exit2002_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
merge 1:1 HHID PN using $savedir/exit2002_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_2002_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit2002_merge.dta, replace

use $savedir/exit2004_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
merge 1:1 HHID PN using $savedir/exit2004_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_2004_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit2004_merge.dta, replace

use $savedir/exit2006_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
merge 1:1 HHID PN using $savedir/exit2006_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_2006_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit2006_merge.dta, replace

use $savedir/exit2008_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP RX_OOP home_OOP special_OOP other_OOP non_med_OOP
merge 1:1 HHID PN using $savedir/exit2008_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_2008_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit2008_merge.dta, replace

use $savedir/exit2010_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP ///
			home_modif_OOP
merge 1:1 HHID PN using $savedir/exit2010_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_2010_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit2010_merge.dta, replace

use $savedir/exit2012_oopi2.dta, clear
keep HHID PN year MC_HMO MC_B private_medigap long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP ///
			home_modif_OOP
merge 1:1 HHID PN using $savedir/exit2012_use.dta, nogen
merge 1:1 HHID PN using $savedir/helper_exit_2012_imputed, nogen keepusing(numhelpers numpaidhelpers helper_OOP)
save $savedir/exit2012_merge.dta, replace

use $savedir/exit2002_merge.dta
append using $savedir/exit2004_merge.dta 
append using $savedir/exit2006_merge.dta 
append using $savedir/exit2008_merge.dta 
append using $savedir/exit2010_merge.dta 
append using $savedir/exit2012_merge.dta

sort HHID PN year

merge 1:1 HHID PN year using $savedir/exit_flags.dta, nogen

scalar drop _all
do load_cpi

gen cpi = .
replace cpi = cpiBASE / cpi2014 if year==2014
replace cpi = cpiBASE / cpi2012 if year==2012
replace cpi = cpiBASE / cpi2010 if year==2010
replace cpi = cpiBASE / cpi2008 if year==2008
replace cpi = cpiBASE / cpi2006 if year==2006
replace cpi = cpiBASE / cpi2004 if year==2004
replace cpi = cpiBASE / cpi2002 if year==2002
replace cpi = cpiBASE / cpi2000 if year==2000
replace cpi = cpiBASE / cpi1998 if year==1998
replace cpi = cpiBASE / cpi1996 if year==1996
replace cpi = cpiBASE / cpi1995 if year==1995

local oop MC_HMO MC_B private_medigap long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP ///
			non_med_OOP home_modif_OOP /*hospital_NH_OOP home_special_OOP*/ helper_OOP
			
foreach v of local oop {
	replace `v' = `v' * cpi
}			
			
keep HHID PN year `oop' flag_* *_iw_date months *_use *_liv *_die *_cov *_nights *_visits numhelpers numpaidhelpers	

save $savedir/exit_merged.dta, replace

cap rm $savedir/exit1995_merge.dta
cap rm $savedir/exit1996_merge.dta
cap rm $savedir/exit1998_merge.dta
cap rm $savedir/exit2000_merge.dta
cap rm $savedir/exit2002_merge.dta
cap rm $savedir/exit2004_merge.dta
cap rm $savedir/exit2006_merge.dta
cap rm $savedir/exit2008_merge.dta
cap rm $savedir/exit2010_merge.dta
cap rm $savedir/exit2012_merge.dta
