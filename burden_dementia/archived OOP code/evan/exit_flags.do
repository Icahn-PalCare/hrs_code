
local oop MC_HMO long_term_care hospital_OOP NH_OOP hospice_OOP doctor_OOP patient_OOP dental_OOP RX_OOP home_OOP special_OOP other_OOP ///
			non_med_OOP home_modif_OOP hospital_NH_OOP home_special_OOP private_medigap_1 private_medigap_2 private_medigap_3
			
foreach v of local oop {
	use $savedir/exit_oop.dta, clear
	keep HHID PN year `v'
	merge 1:1 HHID PN year using $savedir/exit_oopi1.dta, update keepusing(`v') gen(X)
	merge 1:1 HHID PN year using $savedir/exit_oopi2.dta, update keepusing(`v') gen(Y)
	gen flag_`v' = X
	replace flag_`v' = 6 if Y==4 & `v'==0
	replace flag_`v' = 7 if Y==4 & `v'!=0
	drop X Y
	replace flag_`v' = 0 if `v'==.
	save $savedir/exit_`v'.dta, replace
}



use $savedir/exit_doctor_OOP.dta, clear
merge 1:1 HHID PN year using $savedir/exit_use.dta, nogen keepusing(dr_visits)
replace flag_doctor_OOP = 8 if flag_doctor_OOP == 7 & dr_visits > 0 & dr_visits < .
drop dr_visits
save $savedir/exit_doctor_OOP.dta, replace

use $savedir/exit_hospital_OOP.dta, clear
merge 1:1 HHID PN year using $savedir/exit_use.dta, nogen keepusing(hospital_nights)
replace flag_hospital_OOP = 8 if flag_hospital_OOP == 7 & hospital_nights > 0 & hospital_nights < .
drop hospital_nights
save $savedir/exit_hospital_OOP.dta, replace

use $savedir/exit_NH_OOP.dta, clear
merge 1:1 HHID PN year using $savedir/exit_use.dta, nogen keepusing(nh_nights)
replace flag_NH_OOP = 8 if flag_NH_OOP == 7 & nh_nights > 0 & nh_nights < .
drop nh_nights
save $savedir/exit_NH_OOP.dta, replace


use $savedir/exit_oopi2.dta, clear

keep HHID PN year

foreach v of local oop {
	merge 1:1 HHID PN year using $savedir/exit_`v'.dta, nogen
	rm $savedir/exit_`v'.dta
}

keep HHID PN year flag_*

lab def FLAG 0 "missing (no impute)" 1 "master (!)" 2 "using (!)" 3 "match (original data)" 4 "update (bracket)" 5 "update (conflict) (!)" 6 "update (zero)" ///
				7 "update (mean only)" 8 "update (utilization)", replace
lab val flag_* FLAG

save $savedir/exit_flags.dta, replace
