
local oop ///
	private_ltc ///1992-1994
	NH_OOP93 non_NH_OOP93 ///1993
	private_medigap_1 private_medigap_2 private_medigap_3 private_medigap_4 private_medigap_5 ///1994-2010 (_4: 1994/1996 _5: 1994)
	hospital_NH_doctor_OOP ///1994 
	RX_OOP ///1994-2010
	MC_HMO ///1995-2010
	long_term_care ///1995-2010
	hospital_NH_OOP doctor_patient_dental_OOP home_special_OOP ///1995-2000
	hospital_OOP NH_OOP doctor_OOP patient_OOP dental_OOP home_OOP special_OOP ///2002-2010
	MC_D ///2008-2010
	other_OOP //2010

foreach v of local oop {
	use $savedir/core_oop.dta, clear
	keep HHID PN year `v'
	merge 1:1 HHID PN year using $savedir/core_oopi1.dta, update keepusing(`v') gen(X)		//rrd: update option replaces missing values from master 
	merge 1:1 HHID PN year using $savedir/core_oopi2.dta, update keepusing(`v') gen(Y)
	gen flag_`v' = X						//rrd: should only have 3 (match/same in oop and oopi1 (both mising or given)) 4(update/bracket updated) 5 (conflct/shouldnt happen)
	replace flag_`v' = 6 if Y==4 & `v'==0	//rrd: updated from oopi2 and assigned a 0 (either paid by other or no use)	
	replace flag_`v' = 7 if Y==4 & `v'!=0	//rrd: update from oopmu
	drop X Y							
	replace flag_`v' = 0 if `v'==.			//rrd: 0=no impute, 1=?, 2=?, 3=given, 4=bracket impute, 5=shouldnt happen, 6=impute 0, 7= impute from oopi2 (on use or mean)
	save $savedir/core_`v'.dta, replace
}



use $savedir/core_doctor_OOP.dta, clear
merge 1:1 HHID PN year using $savedir/core_use.dta, nogen keepusing(dr_visits)
replace flag_doctor_OOP = 8 if flag_doctor_OOP == 7 & dr_visits > 0 & dr_visits < .			//rrd: 8 = impute from usage (updating 7)
drop dr_visits									
save $savedir/core_doctor_OOP.dta, replace

use $savedir/core_hospital_OOP.dta, clear
merge 1:1 HHID PN year using $savedir/core_use.dta, nogen keepusing(hospital_nights)
replace flag_hospital_OOP = 8 if flag_hospital_OOP == 7 & hospital_nights > 0 & hospital_nights < . //rrd: 8 = impute from usage (updating 7)
drop hospital_nights
save $savedir/core_hospital_OOP.dta, replace

use $savedir/core_NH_OOP.dta, clear
merge 1:1 HHID PN year using $savedir/core_use.dta, nogen keepusing(nh_nights)
replace flag_NH_OOP = 8 if flag_NH_OOP == 7 & nh_nights > 0 & nh_nights < .  //rrd: 8 = impute from usage (updating 7)
drop nh_nights
save $savedir/core_NH_OOP.dta, replace



use $savedir/core_oopi2.dta, clear		//rrd: could use "using" and smaller data

keep HHID PN year

foreach v of local oop {
	merge 1:1 HHID PN year using $savedir/core_`v'.dta, nogen
	rm $savedir/core_`v'.dta
}

keep HHID PN year flag_*

lab def FLAG 0 "missing (no impute)" 1 "master (!)" 2 "using (!)" 3 "match (original data)" 4 "update (bracket)" 5 "update (conflict) (!)" 6 "update (zero)" ///
				7 "update (mean only)" 8 "update (utilization)", replace
lab val flag_* FLAG

save $savedir/core_flags.dta, replace
