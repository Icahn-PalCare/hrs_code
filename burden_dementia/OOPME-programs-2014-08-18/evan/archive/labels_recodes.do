

use $savedir/oopme_final_2012_old.dta, clear

lab def LOC_DIE 1 "1.Hospital" 2 "2.NH" 3 "3.Home" 4 "4.Hospice" 5 "5.ALF" 7 "7.Other" 8 "8.DK" 9 "9.RF", replace
lab val loc_die LOC_DIE

lab def NH_LIV 1 "1.NH" 2 "2.Hospice" 5 "5.No" 8 "8.DK" 9 "9.RF", replace
lab val nh_liv NH_LIV

lab def COV ///
	1 "1.Fully Covered" ///
	2 "2.Mostly Covered" ///
	3 "3.Partially Covered" ///
	5 "5.Not Covered at all" ///
	6 "6.No charge" ///
	7 "7.Costs not settled yet" ///
	8 "8.DK;NA" ///
	9 "9.RF" ///
	97 "97.Other (1995)" ///
	98 "98.DK;NA (1995)" ///
	99 "99.RF (1995)" , replace
	
lab val *_cov COV

foreach v of varlist *_use {
	recode `v' (1 7 = 1) (5 = 0) (8 = .d) (9 = .r)		//Note: rx_use: 7.
}

lab def COV93 1 "1.Some costs not covered" 5 "5.All costs covered" 7 "7.Costs not settled yet" 8 "8.DK" 9 "9.RF", replace
lab val *_cov93 COV93

lab def COV94 ///
	0 "0.Inap" ///
	1 "1.Covered completely by HI" ///
	2 "2.Paid entirely OOP" ///
	3 "3.Partly covered by HI" ///
	4 "4.Paid by other person" ///
	5 "5.Paid by curr/prev employer/union" ///
	6 "6.Free, did not pay" ///
	7 "7.Other" ///
	8 "8.DK/NA" ///
	9 "9.RF/NA",  replace
	
lab val *_cov94 COV94	

//_use variables corrected to include additional stays or deaths in hospital, nh, or hospice

replace hospital_use = 1 if loc_die==1
replace nh_use = 1 if loc_die==2 |  nh_liv==1
replace hospice_use = 1 if loc_die==4 | nh_liv==2

lab def USE 0 "0.No" 1 "1.Yes", replace
lab val *_use USE

lab def USE93 1 "1.Yes, R only (Fin Resp. only)" 2 "2.Both" 3 "3.Yes, SP only" 5 "5.No" 8 "8.DK" 9 "9.RF", replace
lab val *_use93 USE93

recode cause_die (101/103=101) (111/119=111) (121/129=121) (131/139=131) (141/149=141) (151/159=151) (161/169=161) (171/179=171) (181/189=151) (191/196=191) ///
					(595/597=595) (601/607=601) (990 996 997 998 999=999)
					
lab def CAUSE_DIE 101 "101.Cancer/Skin Conditions" 111 "111.Musculoskeletal" 121 "121.Heart/Circulatory" 131 "131.Allergies/Hayfever/Sinusitis/Tonsillitis" ///
					141 "141.Endocrine/Metabolic/Nutritional" 151 "151.Digestive System" 161 "161.Neurological" 171 "171.Reproductive/Prostate" ///
					181 "181.Emotional/Psychological" 191 "191.Miscellaneous" 595 "595.Other Symptoms" 601 "601.Not a health condition" ///
					999 "999.No Text/None/Other condition/DK/RF", replace

lab val cause_die CAUSE_DIE	

*Notes:

notes drop _all

notes NH_OOP93: "May reflect spending by both R and SP/P."
notes non_NH_OOP93: "May reflect spending by both R and SP/P."
notes helper_OOP93: "May reflect spending by both R and SP/P."

notes insurance_prem: "Includes MC_B, MC_HMO, MC_D, private_medigap, and long_term_care. Monthly premium."
notes insurance_costs: "Includes MC_B, MC_HMO, MC_D, private_medigap, and long_term_care. Total spending between Interviews."

notes private_medigap_5: "Core 1994 Only. May contain both private_medigap and long_term_care spending"

notes private_ltc: "This variable is used instead of private_medigap & long_term_care in 1992-1994, b/c some of reported private/medigap spending may include LTC."

notes total_OOP: "Totals may not be comparable across all waves---in particular, between 1992-1994 and later waves."

label data "OOPME ver: ${creation_version}: ${ver_description}" //rrd addition

save $savedir/oopme_final_2012_old.dta, replace
